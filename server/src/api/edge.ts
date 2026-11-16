/**
 * Entry point of the `api` Supabase Edge Function. Bundled by
 * `npm run build:edge` into supabase/functions/api/server.js.
 */
import postgres from 'postgres';

import { env, fakeServicesAllowed } from '../config/env';
import { SupabaseAuthAdmin } from '../services/auth/authAdmin';
import { createServices, type Services } from '../services/factory';
import { FakeOtpSender } from '../services/otp/fakeOtpSender';
import { OtpSendError, type OtpSender } from '../services/otp/otpSender';
import { RenflairOtpSender } from '../services/otp/renflairOtpSender';
import { supabaseCallerResolver } from './caller';
import { handleApiRequest, type ApiContext } from './router';

function required(name: string): string {
  const value = env(name);
  if (!value) throw new Error(`${name} is not set.`);
  return value;
}

const supabaseUrl = required('SUPABASE_URL');
// Supabase pools connections in front of Postgres; prepared statements are off for the pooler.
const sql = postgres(required('SUPABASE_DB_URL'), { prepare: false, max: 3, idle_timeout: 20 });

let services: { key: string; value: Services } | undefined;

const ctx: ApiContext = {
  sql,
  // Any project key works as the `apikey` when asking Auth who a token belongs to.
  resolveCaller: supabaseCallerResolver(supabaseUrl, env('SUPABASE_ANON_KEY') || required('SUPABASE_SERVICE_ROLE_KEY')),
  services(config) {
    const key = JSON.stringify([config.topUpPacks, config.plans, config.subscriptionPeriodDays, config.verificationSessionMinutes]);
    if (!services || services.key !== key) services = { key, value: createServices(config) };
    return services.value;
  },
  authAdmin: new SupabaseAuthAdmin(supabaseUrl, required('SUPABASE_SERVICE_ROLE_KEY')),
  otpSender(): OtpSender {
    const apiKey = env('RENFLAIR_API_KEY');
    if (apiKey) return new RenflairOtpSender(apiKey);
    if (fakeServicesAllowed()) return new FakeOtpSender();
    return { send: () => Promise.reject(new OtpSendError('RENFLAIR_API_KEY is not set.')) };
  },
  cronSecret: env('FINDX_CRON_SECRET'),
};

(globalThis as unknown as { Deno: { serve(handler: (req: Request) => Promise<Response>): void } }).Deno.serve((req) =>
  handleApiRequest(req, ctx),
);
