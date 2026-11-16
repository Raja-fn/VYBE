import type { z } from 'zod';

import { loadAppConfig, type AppConfig } from '../config/appConfig';
import { account, booking, chat, discovery, onboarding, phoneLogin, purchases, safety } from '../handlers';
import type { Deps } from '../handlers/deps';
import type { AuthAdmin } from '../services/auth/authAdmin';
import type { Services } from '../services/factory';
import type { OtpSender } from '../services/otp/otpSender';
import { parseInput, type Caller } from '../shared/callable';
import type { Db } from '../shared/db';
import { AppError, httpStatusFor } from '../shared/errorCodes';

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
  now?: () => Date;
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
  startChat: { kind: 'user', schema: chat.startChatInput, run: chat.startChatLogic },
  sendMessage: { kind: 'user', schema: chat.sendMessageInput, run: chat.sendMessageLogic },
  markChatRead: { kind: 'user', schema: chat.markChatReadInput, run: chat.markChatReadLogic },
  submitReport: { kind: 'user', schema: safety.submitReportInput, run: safety.submitReportLogic },
  blockUser: { kind: 'user', schema: safety.blockUserInput, run: safety.blockUserLogic },
  verifyPurchase: { kind: 'user', schema: purchases.verifyPurchaseInput, run: purchases.verifyPurchaseLogic },
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
