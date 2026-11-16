import { randomUUID } from 'node:crypto';

import postgres from 'postgres';

import { clearAppConfigCache, defaultAppConfig, type AppConfig } from '../../src/config/appConfig';
import type { Deps } from '../../src/handlers/deps';
import { createServices } from '../../src/services/factory';
import type { Caller } from '../../src/shared/callable';
import type { Db } from '../../src/shared/db';
import { AppError } from '../../src/shared/errorCodes';
import { TEST_DB_URL } from './connection';

/** A connection to the test database, closed after the file's tests. */
export function connect(): Db {
  const sql = postgres(TEST_DB_URL, { onnotice: () => {}, max: 5 });
  afterAll(() => sql.end());
  return sql;
}

/** Empties every table so each test starts from the same world. */
export async function reset(sql: Db): Promise<void> {
  clearAppConfigCache();
  const tables = await sql<{ tablename: string }[]>`
    select tablename from pg_tables where schemaname = 'public' and tablename <> 'app_config'`;
  await sql.unsafe(`truncate ${tables.map((t) => `public.${t.tablename}`).join(', ')}, auth.users, storage.objects cascade`);
  await sql`update app_config set overrides = '{}'::jsonb`;
}

/** Names to uuids, stable within one test. */
export class People {
  private readonly ids = new Map<string, string>();

  uid(name: string): string {
    let id = this.ids.get(name);
    if (!id) {
      id = randomUUID();
      this.ids.set(name, id);
    }
    return id;
  }

  name(uid: string): string {
    for (const [name, id] of this.ids) if (id === uid) return name;
    return uid;
  }

  names(list: { uid: string }[]): string[] {
    return list.map((c) => this.name(c.uid));
  }
}

/** Creates the Supabase Auth account (what signing in does). */
export async function authUser(sql: Db, uid: string, email: string | null = `${uid}@example.com`): Promise<void> {
  await sql`
    insert into auth.users (id, email, email_confirmed_at) values (${uid}, ${email}, now())
    on conflict (id) do nothing`;
}

export const googleCaller = (uid: string, email = `${uid}@example.com`): Caller => ({ uid, phoneNumber: undefined, verifiedEmail: email });
export const phoneCaller = (uid: string, phone = '+919800000000'): Caller => ({ uid, phoneNumber: phone });

export function makeDeps(sql: Db, config: Partial<AppConfig> = {}, now: Date = new Date()): Deps {
  const full = { ...defaultAppConfig, ...config };
  return { sql, config: full, services: createServices(full, true), now: () => now };
}

/** Expects an app error with this code (or, for codeless errors, this status). */
export async function expectAppError(promise: Promise<unknown>, code: string): Promise<AppError> {
  const error = await promise.then(
    () => undefined,
    (e: unknown) => e,
  );
  expect(error).toBeInstanceOf(AppError);
  const appError = error as AppError;
  expect(appError.code ?? appError.status).toBe(code);
  return appError;
}

export interface PersonSpec {
  uid: string;
  name: string;
  gender: string;
  showMe?: string;
  whoCanRequest?: string;
  age?: number;
  at?: { lat: number; lng: number };
  verified?: boolean;
  banned?: boolean;
  accountType?: 'member' | 'venue_partner';
  credits?: number;
  companion?: {
    planTypes: string[];
    freeNowUntil?: Date | null;
    weekly?: { weekday: number; start: string; end: string }[];
    isListed?: boolean;
  };
  locatedAt?: Date;
}

