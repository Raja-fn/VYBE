import type { z } from 'zod';

import { loadAppConfig, type AppConfig } from '../config/appConfig';
import { account, admin, adminManage, booking, chat, discovery, onboarding, phoneLogin, purchases, push, reels, safety } from '../handlers';
import type { Deps } from '../handlers/deps';
import type { AuthAdmin } from '../services/auth/authAdmin';
import type { GoogleIdTokenVerifier } from '../services/auth/googleIdToken';
import type { Services } from '../services/factory';
import type { OtpSender } from '../services/otp/otpSender';
import { parseInput, type Caller } from '../shared/callable';
import type { Db } from '../shared/db';
import { createAdminSession, readAdminSession } from '../shared/adminSession';
import { sameSecret } from '../shared/constantTime';
import { AppError, httpStatusFor } from '../shared/errorCodes';
import { consumeRateLimit } from '../shared/rateLimit';

/** What the router needs from the outside world. Tests pass fakes. */
export interface ApiContext {
  sql: Db;
  /** The signed-in person behind an access token, or null when it is not valid. */
  resolveCaller(accessToken: string): Promise<Caller | null>;
  services(config: AppConfig): Services;
  authAdmin: AuthAdmin;
  otpSender(config: AppConfig): OtpSender;
  /** Shared secret the scheduled renewal job sends in `x-cron-secret`. */
  cronSecret: string | undefined;
  /** Signs admin panel sessions (FINDX_ADMIN_SECRET). Unset: the admin panel is off. */
  adminSecret?: string | undefined;
  /** Google accounts allowed into the admin panel (FINDX_ADMIN_EMAILS). Empty: nobody. */
  adminEmails?: readonly string[];
  /** Checks the Google Sign-In token the admin panel sends to `adminSignIn`. */
  verifyGoogleIdToken?: GoogleIdTokenVerifier;
  /** Shared admin panel password (FINDX_ADMIN_PASSWORD), used with a listed email. Unset: password sign-in is off. */
  adminPassword?: string | undefined;
  /** A link to a private storage file ("bucket/name") that works for [seconds]. */
  signStorageUrl?(path: string, seconds: number): Promise<string>;
  now?: () => Date;
}

type AdminAction = { schema: z.ZodType; run: (deps: admin.AdminDeps, input: never) => Promise<unknown> };
const m = adminManage;

/** Actions for the VYBE team's admin panel (site/admin/index.html), not the app. */
const adminActions: Record<string, AdminAction> = {
  adminReviewQueue: { schema: admin.adminReviewQueueInput, run: (deps) => admin.adminReviewQueueLogic(deps) },
  adminDecideVerification: { schema: admin.adminDecideVerificationInput, run: admin.adminDecideVerificationLogic },
  adminOverview: { schema: m.adminOverviewInput, run: (deps) => m.adminOverviewLogic(deps) },
  adminMembers: { schema: m.adminMembersInput, run: m.adminMembersLogic },
  adminMember: { schema: m.adminMemberInput, run: m.adminMemberLogic },
  adminSetBan: { schema: m.adminSetBanInput, run: m.adminSetBanLogic },
  adminAdjustCredits: { schema: m.adminAdjustCreditsInput, run: m.adminAdjustCreditsLogic },
  adminDeleteMember: { schema: m.adminDeleteMemberInput, run: m.adminDeleteMemberLogic },
  adminMessageMember: { schema: m.adminMessageMemberInput, run: m.adminMessageMemberLogic },
  adminBookings: { schema: m.adminBookingsInput, run: m.adminBookingsLogic },
  adminBooking: { schema: m.adminBookingInput, run: m.adminBookingLogic },
  adminCancelBooking: { schema: m.adminCancelBookingInput, run: m.adminCancelBookingLogic },
  adminVenues: { schema: m.adminVenuesInput, run: m.adminVenuesLogic },
  adminSaveVenue: { schema: m.adminSaveVenueInput, run: m.adminSaveVenueLogic },
  adminSetVenueFlags: { schema: m.adminSetVenueFlagsInput, run: m.adminSetVenueFlagsLogic },
  adminDeleteVenue: { schema: m.adminDeleteVenueInput, run: m.adminDeleteVenueLogic },
  adminReports: { schema: m.adminReportsInput, run: m.adminReportsLogic },
  adminResolveReport: { schema: m.adminResolveReportInput, run: m.adminResolveReportLogic },
  adminReels: { schema: m.adminReelsInput, run: m.adminReelsLogic },
  adminDeleteReel: { schema: m.adminDeleteReelInput, run: m.adminDeleteReelLogic },
  adminGetConfig: { schema: m.adminGetConfigInput, run: (deps) => m.adminGetConfigLogic(deps) },
  adminSaveConfig: { schema: m.adminSaveConfigInput, run: m.adminSaveConfigLogic },
  adminAudit: { schema: m.adminAuditInput, run: m.adminAuditLogic },
};

