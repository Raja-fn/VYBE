// End-to-end smoke test of chat, moderation, report and block against the
// running Emulator Suite with the Mumbai seed loaded, using the same HTTP
// calls the app makes. Safe to run again: it resets its own test pair
// (Alex and Sam) first, and leaves Aarav and Neha's chat open for manual tests.
//
//   firebase emulators:start --project demo-findx      (functions must be built)
//   npm --prefix functions run seed
//   node functions/scripts/smoke-chat.mjs

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
const adminDelete = async (path) => fetch(`${FIRESTORE}/${path}`, { method: 'DELETE', headers: OWNER });
const intField = (doc, name) => Number(doc.fields?.[name]?.integerValue ?? NaN);
const balanceOf = async (uid) => intField(await adminGet(`creditAccounts/${uid}`), 'balance');
const chatIdFor = (a, b) => [a, b].sort().join('_');
let clientCounter = 0;
const clientId = () => `smoke${Date.now()}${(clientCounter += 1)}`;

// ---------- Aarav and Neha: start, no double charge, send, read ----------

const aarav = await signIn('aarav@findx.test');
const neha = await signIn('neha@findx.test');
const aaravNeha = chatIdFor('s_aarav', 'c_neha');
const aaravBefore = await balanceOf('s_aarav');
check(aaravBefore >= 1, `Aarav has ${aaravBefore} credits`);

const first = await call('startChat', aarav, { companionUid: 'c_neha' });
check(first.result?.chatId === aaravNeha, 'Aarav opens a chat with Neha', first);
const expected = first.result.charged ? aaravBefore - 1 : aaravBefore;
check(first.result.balance === expected, first.result.charged ? 'starting the chat used 1 credit' : 'the chat already existed, so no charge');

const second = await call('startChat', aarav, { companionUid: 'c_neha' });
check(second.result?.charged === false && second.result.balance === expected, 'opening it again is free', second);

const sent = await call('sendMessage', aarav, { chatId: aaravNeha, text: 'Hi Neha! Coffee this weekend?', clientId: clientId() });
check(typeof sent.result?.messageId === 'string', 'Aarav sends a message', sent);

const chat = await adminGet(`chats/${aaravNeha}`);
check(intField({ fields: chat.fields?.unread?.mapValue?.fields }, 'c_neha') >= 1, 'Neha has an unread message');
const read = await call('markChatRead', neha, { chatId: aaravNeha });
check(read.result?.ok === true, 'Neha opens the chat', read);
check(intField({ fields: (await adminGet(`chats/${aaravNeha}`)).fields?.unread?.mapValue?.fields }, 'c_neha') === 0, 'her unread count is cleared');

const outsider = await call('sendMessage', await signIn('kiran@findx.test'), { chatId: aaravNeha, text: 'Hello', clientId: clientId() });
check(outsider.error?.details?.code === 'not_found', 'someone outside the chat cannot post in it', outsider);

// ---------- Alex and Sam: moderation, report, block ----------

const alexSam = chatIdFor('s_alex', 'c_sam');
await adminDelete(`blocks/s_alex_c_sam`);
await adminDelete(`blocks/c_sam_s_alex`);
await adminDelete(`chats/${alexSam}`);
await adminDelete(`moderationStrikes/s_alex`);

const alex = await signIn('alex@findx.test');
const sam = await signIn('sam@findx.test');
await call('updateMyLocation', alex, { lat: 19.07, lng: 72.832, accuracyM: 10 });
check((await balanceOf('s_alex')) >= 1, 'Alex has credits to start a chat');
const started = await call('startChat', alex, { companionUid: 'c_sam' });
check(started.result?.chatId === alexSam, 'Alex opens a chat with Sam', started);

const attempts = [
  ['call me on 98765 43210', 'a phone number'],
  ['nine eight seven six five four three two one zero', 'a phone number spelled out'],
  ['my insta is @alex.mumbai', 'a social handle'],
];
for (const [text, what] of attempts) {
  const blocked = await call('sendMessage', alex, { chatId: alexSam, text, clientId: clientId() });
  check(blocked.error?.details?.code === 'moderation_blocked', `${what} is not sent`, blocked);
}
const strikes = await adminGet('moderationStrikes/s_alex');
check(intField(strikes, 'count') === 3, 'three blocked attempts are counted', strikes);
const reportId = strikes.fields?.lastReportId?.stringValue;
const autoReport = reportId ? await adminGet(`reports/${reportId}`) : {};
check(
  autoReport.fields?.reportedUid?.stringValue === 's_alex' && autoReport.fields?.source?.stringValue === 'auto_moderation',
  'the third one files an automatic report for review',
  autoReport,
);

const report = await call('submitReport', sam, {
  reportedUid: 's_alex',
  contextType: 'chat',
  refId: alexSam,
  reason: 'asked_for_contact',
  details: 'Kept asking for my number.',
});
check(report.error === undefined, 'Sam reports Alex', report);

const block = await call('blockUser', sam, { blockedUid: 's_alex' });
check(block.error === undefined, 'Sam blocks Alex', block);
check((await adminGet(`chats/${alexSam}`)).fields?.status?.stringValue === 'closed_blocked', 'the chat is closed');

const afterBlock = await call('sendMessage', alex, { chatId: alexSam, text: 'Hello?', clientId: clientId() });
check(afterBlock.error?.details?.code === 'blocked', 'Alex can no longer send messages', afterBlock);
const reopen = await call('startChat', alex, { companionUid: 'c_sam' });
check(reopen.error !== undefined, 'Alex cannot start a new chat with Sam', reopen);

console.log('\nChat smoke test passed.');