/** A complete member as the server would have built them (account, prefs, location, companion profile). */
export async function addPerson(sql: Db, p: PersonSpec): Promise<void> {
  await authUser(sql, p.uid);
  const verified = p.verified !== false;
  await sql`
    insert into users (id, account_type, display_name, verification_status, verification_steps, account_status, age_years)
    values (${p.uid}, ${p.accountType ?? 'member'}, ${p.name}, ${verified ? 'approved' : 'pending'},
      ${sql.json(verified ? { phone: 'approved', selfie: 'approved', id: 'approved' } : { phone: 'approved', selfie: 'not_started', id: 'not_started' })},
      ${p.banned ? 'banned' : 'active'}, ${verified ? (p.age ?? 25) : null})`;
  await sql`insert into private_profiles (id, email) values (${p.uid}, ${`${p.uid}@example.com`})`;
  await sql`insert into credit_accounts (uid, balance) values (${p.uid}, ${p.credits ?? 20})`;
  await sql`insert into subscriptions (uid) values (${p.uid})`;
  await sql`
    insert into preferences (uid, gender, show_me, who_can_request, show_gender, age_min, age_max)
    values (${p.uid}, ${p.gender}, ${p.showMe ?? 'everyone'}, ${p.whoCanRequest ?? 'everyone'}, ${p.gender === 'woman'}, 18, 60)`;
  if (p.at) {
    await sql`
      insert into user_locations (uid, lat, lng, accuracy_m, updated_at)
      values (${p.uid}, ${p.at.lat}, ${p.at.lng}, 10, ${p.locatedAt ?? new Date()})`;
  }
  if (p.companion) {
    await sql`
      insert into companion_profiles (uid, about, activity_tags, plan_types, prompt, is_listed, free_now_until)
      values (${p.uid}, ${`About ${p.name}`}, ${p.companion.planTypes}, ${p.companion.planTypes},
        ${sql.json({ promptId: 'ideal_sunday', answer: 'Coffee and a walk' })}, ${p.companion.isListed ?? true},
        ${p.companion.freeNowUntil ?? null})`;
    await sql`
      insert into availability (uid, weekly, exceptions, timezone)
      values (${p.uid}, ${sql.json(p.companion.weekly ?? [])}, '[]'::jsonb, 'Asia/Kolkata')`;
  }
}

export interface SlotSpec {
  id: string;
  dayKey: string;
  startAt: Date;
  endAt: Date;
  capacity?: number;
  booked?: number;
  status?: string;
}

export async function addVenue(
  sql: Db,
  v: { id: string; ownerUid: string; name: string; at: { lat: number; lng: number }; planTypes?: string[]; verified?: boolean; listed?: boolean },
  slots: SlotSpec[] = [],
): Promise<void> {
  const [owner] = await sql`select 1 from users where id = ${v.ownerUid}`;
  if (!owner) {
    await authUser(sql, v.ownerUid);
    await sql`
      insert into users (id, account_type, display_name, verification_status, account_status)
      values (${v.ownerUid}, 'venue_partner', ${v.name}, 'approved', 'active')`;
  }
  await sql`
    insert into venues (id, owner_uid, name, category, address_line, lat, lng, plan_types, verification_status, is_listed, perk)
    values (${v.id}, ${v.ownerUid}, ${v.name}, 'cafe', 'Somewhere, Mumbai', ${v.at.lat}, ${v.at.lng},
      ${v.planTypes ?? ['coffee', 'walk', 'event', 'movie', 'dinner']}, ${v.verified === false ? 'pending' : 'verified'},
      ${v.listed ?? true}, ${sql.json({ text: '10% off for FindX meetups' })})`;
  for (const s of slots) {
    await sql`
      insert into venue_slots (venue_id, id, day_key, start_at, end_at, capacity, booked, status)
      values (${v.id}, ${s.id}, ${s.dayKey}, ${s.startAt}, ${s.endAt}, ${s.capacity ?? 3}, ${s.booked ?? 0}, ${s.status ?? 'open'})`;
  }
}

/**
 * Runs `body` as a signed-in app user (role `authenticated`, JWT `sub` = uid),
 * so row-level security applies exactly as for the app. Rolled back afterwards.
 */
export async function asUser<T>(sql: Db, uid: string | null, body: (tx: postgres.TransactionSql) => Promise<T>): Promise<T> {
  let result: T | undefined;
  await sql
    .begin(async (tx) => {
      await tx`select set_config('request.jwt.claims', ${JSON.stringify(uid ? { sub: uid, role: 'authenticated' } : { role: 'anon' })}, true)`;
      await tx.unsafe(`set local role ${uid ? 'authenticated' : 'anon'}`);
      result = await body(tx);
      throw new Rollback();
    })
    .catch((error: unknown) => {
      if (!(error instanceof Rollback)) throw error;
    });
  return result as T;
}

class Rollback extends Error {}

/**
 * True when the statement is refused by row-level security, a grant, a check
 * or a guard trigger. An update or delete that RLS filtered down to no rows
 * counts as refused too. Runs in a savepoint so the transaction carries on.
 */
export async function denied(
  tx: postgres.TransactionSql,
  run: (sp: postgres.TransactionSql) => Promise<postgres.RowList<postgres.Row[]>>,
): Promise<boolean> {
  try {
    const rows = await tx.savepoint((sp) => run(sp as unknown as postgres.TransactionSql));
    return rows.command !== 'SELECT' && rows.count === 0;
  } catch (error) {
    const code = (error as { code?: string }).code;
    if (code === '42501' || code === '23514' || code === '23502' || code === 'P0001') return true;
    throw error;
  }
}
