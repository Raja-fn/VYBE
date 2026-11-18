import {
  cancelBookingLogic,
  checkInBookingLogic,
  meetFeedbackLogic,
  nearbyVenuesLogic,
  requestBookingLogic,
  respondBookingLogic,
  venueSlotsLogic,
} from '../../src/handlers/booking';
import { AppError } from '../../src/shared/errorCodes';
import { addPerson, addVenue, connect, expectAppError, googleCaller, makeDeps, People, reset } from './helpers';

// Tuesday 2026-11-10, 15:30 IST.
const NOW = new Date('2026-11-10T10:00:00Z');
const BANDRA = { lat: 19.0596, lng: 72.8295 };
const ist = (hm: string) => new Date(`2026-11-10T${hm}:00+05:30`);

const sql = connect();
let people: People;

// Booking is free by default; most tests turn a price on to check the charging path.
const deps = (config: Parameters<typeof makeDeps>[1] = {}) =>
  makeDeps(sql, { discoverCallsPerMinute: 1000, creditCostBookSpot: 5, creditCostInstantRequest: 5, ...config }, NOW);
const uid = (name: string) => people.uid(name);
const caller = (name: string) => googleCaller(uid(name));

async function member(name: string, opts: { gender: string; at: { lat: number; lng: number }; companion?: boolean; whoCanRequest?: string }) {
  await addPerson(sql, {
    uid: uid(name),
    name,
    gender: opts.gender,
    at: opts.at,
    locatedAt: NOW,
    whoCanRequest: opts.whoCanRequest,
    companion: opts.companion ? { planTypes: ['coffee', 'walk'], weekly: [{ weekday: 2, start: '16:00', end: '20:00' }] } : undefined,
  });
}

async function venue(id: string, at: { lat: number; lng: number }, opts: { planTypes?: string[]; verified?: boolean; listed?: boolean } = {}) {
  await addVenue(
    sql,
    { id, ownerUid: uid(`${id}_owner`), name: `Venue ${id}`, at, planTypes: opts.planTypes ?? ['coffee'], verified: opts.verified, listed: opts.listed },
    [
      ['15:00', '16:00'],
      ['17:00', '18:00'],
      ['19:30', '20:30'],
    ].map(([start, end]) => ({ id: `20261110_${start.replace(':', '')}`, dayKey: '2026-11-10', startAt: ist(start), endAt: ist(end) })),
  );
}

const request = (seeker: string, overrides: Record<string, string> = {}) =>
  requestBookingLogic(deps(), caller(seeker), {
    requestId: `req${seeker}${Object.values(overrides).join('')}xx`.replace(/[^A-Za-z0-9_-]/g, '').slice(0, 40),
    companionUid: uid('neha'),
    venueId: 'cafe',
    slotId: '20261110_1700',
    planType: 'coffee',
    kind: 'scheduled',
    ...overrides,
  } as Parameters<typeof requestBookingLogic>[2]);

const slot = async (venueId = 'cafe', id = '20261110_1700') =>
  (await sql<{ booked: number; status: string; capacity: number }[]>`
    select booked, status, capacity from venue_slots where venue_id = ${venueId} and id = ${id}`)[0];
const balance = async (name: string) => (await sql<{ balance: number }[]>`select balance from credit_accounts where uid = ${uid(name)}`)[0].balance;

beforeEach(async () => {
  await reset(sql);
  people = new People();
  await member('aarav', { gender: 'man', at: BANDRA });
  await member('kabir', { gender: 'man', at: { lat: 19.061, lng: 72.831 } });
  await member('neha', { gender: 'woman', at: { lat: 19.062, lng: 72.833 }, companion: true });
  await member('riya', { gender: 'woman', at: { lat: 19.055, lng: 72.827 }, companion: true, whoCanRequest: 'women' });
  await venue('cafe', { lat: 19.0545, lng: 72.834 });
  await venue('park', { lat: 19.065, lng: 72.823 }, { planTypes: ['walk'] });
  await venue('pending', { lat: 19.06, lng: 72.83 }, { verified: false, listed: false });
  await venue('powai', { lat: 19.119, lng: 72.907 });
});

