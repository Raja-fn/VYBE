import { z } from 'zod';

import { uidSchema, type Caller } from '../shared/callable';
import { appError, ErrorCodes } from '../shared/errorCodes';
import { consumeRateLimit } from '../shared/rateLimit';
import { releaseSlot } from './booking';
import { chatIdFor } from './chatCards';
import type { Deps } from './deps';

export const REPORT_REASONS = [
  'inappropriate_messages',
  'asked_for_contact',
  'harassment',
  'fake_profile',
  'safety_concern',
  'other',
] as const;

// ---------- submitReport ----------

export const submitReportInput = z.object({
  reportedUid: uidSchema,
  contextType: z.enum(['profile', 'chat', 'booking', 'meetup']),
  refId: z.string().min(1).nullable().optional(),
  reason: z.enum(REPORT_REASONS),
  details: z.string().optional(),
});

/** Files a report for the admin queue. Rate-limited per person per day. */
export async function submitReportLogic(
  deps: Deps,
  caller: Caller,
  input: z.infer<typeof submitReportInput>,
): Promise<{ reportId: string }> {
  const { sql, config } = deps;
  const now = deps.now();
  if (input.reportedUid === caller.uid) throw appError(ErrorCodes.invalidInput, 'You cannot report yourself.');
  const details = (input.details ?? '').trim();
  if (details.length > config.reportDetailsMaxLength) throw appError(ErrorCodes.invalidInput, 'Details are too long.');
  await consumeRateLimit(sql, `${caller.uid}_reports`, config.reportsPerDay, 86_400_000, now);

  const [report] = await sql<{ id: string }[]>`
    insert into reports (reporter_uid, reported_uid, context_type, context_ref_id, reason, details, source, status, created_at)
    values (${caller.uid}, ${input.reportedUid}, ${input.contextType}, ${input.refId ?? null}, ${input.reason},
      ${details || null}, 'user', 'open', ${now})
    returning id`;
  return { reportId: report.id };
}

// ---------- blockUser ----------

export const blockUserInput = z.object({ blockedUid: uidSchema });

/**
 * Blocks someone. From then on neither person sees the other anywhere
 * (discovery, profiles, chat, booking). Their chat is closed and open
 * bookings between them are cancelled (tables released; no refunds).
 */
export async function blockUserLogic(
  deps: Deps,
  caller: Caller,
  input: z.infer<typeof blockUserInput>,
): Promise<{ cancelledBookings: number }> {
  const now = deps.now();
  const other = input.blockedUid;
  if (other === caller.uid) throw appError(ErrorCodes.invalidInput, 'You cannot block yourself.');
  const [exists] = await deps.sql`select 1 from users where id = ${other}`;
  if (!exists) throw appError(ErrorCodes.notFound, 'This person is not available.');

  return deps.sql.begin(async (tx) => {
    await tx`
      insert into blocks (blocker_uid, blocked_uid, created_at) values (${caller.uid}, ${other}, ${now})
      on conflict do nothing`;
    await tx`update chats set status = 'closed_blocked', closed_at = ${now} where id = ${chatIdFor(caller.uid, other)}`;

    const between = await tx<{ id: string; venue_id: string; slot_id: string }[]>`
      select id, venue_id, slot_id from bookings
      where participants @> ${[caller.uid, other]}::uuid[] and status in ('requested', 'accepted')
      for update`;
    for (const booking of between) {
      await releaseSlot(tx, booking.venue_id, booking.slot_id);
      await tx`
        update bookings set status = 'cancelled', status_reason = 'blocked', cancelled_by = ${caller.uid}, updated_at = ${now}
        where id = ${booking.id}`;
    }
    return { cancelledBookings: between.length };
  });
}