/** Refused admin sign-ins allowed per address before it is locked out for a while. */
const ADMIN_FAILURES_ALLOWED = 10;
const ADMIN_LOCKOUT_MS = 15 * 60_000;

/** The panel runs from a file or another site, so admin answers allow any origin; the session is the guard. */
const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'content-type, x-admin-session',
};

function withCors(response: Response): Response {
  const headers = new Headers(response.headers);
  for (const [key, value] of Object.entries(CORS_HEADERS)) headers.set(key, value);
  return new Response(response.body, { status: response.status, headers });
}

type SignedIn = { kind: 'user'; schema: z.ZodType; run: (deps: Deps, caller: Caller, input: never) => Promise<unknown> };

/** Every action the app can call, by name (POST /functions/v1/api/<name>). */
const signedIn: Record<string, SignedIn> = {
  acceptRules: { kind: 'user', schema: onboarding.acceptRulesInput, run: onboarding.acceptRulesLogic },
  startVerification: { kind: 'user', schema: onboarding.startVerificationInput, run: onboarding.startVerificationLogic },
  submitVerification: { kind: 'user', schema: onboarding.submitVerificationInput, run: onboarding.submitVerificationLogic },
  updateMyLocation: { kind: 'user', schema: discovery.updateMyLocationInput, run: discovery.updateMyLocationLogic },
  discoverCompanions: { kind: 'user', schema: discovery.discoverInput, run: discovery.discoverCompanionsLogic },
  freeNowCompanions: { kind: 'user', schema: discovery.freeNowInput, run: discovery.freeNowCompanionsLogic },
  getCompanionProfile: { kind: 'user', schema: discovery.profileInput, run: discovery.getCompanionProfileLogic },
  savedCompanions: {
    kind: 'user',
    schema: discovery.discoverInput,
    run: (deps, caller) => discovery.savedCompanionsLogic(deps, caller),
  },
  nearbyVenues: { kind: 'user', schema: booking.nearbyVenuesInput, run: booking.nearbyVenuesLogic },
  venueSlots: { kind: 'user', schema: booking.venueSlotsInput, run: booking.venueSlotsLogic },
  requestBooking: { kind: 'user', schema: booking.requestBookingInput, run: booking.requestBookingLogic },
  cancelBooking: { kind: 'user', schema: booking.cancelBookingInput, run: booking.cancelBookingLogic },
  respondBooking: { kind: 'user', schema: booking.respondBookingInput, run: booking.respondBookingLogic },
  checkInBooking: { kind: 'user', schema: booking.checkInBookingInput, run: booking.checkInBookingLogic },
  meetFeedback: { kind: 'user', schema: booking.meetFeedbackInput, run: booking.meetFeedbackLogic },
  startChat: { kind: 'user', schema: chat.startChatInput, run: chat.startChatLogic },
  sendMessage: { kind: 'user', schema: chat.sendMessageInput, run: chat.sendMessageLogic },
  markChatRead: { kind: 'user', schema: chat.markChatReadInput, run: chat.markChatReadLogic },
  submitReport: { kind: 'user', schema: safety.submitReportInput, run: safety.submitReportLogic },
  blockUser: { kind: 'user', schema: safety.blockUserInput, run: safety.blockUserLogic },
  verifyPurchase: { kind: 'user', schema: purchases.verifyPurchaseInput, run: purchases.verifyPurchaseLogic },
  reelFeed: { kind: 'user', schema: reels.reelFeedInput, run: reels.reelFeedLogic },
  postReel: { kind: 'user', schema: reels.postReelInput, run: reels.postReelLogic },
  deleteReel: { kind: 'user', schema: reels.deleteReelInput, run: reels.deleteReelLogic },
  registerPushToken: { kind: 'user', schema: push.registerPushTokenInput, run: push.registerPushTokenLogic },
  unregisterPushToken: { kind: 'user', schema: push.unregisterPushTokenInput, run: push.unregisterPushTokenLogic },
};

const json = (status: number, body: unknown) =>
  new Response(JSON.stringify(body), { status, headers: { 'Content-Type': 'application/json' } });

const errorResponse = (error: AppError) =>
  json(httpStatusFor[error.status], { error: { status: error.status, code: error.code, message: error.message } });

/** The action name: the last part of the path (…/api/<name>). */
export function routeName(url: string): string {
  const parts = new URL(url).pathname.split('/').filter(Boolean);
  return parts[parts.length - 1] ?? '';
}

