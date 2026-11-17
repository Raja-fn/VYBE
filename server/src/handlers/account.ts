import type { AuthAdmin } from '../services/auth/authAdmin';
import type { Caller } from '../shared/callable';
import type { Db } from '../shared/db';
import { appError, ErrorCodes } from '../shared/errorCodes';
import { releaseSlot } from './booking';

export interface AccountDeps {
  sql: Db;
  authAdmin: AuthAdmin;
  now: () => Date;
}

/** Buckets that hold a person's own files, in folders named after their account id. */
const PERSONAL_BUCKETS = ['photos', 'voice', 'verification', 'reels'] as const;

/**
 * Deletes the caller's account (Google Play requirement):
 * open bookings are cancelled and their tables freed, chats are closed for
 * the other person, the person's photos and ID images are deleted, then the
 * sign-in account, which removes every personal row with it.
 * Credits and plans are not refunded (Play handles subscription cancellation).
 */
export async function deleteAccountLogic(deps: AccountDeps, caller: Caller): Promise<{ deleted: true }> {
  const { sql } = deps;
  const now = deps.now();
  const [user] = await sql<{ account_type: string }[]>`select account_type from users where id = ${caller.uid}`;
  if (user?.account_type === 'venue_partner') {
    throw appError(ErrorCodes.invalidInput, 'Venue partner accounts are closed by VYBE support.');
  }

  await sql.begin(async (tx) => {
    const open = await tx<{ id: string; venue_id: string; slot_id: string }[]>`
      select id, venue_id, slot_id from bookings
      where ${caller.uid}::uuid = any (participants) and status in ('requested', 'accepted', 'checked_in')
      for update`;
    for (const booking of open) {
      await releaseSlot(tx, booking.venue_id, booking.slot_id);
      await tx`
        update bookings set status = 'cancelled', status_reason = 'account_deleted', cancelled_by = ${caller.uid},
          updated_at = ${now}
        where id = ${booking.id}`;
    }
    await tx`
      update chats set status = 'closed_deleted', closed_at = ${now}
      where ${caller.uid}::uuid = any (participants) and status = 'open'`;
  });

  for (const bucket of PERSONAL_BUCKETS) {
    const files = await sql<{ name: string }[]>`
      select name from storage.objects where bucket_id = ${bucket} and name like ${`${caller.uid}/%`}`;
    await deps.authAdmin.deleteFiles(bucket, files.map((f) => f.name));
  }
  await deps.authAdmin.deleteUser(caller.uid);
  return { deleted: true };
}
