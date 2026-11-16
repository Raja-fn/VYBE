import { requestBookingLogic } from '../../src/handlers/booking';
import { deleteAccountLogic } from '../../src/handlers/account';
import { startChatLogic } from '../../src/handlers/chat';
import type { AuthAdmin } from '../../src/services/auth/authAdmin';
import { addPerson, addVenue, connect, expectAppError, googleCaller, makeDeps, People, reset } from './helpers';

const NOW = new Date('2026-11-10T10:00:00Z');
const sql = connect();
let people: People;
let deletedFiles: [string, string[]][];

/** Stands in for Supabase Auth and Storage: deleting the account cascades like the real one. */
const admin: AuthAdmin = {
  createPhoneUser: async () => '',
  createSignInToken: async () => '',
  deleteUser: async (uid) => {
    await sql`delete from auth.users where id = ${uid}`;
  },
  deleteFiles: async (bucket, names) => {
    deletedFiles.push([bucket, names]);
  },
};

const uid = (name: string) => people.uid(name);
const deps = () => makeDeps(sql, { discoverCallsPerMinute: 1000 }, NOW);
const remove = (name: string) => deleteAccountLogic({ sql, authAdmin: admin, now: () => NOW }, googleCaller(uid(name)));

beforeEach(async () => {
  await reset(sql);
  people = new People();
  deletedFiles = [];
  await addPerson(sql, { uid: uid('aarav'), name: 'aarav', gender: 'man', at: { lat: 19.0596, lng: 72.8295 }, locatedAt: NOW });
  await addPerson(sql, {
    uid: uid('neha'),
    name: 'neha',
    gender: 'woman',
    at: { lat: 19.062, lng: 72.833 },
    locatedAt: NOW,
    companion: { planTypes: ['coffee'], weekly: [{ weekday: 2, start: '16:00', end: '20:00' }] },
  });
  await addVenue(sql, { id: 'cafe', ownerUid: uid('owner'), name: 'Cafe', at: { lat: 19.0545, lng: 72.834 }, planTypes: ['coffee'] }, [
    { id: 's1', dayKey: '2026-11-10', startAt: new Date('2026-11-10T17:00:00+05:30'), endAt: new Date('2026-11-10T18:00:00+05:30') },
  ]);
});

describe('deleteAccount', () => {
  it('cancels open bookings, frees the table, closes chats, deletes files and every personal row', async () => {
    await startChatLogic(deps(), googleCaller(uid('aarav')), { companionUid: uid('neha') });
    const { bookingId } = await requestBookingLogic(deps(), googleCaller(uid('aarav')), {
      requestId: 'deletecase1',
      companionUid: uid('neha'),
      venueId: 'cafe',
      slotId: 's1',
      planType: 'coffee',
      kind: 'scheduled',
    });
    await sql`insert into storage.objects (bucket_id, name) values ('verification', ${`${uid('aarav')}/selfie.jpg`})`;

    await expect(remove('aarav')).resolves.toEqual({ deleted: true });

    const [booking] = await sql`select status, status_reason, seeker_name from bookings where id = ${bookingId}`;
    expect(booking).toEqual({ status: 'cancelled', status_reason: 'account_deleted', seeker_name: 'aarav' });
    expect((await sql`select booked from venue_slots where id = 's1'`)[0].booked).toBe(0);
    expect((await sql`select status from chats`)[0].status).toBe('closed_deleted');
    expect(deletedFiles).toContainEqual(['verification', [`${uid('aarav')}/selfie.jpg`]]);
    for (const table of ['users', 'private_profiles', 'preferences', 'user_locations', 'credit_accounts', 'credit_ledger', 'subscriptions']) {
      const key = table === 'users' || table === 'private_profiles' ? 'id' : 'uid';
      expect(await sql`select 1 from ${sql(table)} where ${sql(key)} = ${uid('aarav')}`).toHaveLength(0);
    }
    // The other person keeps their account.
    expect(await sql`select 1 from users where id = ${uid('neha')}`).toHaveLength(1);
  });

  it('a deleted companion disappears from discovery', async () => {
    await remove('neha');
    expect(await sql`select 1 from companion_index`).toHaveLength(0);
  });

  it('venue partners are closed by support, not from the app', async () => {
    await expectAppError(remove('owner'), 'invalid_input');
  });
});
