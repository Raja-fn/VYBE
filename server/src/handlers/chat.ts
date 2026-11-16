import { z } from 'zod';

import { detectContactSharing } from '../domain/contactDetector';
import { uidSchema, type Caller } from '../shared/callable';
import type { Sql } from '../shared/db';
import { appError, ErrorCodes } from '../shared/errorCodes';
import { visibleCompanion } from './booking';
import { bumpUnread, chatIdFor } from './chatCards';
import type { Deps } from './deps';

export async function isBlockedEitherWay(sql: Sql, a: string, b: string): Promise<boolean> {
  const rows = await sql`
    select 1 from blocks
    where (blocker_uid = ${a} and blocked_uid = ${b}) or (blocker_uid = ${b} and blocked_uid = ${a}) limit 1`;
  return rows.length > 0;
}

// ---------- startChat ----------

export const startChatInput = z.object({ companionUid: uidSchema });

/**
 * A seeker opens a chat with a companion they can see. Costs
 * `creditCostStartChat` once per pair; opening it again is free.
 */
export async function startChatLogic(
  deps: Deps,
  caller: Caller,
  input: z.infer<typeof startChatInput>,
): Promise<{ chatId: string; charged: boolean; balance: number }> {
  const { sql, config } = deps;
  const { companion } = await visibleCompanion(deps, caller, input.companionUid);
  const chatId = chatIdFor(caller.uid, companion.uid);
  const cost = config.creditCostStartChat;
  const now = deps.now();

  return sql.begin(async (tx) => {
    const people = await tx<{ id: string; display_name: string | null }[]>`
      select id, display_name from users where id in ${tx([caller.uid, companion.uid])} order by id for update`;
    const [account] = await tx<{ balance: number }[]>`select balance from credit_accounts where uid = ${caller.uid} for update`;
    const balance = account?.balance ?? 0;
    const [chat] = await tx<{ status: string }[]>`select status from chats where id = ${chatId}`;
    if (chat) {
      if (chat.status !== 'open') throw appError(ErrorCodes.blocked, 'This chat is closed.');
      return { chatId, charged: false, balance };
    }
    if (balance < cost) throw appError(ErrorCodes.insufficientCredits, 'Not enough credits.');
    const after = balance - cost;
    const ledgerId = `${chatId}_open`;
    const name = (uid: string) => people.find((p) => p.id === uid)?.display_name ?? '';

    await tx`
      insert into credit_accounts (uid, balance, updated_at) values (${caller.uid}, ${after}, ${now})
      on conflict (uid) do update set balance = excluded.balance, updated_at = excluded.updated_at`;
    await tx`
      insert into credit_ledger (id, uid, delta, balance_after, reason, ref_type, ref_id, idempotency_key, created_at)
      values (${ledgerId}, ${caller.uid}, ${-cost}, ${after}, 'chat_start', 'chat', ${chatId}, ${ledgerId}, ${now})`;
    const participantInfo = {
      [caller.uid]: { displayName: name(caller.uid) },
      [companion.uid]: { displayName: name(companion.uid) },
    };
    const lastMessage = { type: 'system', text: '', senderUid: null, at: now.toISOString() };
    await tx`
      insert into chats (id, participants, participant_info, seeker_uid, companion_uid, opened_by, open_ledger_id, status,
        last_message, last_message_at, unread, created_at)
      values (${chatId}, ${[caller.uid, companion.uid].sort()}::uuid[], ${tx.json(participantInfo)}, ${caller.uid},
        ${companion.uid}, ${caller.uid}, ${ledgerId}, 'open', ${tx.json(lastMessage)}, ${now},
        ${tx.json({ [caller.uid]: 0, [companion.uid]: 0 })}, ${now})`;
    await tx`
      insert into messages (chat_id, id, sender_uid, type, system_kind, credits, text, created_at)
      values (${chatId}, 'start', null, 'system', 'chat_started', ${cost}, null, ${now})`;
    return { chatId, charged: true, balance: after };
  });
}

// ---------- sendMessage ----------

export const sendMessageInput = z.object({
  chatId: z.string().min(1),
  text: z.string(),
  /** Client-generated id: a retry never posts the message twice. */
  clientId: z.string().regex(/^[A-Za-z0-9_-]{8,40}$/),
});

/**
 * Records a blocked attempt. On the configured strike (3rd by default)
 * inside the window, files an automatic report for the admin queue.
 */
