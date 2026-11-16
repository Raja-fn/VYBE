// End-to-end smoke test of credits, plans and store refunds against the
// running Emulator Suite with the Mumbai seed loaded, using the same HTTP
// calls the app makes (the app's test store sends `fake-` receipts).
// Safe to run again: it resets Kiran's plan first.
//
//   firebase emulators:start --project demo-findx      (functions must be built)
//   npm --prefix functions run seed
//   node functions/scripts/smoke-credits.mjs

import { signIn } from './emulatorLogin.mjs';

const PROJECT = 'demo-findx';
const HOST = process.env.EMULATOR_HOST ?? '127.0.0.1';
const FIRESTORE = `http://${HOST}:8080/v1/projects/${PROJECT}/databases/(default)/documents`;
const FUNCTIONS = `http://${HOST}:5001/${PROJECT}/asia-south1`;
const OWNER = { Authorization: 'Bearer owner' };

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
const adminGet = async (path) => (await fetch(`${FIRESTORE}/${path}`, { headers: OWNER })).json();
const balanceOf = async (uid) => Number((await adminGet(`creditAccounts/${uid}`)).fields?.balance?.integerValue ?? NaN);
const tierOf = async (uid) => (await adminGet(`subscriptions/${uid}`)).fields?.tier?.stringValue ?? 'free';
const token = (name) => `fake-t${Date.now()}-${name}${Math.random().toString(36).slice(2, 8)}`;
const buy = (idToken, productId, purchaseToken) => call('verifyPurchase', idToken, { platform: 'android', productId, purchaseToken });

await fetch(`${FIRESTORE}/subscriptions/s_kiran`, { method: 'DELETE', headers: OWNER });
const kiran = await signIn('kiran@findx.test');
const start = await balanceOf('s_kiran');
check(Number.isFinite(start), `Kiran starts with ${start} credits on Free`);

// Top-up pack.
const packToken = token('pack');
const pack = await buy(kiran, 'vybe_credits_10', packToken);
check(pack.result?.status === 'granted' && pack.result.creditsAdded === 10 && pack.result.balance === start + 10, 'a 10-credit pack adds 10', pack);
const again = await buy(kiran, 'vybe_credits_10', packToken);
check(again.result?.status === 'already_granted' && (await balanceOf('s_kiran')) === start + 10, 'sending the same receipt again adds nothing', again);

const forged = await buy(kiran, 'vybe_credits_75', 'not-a-store-receipt');
check(forged.error?.details?.code === 'purchase_invalid', 'a forged receipt is refused', forged);
const unknown = await buy(kiran, 'vybe_credits_9999', token('x'));
check(unknown.error?.details?.code === 'invalid_input', 'an unknown product is refused', unknown);

const alex = await signIn('alex@findx.test');
const stolen = await buy(alex, 'vybe_credits_10', packToken);
check(stolen.error?.details?.code === 'purchase_invalid', "someone else cannot use Kiran's receipt", stolen);

// Plans.
const plus = await buy(kiran, 'vybe_plus_monthly', token('plus'));
check(plus.result?.status === 'granted' && plus.result.creditsAdded === 100 && plus.result.tier === 'plus', 'Plus adds 100 credits', plus);
check((await tierOf('s_kiran')) === 'plus', 'Kiran is on Plus');

const premium = await buy(kiran, 'vybe_premium_monthly', token('premium'));
check(premium.result?.creditsAdded === 200 && premium.result.tier === 'premium', 'upgrading to Premium adds 200 straight away', premium);

const down = await buy(kiran, 'vybe_plus_monthly', token('down'));
check(down.result?.status === 'at_renewal' && down.result.creditsAdded === 0, 'going back to Plus waits for the renewal', down);
const sub = await adminGet('subscriptions/s_kiran');
check(sub.fields?.tier?.stringValue === 'premium' && sub.fields?.pendingTier?.stringValue === 'plus', 'Premium stays until then, Plus is waiting');

const afterPlans = await balanceOf('s_kiran');
check(afterPlans === start + 310, `balance is ${afterPlans} (start + 10 + 100 + 200)`);

// Store refund of the pack.
const refund = await post(`${FUNCTIONS}/storeNotification?platform=android`, {
  fake: { type: 'refund', storeTransactionId: `fake-txn-${packToken}` },
});
check(refund.outcome === 'refunded', 'the store reports the pack refunded', refund);
check((await balanceOf('s_kiran')) === afterPlans - 10, 'its 10 credits are taken back');
const repeat = await post(`${FUNCTIONS}/storeNotification?platform=android`, {
  fake: { type: 'refund', storeTransactionId: `fake-txn-${packToken}` },
});
check(repeat.outcome === 'ignored' && (await balanceOf('s_kiran')) === afterPlans - 10, 'a repeated notification changes nothing');

const forgedNote = await fetch(`${FUNCTIONS}/storeNotification?platform=android`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ hello: 'world' }),
});
check(forgedNote.status === 401, 'a notification that is not from the store is rejected');

const ledger = await post(`${FIRESTORE}:runQuery`, {
  structuredQuery: {
    from: [{ collectionId: 'creditLedger' }],
    where: { fieldFilter: { field: { fieldPath: 'refId' }, op: 'EQUAL', value: { stringValue: `android_fake-txn-${packToken}` } } },
  },
}, OWNER);
const reasons = ledger.flatMap((r) => (r.document ? [r.document.fields.reason.stringValue] : [])).sort();
check(JSON.stringify(reasons) === JSON.stringify(['purchase', 'purchase_reversal']), 'the ledger shows the purchase and its reversal', reasons);

console.log('\nCredits smoke test passed.');