function clientIp(req: Request): string {
  const forwarded = req.headers.get('x-forwarded-for');
  return forwarded?.split(',')[0]?.trim() || req.headers.get('cf-connecting-ip') || 'unknown';
}

async function readJson(req: Request): Promise<unknown> {
  const text = await req.text();
  if (!text) return {};
  try {
    return JSON.parse(text);
  } catch {
    throw new AppError('invalid-argument', 'The request body is not JSON.');
  }
}

/** Handles one HTTP request to the `api` Edge Function. */
export async function handleApiRequest(req: Request, ctx: ApiContext): Promise<Response> {
  const name = routeName(req.url);
  if (name in adminActions || name === 'adminSignIn') {
    if (req.method === 'OPTIONS') return new Response(null, { status: 204, headers: CORS_HEADERS });
    return withCors(await handleAdmin(name, req, ctx));
  }
  return handleAppRequest(name, req, ctx);
}

async function handleAdmin(name: string, req: Request, ctx: ApiContext): Promise<Response> {
  const now = ctx.now ?? (() => new Date());
  try {
    if (req.method !== 'POST') return json(405, { error: { status: 'invalid-argument', code: null, message: 'Use POST.' } });
    const key = ctx.adminSecret;
    const allowed = ctx.adminEmails ?? [];
    if (!key || allowed.length === 0) throw new AppError('permission-denied', 'The admin panel is not set up.');
    if (name === 'adminSignIn') return json(200, await adminSignIn(req, ctx, key, allowed, now));

    const session = readAdminSession(key, req.headers.get('x-admin-session') ?? '', allowed, now());
    if (!session) throw new AppError('unauthenticated', 'Sign in again.');
    const signStorageUrl = ctx.signStorageUrl;
    if (!signStorageUrl) throw new AppError('failed-precondition', 'Storage links are not available.');
    const action = adminActions[name];
    const config = await loadAppConfig(ctx.sql);
    const input = parseInput(action.schema, await readJson(req));
    const deps: admin.AdminDeps = {
      sql: ctx.sql,
      config,
      services: ctx.services(config),
      now,
      signUrl: signStorageUrl,
      authAdmin: ctx.authAdmin,
      actor: session.email,
    };
    return json(200, (await action.run(deps, input as never)) ?? {});
  } catch (error) {
    if (error instanceof AppError) return errorResponse(error);
    console.error(`api/${name} failed`, error instanceof Error ? `${error.name}: ${error.message}` : String(error));
    return errorResponse(new AppError('internal', 'Something went wrong.'));
  }
}

/**
 * Admin panel sign-in, by Google or by email + password. Either way only the
 * emails in FINDX_ADMIN_EMAILS get a session; the password is FINDX_ADMIN_PASSWORD.
 */
async function adminSignIn(req: Request, ctx: ApiContext, key: string, allowed: readonly string[], now: () => Date) {
  const failureKey = `admin_fail_${clientIp(req)}`;
  const [failures] = await ctx.sql<{ count: number; window_start: Date }[]>`
    select count, window_start from rate_limits where key = ${failureKey}`;
  if (failures && failures.count >= ADMIN_FAILURES_ALLOWED && now().getTime() - failures.window_start.getTime() < ADMIN_LOCKOUT_MS) {
    throw new AppError('resource-exhausted', 'Too many refused sign-ins. Try again in 15 minutes.');
  }
  const refuse = async (message: string): Promise<never> => {
    await consumeRateLimit(ctx.sql, failureKey, Number.MAX_SAFE_INTEGER, ADMIN_LOCKOUT_MS, now());
    throw new AppError('permission-denied', message);
  };
  const body = (await readJson(req)) as { idToken?: unknown; email?: unknown; password?: unknown } | null;
  const text = (value: unknown) => (typeof value === 'string' ? value : '');

  let who: { email: string; name: string } | null;
  if (body && 'password' in body) {
    const email = text(body.email).trim().toLowerCase();
    const password = text(body.password);
    const right = ctx.adminPassword ?? '';
    if (!right) throw new AppError('failed-precondition', 'Password sign-in is not set up.');
    // Both checks always run, so the answer time does not tell which one failed.
    const passwordOk = sameSecret(password, right);
    if (!passwordOk || !allowed.includes(email)) return refuse('Wrong email or password.');
    who = { email, name: email };
  } else {
    const idToken = text(body?.idToken);
    if (!ctx.verifyGoogleIdToken) throw new AppError('failed-precondition', 'Google sign-in is not set up.');
    who = idToken ? await ctx.verifyGoogleIdToken(idToken).catch(() => null) : null;
    if (!who || !allowed.includes(who.email)) {
      return refuse(who ? `${who.email} is not allowed into the admin panel.` : 'Google sign-in failed.');
    }
  }
  const { token, expiresAt } = createAdminSession(key, who.email, who.name, now());
  return { session: token, email: who.email, name: who.name, expiresAt: expiresAt.toISOString() };
}

