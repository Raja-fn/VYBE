// End-to-end smoke test of booking against the running Emulator Suite with
// the Mumbai seed loaded, using the same HTTP calls the app makes.
//
//   firebase emulators:start --project demo-findx      (functions must be built)
//   npm --prefix functions run seed
//   node functions/scripts/smoke-booking.mjs

import { signIn } from './emulatorLogin.mjs';

const PROJECT = 'demo-findx';
const HOST = process.env.EMULATOR_HOST ?? '127.0.0.1';
const FIRESTORE = `http://${HOST}:8080/v1/projects/${PROJECT}/databases/(default)/documents`;
const FUNCTIONS = `http://${HOST}:5001/${PROJECT}/asia-south1`;
const BANDRA = { lat: 19.0596, lng: 72.8295, accuracyM: 10 };

let step = 0;
function check(condition, message, detail) {
  step += 1;
  if (!condition) {
    console.error(`✗ ${step}. ${message}`, JSON.stringify(detail ?? '', null, 1));
    process.exit(1);
  }
  console.log(`✓ ${step}. ${message}`);
}

const post = async (url, body, headers = {}) =>
  (await fetch(url, { method: 'POST', headers: { 'Content-Type': 'application/json', ...headers }, body: JSON.stringify(body) })).json();

const call = async (name, token, data) => post(`${FUNCTIONS}/${name}`, { data }, { Authorization: `Bearer ${token}` });
const adminGet = async (path) => (await fetch(`${FIRESTORE}/${path}`, { headers: { Authorization: 'Bearer owner' } })).json();
const intField = (doc, name) => Number(doc.fields?.[name]?.integerValue ?? NaN);

/** yyyy-MM-dd in India for `daysAhead` days from now. */
function istDayKey(daysAhead) {
  const d = new Date(Date.now() + daysAhead * 86_400_000 + 330 * 60_000);
  return d.toISOString().slice(0, 10);
}

const aarav = await signIn('aarav@findx.test');
await call('updateMyLocation', aarav, BANDRA);
const balanceBefore = intField(await adminGet('creditAccounts/s_aarav'), 'balance');
check(balanceBefore >= 10, `Aarav starts with ${balanceBefore} credits`);

const venues = await call('nearbyVenues', aarav, { planType: 'coffee', companionUid: 'c_neha' });
const list = venues.result?.venues ?? [];
check(list.length > 0 && list.every((v) => typeof v.lat === 'number' && v.rank >= 1), 'coffee spots reachable by Aarav and Neha, ranked', list);
check(!list.some((v) => v.venueId === 'v_lakeview' || v.venueId === 'v_corner_tea'), 'far-away and unverified venues excluded');

// First bookable time with Neha in the next week.
let pick = null;
for (let day = 0; day < 7 && !pick; day++) {
  for (const venue of list) {
    const slots = await call('venueSlots', aarav, { venueId: venue.venueId, dayKey: istDayKey(day), companionUid: 'c_neha' });
    const slot = (slots.result?.slots ?? []).find((s) => s.state === 'available');
    if (slot) {
      pick = { venue, slot };
      break;
    }
  }
}
check(pick !== null, 'found a time that suits Neha', pick);

const requestId = `smoke${Date.now()}`;
const booked = await call('requestBooking', aarav, {
  requestId,
  companionUid: 'c_neha',
  venueId: pick.venue.venueId,
  slotId: pick.slot.slotId,
  planType: 'coffee',
  kind: 'scheduled',
});
check(booked.result?.balance === balanceBefore - 5, 'booking charged 5 credits', booked);
const bookingId = booked.result.bookingId;

const retry = await call('requestBooking', aarav, {
  requestId,
  companionUid: 'c_neha',
  venueId: pick.venue.venueId,
  slotId: pick.slot.slotId,
  planType: 'coffee',
  kind: 'scheduled',
});
check(retry.result?.bookingId === bookingId && retry.result.balance === balanceBefore - 5, 'retrying the same request does not charge again');

const booking = await adminGet(`bookings/${bookingId}`);
check(booking.fields?.status?.stringValue === 'requested', 'booking is waiting for Neha');

const slotPath = `venues/${pick.venue.venueId}/slots/${pick.slot.slotId}`;
const bookedCount = intField(await adminGet(slotPath), 'booked');
check(bookedCount >= 1, 'a table is reserved');

// Neha is now busy at that time for anyone else.
const kabirSees = await call('venueSlots', await signIn('kiran@findx.test'), {
  venueId: pick.venue.venueId,
  dayKey: (await adminGet(slotPath)).fields.dayKey.stringValue,
  companionUid: 'c_neha',
}).catch(() => null);
check(kabirSees !== null, 'another seeker can still look at the slots');

// The same companion at the same time again: must be refused.
const poor = await call('requestBooking', aarav, {
  requestId: `poor${Date.now()}`,
  companionUid: 'c_neha',
  venueId: pick.venue.venueId,
  slotId: pick.slot.slotId,
  planType: 'coffee',
  kind: 'scheduled',
});
check(poor.error?.details?.code === 'companion_unavailable', 'Neha cannot be double-booked at the same time', poor);

const cancelled = await call('cancelBooking', aarav, { bookingId });
check(cancelled.result?.status === 'cancelled', 'Aarav cancels', cancelled);
check(intField(await adminGet(slotPath), 'booked') === bookedCount - 1, 'the table is released');
check(intField(await adminGet('creditAccounts/s_aarav'), 'balance') === balanceBefore - 5, 'no refund after cancelling');

const again = await call('cancelBooking', aarav, { bookingId });
check(again.error?.details?.code === 'invalid_input', 'a cancelled booking cannot be cancelled again', again);

console.log('\nBooking smoke test passed.');