describe('nearbyVenues', () => {
  it('lists verified, listed venues within 5 km, ranked, with public coordinates', async () => {
    const { venues } = await nearbyVenuesLogic(deps(), caller('aarav'), {});
    expect(venues.map((v) => v.venueId).sort()).toEqual(['cafe', 'park']);
    expect(venues.map((v) => v.rank)).toEqual([1, 2]);
    expect(venues[0]).toEqual(expect.objectContaining({ lat: expect.any(Number), lng: expect.any(Number), perk: '10% off for VYBE meetups' }));
    expect(['hot', 'busy', 'quiet']).toContain(venues[0].popularityLabel);
  });

  it('filters by plan', async () => {
    const { venues } = await nearbyVenuesLogic(deps(), caller('aarav'), { planType: 'walk' });
    expect(venues.map((v) => v.venueId)).toEqual(['park']);
  });

  it('refuses a companion the seeker cannot see', async () => {
    await expectAppError(nearbyVenuesLogic(deps(), caller('aarav'), { companionUid: uid('riya') }), 'not_found');
  });
});

describe('venueSlots', () => {
  it('marks past, outside-hours and available slots', async () => {
    const { slots } = await venueSlotsLogic(deps(), caller('aarav'), { venueId: 'cafe', dayKey: '2026-11-10', companionUid: uid('neha') });
    expect(slots.map((s) => [s.slotId, s.state])).toEqual([
      ['20261110_1500', 'past'],
      ['20261110_1700', 'available'],
      ['20261110_1930', 'companion_unavailable'],
    ]);
  });

  it('shows the companion as busy once someone books them', async () => {
    await request('kabir');
    const { slots } = await venueSlotsLogic(deps(), caller('aarav'), { venueId: 'cafe', dayKey: '2026-11-10', companionUid: uid('neha') });
    expect(slots[1].state).toBe('companion_unavailable');
  });

  it('refuses venues beyond 5 km', async () => {
    await expectAppError(venueSlotsLogic(deps(), caller('aarav'), { venueId: 'powai', dayKey: '2026-11-10', companionUid: uid('neha') }), 'not_found');
  });
});

describe('requestBooking', () => {
  it('charges 5 credits, reserves a table and creates the request', async () => {
    const result = await request('aarav');
    expect(result.balance).toBe(15);
    const [booking] = await sql`select * from bookings where id = ${result.bookingId}`;
    expect(booking).toMatchObject({
      seeker_uid: uid('aarav'),
      companion_uid: uid('neha'),
      companion_name: 'neha',
      venue_name: 'Venue cafe',
      status: 'requested',
      credit_cost: 5,
      kind: 'scheduled',
      participants: [uid('aarav'), uid('neha')],
      day_key: '2026-11-10',
    });
    expect((await slot()).booked).toBe(1);
    const [ledger] = await sql`select * from credit_ledger where id = ${`${result.bookingId}_charge`}`;
    expect(ledger).toMatchObject({ uid: uid('aarav'), delta: -5, balance_after: 15, reason: 'booking' });
  });

  it('is free by default: no credits needed, nothing charged', async () => {
    await sql`update credit_accounts set balance = 0 where uid = ${uid('aarav')}`;
    const result = await requestBookingLogic(makeDeps(sql, { discoverCallsPerMinute: 1000 }, NOW), caller('aarav'), {
      requestId: 'reqfreexx',
      companionUid: uid('neha'),
      venueId: 'cafe',
      slotId: '20261110_1700',
      planType: 'coffee',
      kind: 'scheduled',
    });
    expect(result.balance).toBe(0);
    const [booking] = await sql`select status, credit_cost, charge_ledger_id from bookings where id = ${result.bookingId}`;
    expect(booking).toEqual({ status: 'requested', credit_cost: 0, charge_ledger_id: null });
    expect(await sql`select 1 from credit_ledger where ref_id = ${result.bookingId}`).toHaveLength(0);
    expect((await slot()).booked).toBe(1);
  });

  it('instant requests are recorded as such', async () => {
    const result = await request('aarav', { kind: 'instant' });
    const [ledger] = await sql`select reason from credit_ledger where id = ${`${result.bookingId}_charge`}`;
    expect(ledger.reason).toBe('instant_request');
  });

  it('a retry with the same request id never charges twice', async () => {
    const first = await request('aarav');
    const second = await request('aarav');
    expect(second).toEqual(first);
    expect(await balance('aarav')).toBe(15);
    expect((await slot()).booked).toBe(1);
  });

  it('two retries at the same moment still charge once', async () => {
    const results = await Promise.all([request('aarav'), request('aarav')]);
    expect(results[0].bookingId).toBe(results[1].bookingId);
    expect(await balance('aarav')).toBe(15);
    expect((await slot()).booked).toBe(1);
  });

  it('refuses when credits are short', async () => {
    await sql`update credit_accounts set balance = 4 where uid = ${uid('aarav')}`;
    await expectAppError(request('aarav'), 'insufficient_credits');
    expect((await slot()).booked).toBe(0);
  });

  it('never double-books the last table, even when two people race for it', async () => {
    await sql`update venue_slots set capacity = 1 where venue_id = 'cafe' and id = '20261110_1700'`;
    await member('sam', { gender: 'non_binary', at: { lat: 19.063, lng: 72.832 }, companion: true });
    const results = await Promise.allSettled([request('aarav'), request('kabir', { companionUid: uid('sam') })]);
    expect(results.filter((r) => r.status === 'fulfilled')).toHaveLength(1);
    const rejected = results.find((r) => r.status === 'rejected') as PromiseRejectedResult;
    expect((rejected.reason as AppError).code).toBe('slot_full');
    expect(await slot()).toMatchObject({ booked: 1, status: 'full' });
  });

  it('a companion cannot be booked twice for the same time, even in a race', async () => {
    await sql`update venues set plan_types = '{coffee}' where id = 'park'`;
    const results = await Promise.allSettled([request('kabir'), request('aarav', { venueId: 'park' })]);
    expect(results.filter((r) => r.status === 'fulfilled')).toHaveLength(1);
    await expectAppError(request('aarav'), 'companion_unavailable');
  });

  it("refuses outside the companion's hours, plans the venue does not offer, hidden companions and far venues", async () => {
    await expectAppError(request('aarav', { slotId: '20261110_1930' }), 'companion_unavailable');
    await expectAppError(request('aarav', { planType: 'walk' }), 'invalid_input');
    await expectAppError(request('aarav', { companionUid: uid('riya') }), 'not_found');
    await expectAppError(request('aarav', { venueId: 'powai' }), 'not_found');
    await expectAppError(request('aarav', { venueId: 'pending' }), 'not_found');
    await expectAppError(request('aarav', { slotId: '20261110_1500' }), 'invalid_input');
  });
});