async function recordStrike(deps: Deps, uid: string, chatId: string, reasons: string[]) {
  const { config } = deps;
  const now = deps.now();
  const windowMs = config.moderationStrikeWindowHours * 3_600_000;

  await deps.sql.begin(async (tx) => {
    const [strike] = await tx<{ count: number; window_started_at: Date }[]>`
      select count, window_started_at from moderation_strikes where uid = ${uid} for update`;
    const fresh = !strike || strike.window_started_at.getTime() + windowMs <= now.getTime();
    const count = fresh ? 1 : strike.count + 1;
    const windowStartedAt = fresh ? now : strike.window_started_at;
    let reportId: string | null = null;
    if (count === config.moderationStrikesForReport) {
      const [report] = await tx<{ id: string }[]>`
        insert into reports (reporter_uid, reported_uid, context_type, context_ref_id, reason, details, source, status, created_at)
        values (null, ${uid}, 'chat', ${chatId}, 'off_app_contact',
          ${`Blocked ${count} messages in ${config.moderationStrikeWindowHours} h: ${reasons.join(', ')}`},
          'auto_moderation', 'open', ${now})
        returning id`;
      reportId = report.id;
    }
    await tx`
      insert into moderation_strikes as m (uid, count, window_started_at, last_reasons, last_report_id, updated_at)
      values (${uid}, ${count}, ${windowStartedAt}, ${reasons}, ${reportId}, ${now})
      on conflict (uid) do update set count = excluded.count, window_started_at = excluded.window_started_at,
        last_reasons = excluded.last_reasons, last_report_id = coalesce(excluded.last_report_id, m.last_report_id),
        updated_at = excluded.updated_at`;
  });
}

interface ChatRow {
  participants: string[];
  status: string;
}

async function loadChatFor(sql: Sql, chatId: string, uid: string): Promise<ChatRow> {
  const [chat] = await sql<ChatRow[]>`select participants, status from chats where id = ${chatId}`;
  if (!chat || !chat.participants.includes(uid)) throw appError(ErrorCodes.notFound, 'Chat not found.');
  return chat;
}

export async function sendMessageLogic(
  deps: Deps,
  caller: Caller,
  input: z.infer<typeof sendMessageInput>,
): Promise<{ messageId: string }> {
  const { sql, config } = deps;
  const text = input.text.trim();
  if (text.length === 0 || text.length > config.chatMessageMaxLength) {
    throw appError(ErrorCodes.invalidInput, 'Message is empty or too long.');
  }

  const chat = await loadChatFor(sql, input.chatId, caller.uid);
  const other = chat.participants.find((p) => p !== caller.uid)!;
  if (chat.status !== 'open' || (await isBlockedEitherWay(sql, caller.uid, other))) {
    throw appError(ErrorCodes.blocked, 'This chat is closed.');
  }

  // Moderation runs before anything is stored.
  const reasons: string[] = detectContactSharing(text);
  const verdict = await deps.services.moderation.checkText(text);
  if (!verdict.allowed) reasons.push(verdict.reason);
  if (reasons.length > 0) {
    await recordStrike(deps, caller.uid, input.chatId, reasons);
    throw appError(ErrorCodes.moderationBlocked, 'This message was not sent.');
  }

  const messageId = `${caller.uid}_${input.clientId}`;
  const now = deps.now();
  const last = { type: 'text', text, senderUid: caller.uid, at: now.toISOString() };
  await sql.begin(async (tx) => {
    const inserted = await tx`
      insert into messages (chat_id, id, sender_uid, type, text, created_at)
      values (${input.chatId}, ${messageId}, ${caller.uid}, 'text', ${text}, ${now})
      on conflict do nothing returning id`;
    if (inserted.length === 0) return;
    await tx`
      update chats set last_message = ${tx.json(last)}, last_message_at = ${now}, unread = ${bumpUnread(tx, other)}
      where id = ${input.chatId}`;
  });
  return { messageId };
}

// ---------- markChatRead ----------

export const markChatReadInput = z.object({ chatId: z.string().min(1) });

export async function markChatReadLogic(deps: Deps, caller: Caller, input: { chatId: string }): Promise<{ ok: true }> {
  await loadChatFor(deps.sql, input.chatId, caller.uid);
  await deps.sql`
    update chats set unread = jsonb_set(unread, ${[caller.uid]}::text[], '0'::jsonb) where id = ${input.chatId}`;
  return { ok: true };
}
