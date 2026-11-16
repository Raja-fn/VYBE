// End-to-end smoke test of discovery against the running Emulator Suite with
// the Mumbai seed loaded, using the same HTTP calls the app makes.
//
//   firebase emulators:start --project demo-findx      (functions must be built)
//   npm --prefix functions run seed
//   node functions/scripts/smoke-discovery.mjs

import { signIn } from './emulatorLogin.mjs';

const PROJECT = 'demo-findx';
const HOST = process.env.EMULATOR_HOST ?? '127.0.0.1';
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
const names = (result) => (result.result?.companions ?? []).map((c) => c.uid).sort();

// Aarav: man, "Show me: Everyone".
const aarav = await signIn('aarav@findx.test');
check(typeof aarav === 'string', 'signed in as the seeded seeker Aarav');
const moved = await call('updateMyLocation', aarav, BANDRA);
check(moved.result?.ok === true, 'location sent', moved);

const coffee = await call('discoverCompanions', aarav, { planType: 'coffee' });
check(
  JSON.stringify(names(coffee)) === JSON.stringify(['c_ira', 'c_neha', 'c_sam']),
  'coffee: Neha, Sam (non-binary) and Ira (prefer not to say); not Riya (women only) and not Meera (9 km away)',
  names(coffee),
);

const all = await call('discoverCompanions', aarav, { planType: null });
check(!names(all).includes('c_arjun') && !names(all).includes('c_riya'), '"women only" companions hidden from a man', names(all));
check(names(all).includes('c_dev'), '"men only" companion visible to a man', names(all));
check(!names(all).includes('c_far'), 'companion outside 5 km never returned', names(all));

const text = JSON.stringify(all);
check(!/"lat"|"lng"|geohash/.test(text), 'no coordinates or geohashes in the response');
check(
  all.result.companions.every((c) => Number.isInteger(c.distanceKm) && c.distanceKm >= 1),
  'distances are whole km, at least 1',
);
const neha = all.result.companions.find((c) => c.uid === 'c_neha');
check(neha.gender === null && neha.freeNowUntil !== null, 'Neha: gender hidden (she did not choose to show it), free now');
check(all.result.companions.every((c) => c.spotsNearby >= 0), 'spots nearby counted');

const free = await call('freeNowCompanions', aarav, { window: 'next_2h' });
check(names(free).includes('c_neha') && !names(free).includes('c_sam'), 'next 2 hrs lists only companions who are free now', names(free));

const profile = await call('getCompanionProfile', aarav, { uid: 'c_sam' });
check(profile.result?.displayName === 'Sam', 'profile opens for a visible companion', profile);
const hidden = await call('getCompanionProfile', aarav, { uid: 'c_riya' });
check(hidden.error?.details?.code === 'not_found', 'profile of a hidden companion is "not found"', hidden);
const far = await call('getCompanionProfile', aarav, { uid: 'c_far' });
check(far.error?.details?.code === 'not_found', 'profile of a far-away companion is "not found"', far);

// Diya: woman, "Show me: Men".
const diya = await signIn('diya@findx.test');
await call('updateMyLocation', diya, { lat: 19.064, lng: 72.835, accuracyM: 10 });
const diyaAll = await call('discoverCompanions', diya, { planType: null });
check(
  JSON.stringify(names(diyaAll)) === JSON.stringify(['c_arjun', 'c_kabir']),
  'Diya (Show me: Men) sees Arjun (women only accepts her) and Kabir; not Dev (men only)',
  names(diyaAll),
);

// Unverified account is refused.
const tara = await signIn('tara@findx.test');
const refused = await call('discoverCompanions', tara, { planType: null });
check(refused.error?.details?.code === 'not_verified', 'unverified account cannot discover', refused);

console.log('\nDiscovery smoke test passed.');