describe('cancelBooking', () => {
  it('frees the table and does not refund credits', async () => {
    await sql`update venue_slots set capacity = 1 where venue_id = 'cafe' and id = '20261110_1700'`;
    const { bookingId } = await request('aarav');
    expect((await slot()).status).toBe('full');

    await cancelBookingLogic(deps(), caller('aarav'), { bookingId });
    const [booking] = await sql`select status, status_reason, cancelled_by from bookings where id = ${bookingId}`;
    expect(booking).toEqual({ status: 'cancelled', status_reason: 'seeker_cancelled', cancelled_by: uid('aarav') });
    expect(await slot()).toMatchObject({ booked: 0, status: 'open' });
    expect(await balance('aarav')).toBe(15);
  });

  it('only the two people can cancel, and only once', async () => {
    const { bookingId } = await request('aarav');
    await expectAppError(cancelBookingLogic(deps(), caller('kabir'), { bookingId }), 'not_found');
    await cancelBookingLogic(deps(), caller('aarav'), { bookingId });
    await expectAppError(cancelBookingLogic(deps(), caller('aarav'), { bookingId }), 'invalid_input');
  });

  it('the invited person can cancel too', async () => {
    const { bookingId } = await request('aarav');
    await cancelBookingLogic(deps(), caller('neha'), { bookingId });
    const [booking] = await sql`select status, status_reason, cancelled_by from bookings where id = ${bookingId}`;
    expect(booking).toEqual({ status: 'cancelled', status_reason: 'companion_cancelled', cancelled_by: uid('neha') });
  });
});

// The 17:00 IST slot starts at 11:30Z.
const at = (iso: string) => (config: Parameters<typeof makeDeps>[1] = {}) =>
  makeDeps(sql, { discoverCallsPerMinute: 1000, ...config }, new Date(iso));
const statusOf = async (bookingId: string) =>
  (await sql<{ status: string; checked_in_uids: string[]; feedback_uids: string[] }[]>`
    select status, checked_in_uids, feedback_uids from bookings where id = ${bookingId}`)[0];

describe('respondBooking', () => {
  it('the invited person accepts; a retry is fine', async () => {
    const { bookingId } = await request('aarav');
    expect(await respondBookingLogic(deps(), caller('neha'), { bookingId, accept: true })).toEqual({ status: 'accepted' });
    expect(await respondBookingLogic(deps(), caller('neha'), { bookingId, accept: true })).toEqual({ status: 'accepted' });
    expect((await statusOf(bookingId)).status).toBe('accepted');
  });

  it('declining frees the table', async () => {
    await sql`update venue_slots set capacity = 1 where venue_id = 'cafe' and id = '20261110_1700'`;
    const { bookingId } = await request('aarav');
    await respondBookingLogic(deps(), caller('neha'), { bookingId, accept: false });
    expect((await statusOf(bookingId)).status).toBe('declined');
    expect(await slot()).toMatchObject({ booked: 0, status: 'open' });
    await expectAppError(respondBookingLogic(deps(), caller('neha'), { bookingId, accept: true }), 'invalid_input');
  });

  it('only the invited person can answer, and not after the start', async () => {
    const { bookingId } = await request('aarav');
    await expectAppError(respondBookingLogic(deps(), caller('aarav'), { bookingId, accept: true }), 'not_found');
    await expectAppError(respondBookingLogic(deps(), caller('kabir'), { bookingId, accept: true }), 'not_found');
    await expectAppError(respondBookingLogic(at('2026-11-10T11:31:00Z')(), caller('neha'), { bookingId, accept: true }), 'invalid_input');
  });
});

