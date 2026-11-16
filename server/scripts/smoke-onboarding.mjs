// End-to-end smoke test of onboarding against the running Emulator Suite,
// using the same HTTP paths the app uses (Auth, callable Functions, Storage).
//
//   firebase emulators:start --project demo-findx      (functions must be built)
//   node functions/scripts/smoke-onboarding.mjs
//
// Exits non-zero on the first failed step.

import { callSignedOut, claimsOf, googleSignIn } from './emulatorLogin.mjs';

const PROJECT = 'demo-findx';
const REGION = 'asia-south1';
const HOST = process.env.EMULATOR_HOST ?? '127.0.0.1';
const AUTH = `http://${HOST}:9099`;
const FUNCTIONS = `http://${HOST}:5001/${PROJECT}/${REGION}`;
const STORAGE = `http://${HOST}:9199`;
const BUCKET = `${PROJECT}.appspot.com`;
const API_KEY = 'demo-api-key';


let step = 0;

function check(condition, message, detail) {
  step += 1;
  if (!condition) {
    console.error(`✗ ${step}. ${message}`, detail ?? '');
    process.exit(1);
  }
  console.log(`✓ ${step}. ${message}`);
}

async function json(response) {
  const text = await response.text();
  try {
    return JSON.parse(text);
  } catch {
    return { raw: text };
  }
}

async function call(name, idToken, data) {
  const response = await fetch(`${FUNCTIONS}/${name}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${idToken}` },
    body: JSON.stringify({ data }),
  });
  return { status: response.status, body: await json(response) };
}

async function upload(path, idToken, bytes, contentType = 'image/jpeg') {
  const response = await fetch(`${STORAGE}/v0/b/${BUCKET}/o?name=${encodeURIComponent(path)}`, {
    method: 'POST',
    headers: { 'Content-Type': contentType, Authorization: `Firebase ${idToken}` },
    body: bytes,
  });
  return response.status;
}

// 1. A new person signs in with Google (a test Google account on the emulator).
const email = `new${Date.now()}@example.com`;
const signedIn = await googleSignIn(email);
check(typeof signedIn.idToken === 'string', `signed in with Google as ${email}`, signedIn);
const first = claimsOf(signedIn.idToken);
check(first.email === email && first.email_verified === true && first.firebase?.sign_in_provider === 'google.com', 'the ID token carries the verified Google email', first);

// Phone login is switched off for now: no SMS can be requested.
const phoneOff = await callSignedOut('requestLoginOtp', { phone: '+919876543210' });
check(phoneOff.error?.details?.code === 'invalid_input', 'phone codes are refused while phone login is off', phoneOff);
let idToken = signedIn.idToken;

// 2. Verification is refused before the account exists.
const early = await call('startVerification', idToken, { step: 'selfie' });
check(early.status !== 200 && early.body.error?.details?.code === 'not_found', 'verification refused before accepting rules', early);

// 3. Accept rules -> account with 20 credits.
const accepted = await call('acceptRules', idToken, { rulesVersion: 1, ageConfirmed: true });
check(accepted.status === 200 && accepted.body.result?.created === true, 'acceptRules created the account', accepted);
const again = await call('acceptRules', idToken, { rulesVersion: 1, ageConfirmed: true });
check(again.body.result?.created === false, 'acceptRules is idempotent', again);

// 4. Selfie: start, upload (Storage rules), submit.
const selfie = await call('startVerification', idToken, { step: 'selfie' });
check(selfie.status === 200 && selfie.body.result?.uploadPath, 'selfie session started', selfie);
const notUploaded = await call('submitVerification', idToken, { sessionId: selfie.body.result.sessionId });
check(notUploaded.body.error?.details?.code === 'invalid_input', 'submit refused before the photo is uploaded', notUploaded);

const jpeg = new Uint8Array([0xff, 0xd8, 0xff, 0xe0, 0x00, 0x10, 0x4a, 0x46, 0x49, 0x46, 0xff, 0xd9]);
const badType = await upload(selfie.body.result.uploadPath, idToken, jpeg, 'text/plain');
check(badType === 403, 'Storage rules reject a non-image upload', badType);
const uploaded = await upload(selfie.body.result.uploadPath, idToken, jpeg);
check(uploaded === 200, 'selfie uploaded to the session path', uploaded);
const otherUser = await upload(`verification/someone-else/x.jpg`, idToken, jpeg);
check(otherUser === 403, "Storage rules block uploading into another user's folder", otherUser);

const selfieResult = await call('submitVerification', idToken, { sessionId: selfie.body.result.sessionId });
check(selfieResult.body.result?.stepStatus === 'approved', 'selfie approved by the fake provider', selfieResult);

// 5. ID check.
const noType = await call('startVerification', idToken, { step: 'id' });
check(noType.body.error?.details?.code === 'invalid_input', 'ID step needs a document type', noType);
const id = await call('startVerification', idToken, { step: 'id', documentType: 'aadhaar' });
check(id.status === 200, 'ID session started', id);
check((await upload(id.body.result.uploadPath, idToken, jpeg)) === 200, 'ID photo uploaded');
const idResult = await call('submitVerification', idToken, { sessionId: id.body.result.sessionId });
check(idResult.body.result?.verificationStatus === 'approved', 'account fully verified', idResult);

// 6. The refreshed token carries the verified claim.
const refreshed = await json(
  await fetch(`${AUTH}/securetoken.googleapis.com/v1/token?key=${API_KEY}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: `grant_type=refresh_token&refresh_token=${signedIn.refreshToken}`,
  }),
);
idToken = refreshed.id_token;
const claims = JSON.parse(Buffer.from(idToken.split('.')[1], 'base64url').toString());
check(claims.verified === true && claims.accountType === 'member', 'refreshed token has verified=true', claims);

console.log(`\nOnboarding smoke test passed for ${email} (uid ${claims.user_id}).`);