async function handleAppRequest(name: string, req: Request, ctx: ApiContext): Promise<Response> {
  const now = ctx.now ?? (() => new Date());
  try {
    if (name === 'storeNotification') return await storeNotification(req, ctx, now);
    if (req.method !== 'POST') return json(405, { error: { status: 'invalid-argument', code: null, message: 'Use POST.' } });

    const config = await loadAppConfig(ctx.sql);
    if (name === 'renewSubscriptions') {
      if (!ctx.cronSecret || req.headers.get('x-cron-secret') !== ctx.cronSecret) {
        throw new AppError('permission-denied', 'Not allowed.');
      }
      return json(200, await purchases.renewSubscriptionsLogic({ sql: ctx.sql, config, services: ctx.services(config), now }));
    }

    const body = await readJson(req);
    if (name === 'requestLoginOtp' || name === 'verifyLoginOtp') {
      const deps = {
        sql: ctx.sql,
        authAdmin: ctx.authAdmin,
        config,
        // Checking a code never sends an SMS.
        sender: name === 'requestLoginOtp' ? ctx.otpSender(config) : { send: () => Promise.reject(new Error('No SMS here.')) },
        now,
        ip: clientIp(req),
      };
      const result =
        name === 'requestLoginOtp'
          ? await phoneLogin.requestLoginOtpLogic(deps, parseInput(phoneLogin.requestLoginOtpInput, body))
          : await phoneLogin.verifyLoginOtpLogic(deps, parseInput(phoneLogin.verifyLoginOtpInput, body));
      return json(200, result);
    }

    if (name === 'deleteAccount') {
      const token = req.headers.get('authorization')?.replace(/^Bearer\s+/i, '') ?? '';
      const caller = token ? await ctx.resolveCaller(token) : null;
      if (!caller) throw new AppError('unauthenticated', 'Sign in first.');
      return json(200, await account.deleteAccountLogic({ sql: ctx.sql, authAdmin: ctx.authAdmin, now }, caller));
    }

    const action = signedIn[name];
    if (!action) return json(404, { error: { status: 'not-found', code: null, message: 'Unknown action.' } });
    const token = req.headers.get('authorization')?.replace(/^Bearer\s+/i, '') ?? '';
    const caller = token ? await ctx.resolveCaller(token) : null;
    if (!caller) throw new AppError('unauthenticated', 'Sign in first.');
    const input = parseInput(action.schema, body);
    const result = await action.run({ sql: ctx.sql, config, services: ctx.services(config), now }, caller, input as never);
    return json(200, result ?? {});
  } catch (error) {
    if (error instanceof AppError) return errorResponse(error);
    console.error(`api/${name} failed`, error instanceof Error ? `${error.name}: ${error.message}` : String(error));
    return errorResponse(new AppError('internal', 'Something went wrong.'));
  }
}

/**
 * Store server notifications: `POST …/api/storeNotification?platform=android`
 * (Play RTDN through a Pub/Sub push subscription) or `?platform=ios`
 * (App Store Server Notifications v2). The purchase service authenticates them.
 */
async function storeNotification(req: Request, ctx: ApiContext, now: () => Date): Promise<Response> {
  const platform = new URL(req.url).searchParams.get('platform');
  if (req.method !== 'POST' || (platform !== 'android' && platform !== 'ios')) return new Response('Bad request', { status: 400 });
  const headers: Record<string, string> = {};
  req.headers.forEach((value, key) => (headers[key] = value));
  // Google Pub/Sub cannot send custom headers, so the push URL carries the shared secret.
  const queryToken = new URL(req.url).searchParams.get('token');
  if (queryToken) headers['x-findx-query-token'] = queryToken;
  const config = await loadAppConfig(ctx.sql);
  try {
    const body = await readJson(req);
    const outcome = await purchases.handleStoreNotificationLogic(
      { sql: ctx.sql, config, services: ctx.services(config), now },
      platform,
      body,
      headers,
    );
    return json(200, { outcome });
  } catch (error) {
    if (error instanceof purchases.NotificationRejected || error instanceof AppError) {
      console.warn('Store notification rejected', String(error));
      return new Response('Rejected', { status: 401 });
    }
    // 5xx makes the store retry later.
    console.error('Store notification failed', String(error));
    return new Response('Try again', { status: 500 });
  }
}
