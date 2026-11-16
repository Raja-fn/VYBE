// Login on the emulator, exactly as the app does it.
//
// Google (the login in use): emulator builds sign in with "test Google
// accounts" — the Auth emulator accepts an unsigned Google ID token. Seeded
// people are <first name>@findx.test (see functions/seed/seed.ts).
//
// Phone OTP (switched off for now, `phoneLoginEnabled`): requestLoginOtp →
// code from the emulator's SMS inbox → verifyLoginOtp → sign in with the token.

const PROJECT = 'demo-findx';
const HOST = process.env.EMULATOR_HOST ?? '127.0.0.1';
const AUTH = `http://${HOST}:9099`;
const FIRESTORE = `http://${HOST}:8080/v1/projects/${PROJECT}/databases/(default)/documents`;
const FUNCTIONS = `http://${HOST}:5001/${PROJECT}/asia-south1`;
const API_KEY = 'demo-api-key';
const OWNER = { Authorization: 'Bearer owner' };

const post = async (url, body, headers = {}) =>
  (await fetch(url, { method: 'POST', headers: { 'Content-Type': 'application/json', ...headers }, body: JSON.stringify(body) })).json();

/** Calls a Cloud Function without signing in (the login functions). */
export const callSignedOut = (name, data) => post(`${FUNCTIONS}/${name}`, { data });

/** Clears this number's last code and the login limits, so scripts can run again and again. */
export async function resetLoginLimits(phone) {
  await fetch(`${FIRESTORE}/otpChallenges/${encodeURIComponent(phone)}`, { method: 'DELETE', headers: OWNER });
  const limits = await (await fetch(`${FIRESTORE}/rateLimits?pageSize=300`, { headers: OWNER })).json();
  for (const doc of limits.documents ?? []) {
    if (doc.name.split('/').at(-1).startsWith('otp_')) {
      await fetch(`http://${HOST}:8080/v1/${doc.name}`, { method: 'DELETE', headers: OWNER });
    }
  }
}

/** The code the emulator "sent" to [phone]. */
export async function emulatorCode(phone) {
  const doc = await (await fetch(`${FIRESTORE}/emulatorOtpCodes/${encodeURIComponent(phone)}`, { headers: OWNER })).json();
  return doc.fields?.code?.stringValue;
}

/** Exchanges the one-time token from verifyLoginOtp for an ID token. */
export const exchangeToken = (token) =>
  post(`${AUTH}/identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key=${API_KEY}`, { token, returnSecureToken: true });

/** Signs in with a test Google account and returns the sign-in response (idToken, refreshToken, localId). */
export const googleSignIn = (email) =>
  post(`${AUTH}/identitytoolkit.googleapis.com/v1/accounts:signInWithIdp?key=${API_KEY}`, {
    postBody: `id_token=${encodeURIComponent(JSON.stringify({ sub: email, email, email_verified: true }))}&providerId=google.com`,
    requestUri: 'http://localhost',
    returnIdpCredential: true,
    returnSecureToken: true,
  });

/** Signs a seeded person in with their test Google account (e.g. aarav@findx.test) and returns the ID token. */
export async function signIn(email) {
  const result = await googleSignIn(email);
  if (!result.idToken) throw new Error(`Google sign-in failed for ${email}: ${JSON.stringify(result)}`);
  return result.idToken;
}

/** Phone OTP sign-in (needs phoneLoginEnabled) for [phone]; returns the ID token. */
export async function signInWithPhone(phone) {
  await resetLoginLimits(phone);
  const sent = await callSignedOut('requestLoginOtp', { phone });
  if (sent.error) throw new Error(`requestLoginOtp failed for ${phone}: ${JSON.stringify(sent.error)}`);
  const verified = await callSignedOut('verifyLoginOtp', { phone, code: await emulatorCode(phone) });
  if (verified.error) throw new Error(`verifyLoginOtp failed for ${phone}: ${JSON.stringify(verified.error)}`);
  return (await exchangeToken(verified.result.token)).idToken;
}

/** The claims inside an ID token. */
export const claimsOf = (idToken) => JSON.parse(Buffer.from(idToken.split('.')[1], 'base64url').toString());
