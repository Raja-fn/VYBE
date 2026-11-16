import type { Db, Sql } from '../shared/db';

/** One chat per pair: the two uids, sorted. */
export const chatIdFor = (a: string, b: string) => [a, b].sort().join('_');

/** Adds 1 to one person's unread count in a chat row's `unread` map. */
export const bumpUnread = (sql: Sql, uid: string) =>
  sql`jsonb_set(unread, ${[uid]}::text[], to_jsonb(coalesce((unread ->> ${uid})::int, 0) + 1))`;

/**
 * When a booking is requested between two people who already chat, a card
 * appears in their conversation. No chat yet: nothing to do.
 */
export async function postBookingCard(
  sql: Db,
  booking: { bookingId: string; seekerUid: string; companionUid: string; planType: string; startAt: Date; venueName: string },
  now: Date,
): Promise<void> {
  const chatId = chatIdFor(booking.seekerUid, booking.companionUid);
  const last = { type: 'booking_card', text: '', senderUid: booking.seekerUid, at: now.toISOString() };
  await sql.begin(async (tx) => {
    const [chat] = await tx<{ status: string }[]>`select status from chats where id = ${chatId} for update`;
    if (!chat || chat.status !== 'open') return;
    await tx`
      insert into messages (chat_id, id, sender_uid, type, booking_id, plan_type, start_at, venue_name, text, created_at)
      values (${chatId}, ${`booking_${booking.bookingId}`}, ${booking.seekerUid}, 'booking_card', ${booking.bookingId},
        ${booking.planType}, ${booking.startAt}, ${booking.venueName}, null, ${now})
      on conflict do nothing`;
    await tx`
      update chats set last_message = ${tx.json(last)}, last_message_at = ${now},
        unread = ${bumpUnread(tx, booking.companionUid)}
      where id = ${chatId}`;
  });
}