describe('checkInBooking', () => {
  it('opens 15 minutes before the start; each person checks in once', async () => {
    const { bookingId } = await request('aarav');
    await expectAppError(checkInBookingLogic(at('2026-11-10T11:20:00Z')(), caller('aarav'), { bookingId }), 'invalid_input');
    await respondBookingLogic(deps(), caller('neha'), { bookingId, accept: true });
    await expectAppError(checkInBookingLogic(at('2026-11-10T11:10:00Z')(), caller('aarav'), { bookingId }), 'invalid_input');

    await checkInBookingLogic(at('2026-11-10T11:20:00Z')(), caller('aarav'), { bookingId });
    await checkInBookingLogic(at('2026-11-10T11:21:00Z')(), caller('aarav'), { bookingId });
    await checkInBookingLogic(at('2026-11-10T11:40:00Z')(), caller('neha'), { bookingId });
    expect(await statusOf(bookingId)).toMatchObject({ status: 'checked_in', checked_in_uids: [uid('aarav'), uid('neha')] });
    await expectAppError(checkInBookingLogic(at('2026-11-10T11:41:00Z')(), caller('kabir'), { bookingId }), 'not_found');
  });

  it('closes 30 minutes after the start', async () => {
    const { bookingId } = await request('aarav');
    await respondBookingLogic(deps(), caller('neha'), { bookingId, accept: true });
    await expectAppError(checkInBookingLogic(at('2026-11-10T12:01:00Z')(), caller('aarav'), { bookingId }), 'invalid_input');
  });
});

describe('meetFeedback', () => {
  it('is private, once per person, and only after the start of a confirmed meetup', async () => {
    const { bookingId } = await request('aarav');
    const after = at('2026-11-10T13:00:00Z')();
    await expectAppError(meetFeedbackLogic(after, caller('aarav'), { bookingId, felt: 'good' }), 'invalid_input');
    await respondBookingLogic(deps(), caller('neha'), { bookingId, accept: true });
    await expectAppError(meetFeedbackLogic(deps(), caller('aarav'), { bookingId, felt: 'good' }), 'invalid_input');

    await meetFeedbackLogic(after, caller('aarav'), { bookingId, felt: 'good', note: ' Lovely ' });
    await meetFeedbackLogic(after, caller('aarav'), { bookingId, felt: 'unsafe' });
    const rows = await sql`select uid, about_uid, felt, note from meet_feedback where booking_id = ${bookingId}`;
    expect(rows).toEqual([{ uid: uid('aarav'), about_uid: uid('neha'), felt: 'good', note: 'Lovely' }]);
    expect((await statusOf(bookingId)).feedback_uids).toEqual([uid('aarav')]);
    expect(await sql`select 1 from reports`).toHaveLength(0);
    await expectAppError(meetFeedbackLogic(after, caller('kabir'), { bookingId, felt: 'good' }), 'not_found');
  });

  it('"unsafe" files a report for the safety team', async () => {
    const { bookingId } = await request('aarav');
    await respondBookingLogic(deps(), caller('neha'), { bookingId, accept: true });
    await meetFeedbackLogic(at('2026-11-10T13:00:00Z')(), caller('neha'), { bookingId, felt: 'unsafe', note: 'Kept pushing' });
    const [report] = await sql`select reporter_uid, reported_uid, context_type, context_ref_id, reason, details, source from reports`;
    expect(report).toEqual({
      reporter_uid: uid('neha'),
      reported_uid: uid('aarav'),
      context_type: 'meetup',
      context_ref_id: bookingId,
      reason: 'safety_concern',
      details: 'Kept pushing',
      source: 'feedback',
    });
  });

  it('closes two weeks after the meetup', async () => {
    const { bookingId } = await request('aarav');
    await respondBookingLogic(deps(), caller('neha'), { bookingId, accept: true });
    await expectAppError(meetFeedbackLogic(at('2026-11-25T13:00:00Z')(), caller('aarav'), { bookingId, felt: 'good' }), 'invalid_input');
  });
});
