import { z } from 'zod';

import { freeSpanFor, localDay, type AvailabilityDoc, type FreeSpan, type FreeWindow } from '../domain/availability';
import {
  isPlausibleMove,
  rankCandidates,
  type CompanionCandidate,
  type RankedCandidate,
  type Seeker,
  type VenuePoint,
} from '../domain/discovery';
import { distanceKm, type LatLng } from '../domain/geo';
import type { Gender, ShowMe, WhoCanRequest } from '../domain/matching';
import { uidSchema, type Caller } from '../shared/callable';
import type { Sql } from '../shared/db';
import { appError, ErrorCodes } from '../shared/errorCodes';
import { consumeRateLimit } from '../shared/rateLimit';
import type { Deps } from './deps';
import { defaultSlotsLeftToday, ensurePlacesNear } from './places';

/** What the app gets for each companion. Never contains coordinates. */
export interface CompanionCardDto {
  uid: string;
  displayName: string;
  ageYears: number;
  /** Only when the companion chose to show it. */
  gender: string | null;
  photoPaths: string[];
  about: string;
  activityTags: string[];
  planTypes: string[];
  prompt: { promptId: string; answer: string } | null;
  voiceIntro: { path: string; durationSec: number } | null;
  ratingAvg: number | null;
  ratingCount: number;
  meetupCount: number;
  distanceKm: number;
  spotsNearby: number;
  freeNowUntil: string | null;
  freeFrom: string | null;
  freeUntil: string | null;
  /** What the companion filled in on "Edit profile" (all optional). */
  details: ProfileDetailsDto;
}

export interface ProfileDetailsDto {
  city: string | null;
  languages: string[];
  education: string | null;
  profession: string | null;
  interests: string[];
  personality: string[];
  socialEnergy: string | null;
  drinking: string | null;
  smoking: string | null;
  fitness: string | null;
}

/** A latitude/longitude box that contains every point within `radiusKm` of `center`. */
export function boundingBox(center: LatLng, radiusKm: number) {
  const latDelta = radiusKm / 111.32;
  const lngDelta = radiusKm / (111.32 * Math.max(Math.cos((center.lat * Math.PI) / 180), 0.01));
  return {
    minLat: center.lat - latDelta,
    maxLat: center.lat + latDelta,
    minLng: center.lng - lngDelta,
    maxLng: center.lng + lngDelta,
  };
}

// ---------- shared loading ----------

interface SeekerRow {
  account_status: string;
  verification_status: string;
  gender: Gender | null;
  show_me: ShowMe | null;
  age_min: number | null;
  age_max: number | null;
  has_prefs: boolean;
  lat: number | null;
  lng: number | null;
}

export async function loadSeeker(sql: Sql, uid: string): Promise<Seeker> {
  const [row] = await sql<SeekerRow[]>`
    select u.account_status, u.verification_status, p.gender, p.show_me, p.age_min, p.age_max,
      p.uid is not null as has_prefs, l.lat, l.lng
    from users u
    left join preferences p on p.uid = u.id
    left join user_locations l on l.uid = u.id
    where u.id = ${uid}`;
  if (!row) throw appError(ErrorCodes.notFound, 'Accept the rules first.');
  if (row.account_status !== 'active') throw appError(ErrorCodes.blocked, 'This account is suspended.');
  if (row.verification_status !== 'approved') throw appError(ErrorCodes.notVerified, 'Finish verification first.');
  if (!row.has_prefs) throw appError(ErrorCodes.invalidInput, 'Set your preferences first.');
  if (row.lat === null || row.lng === null) throw appError(ErrorCodes.locationRequired, 'Share your location first.');
  return {
    uid,
    lat: row.lat,
    lng: row.lng,
    gender: row.gender!,
    showMe: row.show_me!,
    ageMin: row.age_min!,
    ageMax: row.age_max!,
  };
}

export interface IndexRow {
  uid: string;
  lat: number;
  lng: number;
  gender: Gender;
  who_can_request: WhoCanRequest;
  age_years: number;
  plan_types: string[];
  is_listed: boolean;
  verified: boolean;
  banned: boolean;
  free_now_until: Date | null;
}

export function candidateFrom(row: IndexRow): CompanionCandidate {
  return {
    uid: row.uid,
    lat: row.lat,
    lng: row.lng,
    gender: row.gender,
    whoCanRequest: row.who_can_request,
    ageYears: row.age_years,
    planTypes: row.plan_types ?? [],
    isListed: row.is_listed,
    verified: row.verified,
    banned: row.banned,
    freeNowUntil: row.free_now_until,
  };
}

/** Index rows for these companions (any that exist). */
export async function indexRows(sql: Sql, uids: string[]): Promise<IndexRow[]> {
  if (uids.length === 0) return [];
  return sql<IndexRow[]>`
    select uid, lat, lng, gender, who_can_request, age_years, plan_types, is_listed, verified, banned, free_now_until
    from companion_index where uid in ${sql(uids)}`;
}

/** Listed, verified companions in the box around `center`; exact radius checks happen in ranking. */
async function candidatesNear(sql: Sql, center: LatLng, radiusKm: number): Promise<CompanionCandidate[]> {
  const box = boundingBox(center, radiusKm);
  const rows = await sql<IndexRow[]>`
    select uid, lat, lng, gender, who_can_request, age_years, plan_types, is_listed, verified, banned, free_now_until
    from companion_index
    where is_listed and verified
      and lat between ${box.minLat} and ${box.maxLat}
      and lng between ${box.minLng} and ${box.maxLng}`;
  return rows.map(candidateFrom);
}

/** Everyone the caller blocked or was blocked by. */
export async function blockedUids(sql: Sql, uid: string): Promise<Set<string>> {
  const rows = await sql<{ other: string }[]>`
    select blocked_uid as other from blocks where blocker_uid = ${uid}
    union
    select blocker_uid as other from blocks where blocked_uid = ${uid}`;
  return new Set(rows.map((r) => r.other));
}

/** Verified, listed venues near `center` that still have an open slot today. */
async function venuesWithOpenSlotsToday(deps: Deps, center: LatLng): Promise<VenuePoint[]> {
  const { sql, config } = deps;
  const now = deps.now();
  const today = localDay(now, 0, config.launchCity.timezone).dayKey;
  const box = boundingBox(center, config.discoveryRadiusKm);
  const rows = await sql<{ id: string; lat: number; lng: number }[]>`
    select v.id, v.lat, v.lng from venues v
    where v.verification_status = 'verified' and v.is_listed
      and v.lat between ${box.minLat} and ${box.maxLat}
      and v.lng between ${box.minLng} and ${box.maxLng}
      and (
        exists (
          select 1 from venue_slots s
          where s.venue_id = v.id and s.day_key = ${today} and s.status = 'open' and s.start_at > ${now}
        )
        -- Public places get default slots when first opened.
        or (${defaultSlotsLeftToday(deps)} and v.source = 'osm'
            and not exists (select 1 from venue_slots s where s.venue_id = v.id and s.day_key = ${today}))
      )`;
  return rows
    .map((r) => ({ venueId: r.id, lat: r.lat, lng: r.lng }))
    .filter((v) => distanceKm(center, v) <= config.discoveryRadiusKm);
}

interface CardRow {
  uid: string;
  display_name: string | null;
  photo_paths: string[] | null;
  show_gender: boolean | null;
  gender: string | null;
  about: string | null;
  activity_tags: string[] | null;
  prompt: CompanionCardDto['prompt'];
  voice_intro: CompanionCardDto['voiceIntro'];
  rating_avg: string | number | null;
  rating_count: number | null;
  meetup_count: number | null;
  bio: string | null;
  city: string | null;
  languages: string[] | null;
  education: string | null;
  profession: string | null;
  interests: string[] | null;
  personality: string[] | null;
  social_energy: string | null;
  drinking: string | null;
  smoking: string | null;
  fitness: string | null;
}

async function toDtos(sql: Sql, ranked: RankedCandidate[], spans: Map<string, FreeSpan> = new Map()): Promise<CompanionCardDto[]> {
  if (ranked.length === 0) return [];
  const rows = await sql<CardRow[]>`
    select u.id as uid, u.display_name, u.photo_paths, p.show_gender, p.gender,
      c.about, c.activity_tags, c.prompt, c.voice_intro, c.rating_avg, c.rating_count, c.meetup_count,
      d.about as bio, d.city, d.languages, d.education, d.profession, d.interests, d.personality, d.social_energy,
      d.drinking, d.smoking, d.fitness
    from users u
    left join preferences p on p.uid = u.id
    left join companion_profiles c on c.uid = u.id
    left join profile_details d on d.uid = u.id
    where u.id in ${sql(ranked.map((r) => r.candidate.uid))}`;
  const byUid = new Map(rows.map((r) => [r.uid, r]));
  return ranked.map(({ candidate, distanceKm: km, spotsNearby, freeNow }) => {
    const row = byUid.get(candidate.uid);
    const span = spans.get(candidate.uid);
    return {
      uid: candidate.uid,
      displayName: row?.display_name ?? '',
      ageYears: candidate.ageYears,
      gender: row?.show_gender === true ? row.gender : null,
      photoPaths: row?.photo_paths ?? [],
      // The companion bio, else the general one from "Edit profile".
      about: row?.about || row?.bio || '',
      activityTags: row?.activity_tags ?? [],
      planTypes: candidate.planTypes,
      prompt: row?.prompt ?? null,
      voiceIntro: row?.voice_intro ?? null,
      ratingAvg: row?.rating_avg === null || row?.rating_avg === undefined ? null : Number(row.rating_avg),
      ratingCount: row?.rating_count ?? 0,
      meetupCount: row?.meetup_count ?? 0,
      distanceKm: km,
      spotsNearby,
      freeNowUntil: freeNow && candidate.freeNowUntil ? candidate.freeNowUntil.toISOString() : null,
      freeFrom: span ? span.from.toISOString() : null,
      freeUntil: span ? span.until.toISOString() : null,
      details: {
        city: row?.city ?? null,
        languages: row?.languages ?? [],
        education: row?.education ?? null,
        profession: row?.profession ?? null,
        interests: row?.interests ?? [],
        personality: row?.personality ?? [],
        socialEnergy: row?.social_energy ?? null,
        drinking: row?.drinking ?? null,
        smoking: row?.smoking ?? null,
        fitness: row?.fitness ?? null,
      },
    };
  });
}

/** Everything a discovery call needs, after the security checks. */
export async function prepare(deps: Deps, caller: Caller) {
  const now = deps.now();
  await consumeRateLimit(deps.sql, `${caller.uid}_discovery`, deps.config.discoverCallsPerMinute, 60_000, now);
  const seeker = await loadSeeker(deps.sql, caller.uid);
  await ensurePlacesNear(deps, seeker);
  const [blocked, venues] = await Promise.all([blockedUids(deps.sql, caller.uid), venuesWithOpenSlotsToday(deps, seeker)]);
  return { now, seeker, blocked, venues };
}

export function rank(
  deps: Deps,
  ctx: Awaited<ReturnType<typeof prepare>>,
  candidates: CompanionCandidate[],
  planType: string | null,
  limit: number,
): RankedCandidate[] {
  return rankCandidates({
    seeker: ctx.seeker,
    candidates,
    blockedUids: ctx.blocked,
    venues: ctx.venues,
    planType,
    radiusKm: deps.config.discoveryRadiusKm,
    distanceStepKm: deps.config.distanceLabelStepKm,
    now: ctx.now,
    limit,
  });
}

// ---------- updateMyLocation ----------

export const updateMyLocationInput = z.object({
  lat: z.number().min(-90).max(90),
  lng: z.number().min(-180).max(180),
  accuracyM: z.number().min(0).max(100_000),
});

/** Stores the exact location. A database trigger refreshes the companion index. */
export async function updateMyLocationLogic(
  deps: Deps,
  caller: Caller,
  input: z.infer<typeof updateMyLocationInput>,
): Promise<{ ok: true }> {
  const { sql } = deps;
  const now = deps.now();
  const [user] = await sql<{ account_status: string }[]>`select account_status from users where id = ${caller.uid}`;
  if (!user) throw appError(ErrorCodes.notFound, 'Accept the rules first.');
  if (user.account_status !== 'active') throw appError(ErrorCodes.blocked, 'This account is suspended.');

  const [previous] = await sql<{ lat: number; lng: number; updated_at: Date }[]>`
    select lat, lng, updated_at from user_locations where uid = ${caller.uid}`;
  const prior = previous ? { lat: previous.lat, lng: previous.lng, at: previous.updated_at } : null;
  if (!isPlausibleMove(prior, { lat: input.lat, lng: input.lng, at: now }, deps.config.maxPlausibleSpeedKmh)) {
    throw appError(ErrorCodes.invalidInput, 'That location does not look right. Try again in a moment.');
  }

  await sql`
    insert into user_locations (uid, lat, lng, accuracy_m, updated_at)
    values (${caller.uid}, ${input.lat}, ${input.lng}, ${input.accuracyM}, ${now})
    on conflict (uid) do update set lat = excluded.lat, lng = excluded.lng,
      accuracy_m = excluded.accuracy_m, updated_at = excluded.updated_at`;
  return { ok: true };
}

// ---------- discoverCompanions ----------

export const discoverInput = z.object({
  planType: z.enum(['coffee', 'movie', 'event', 'walk', 'dinner']).nullable().optional(),
});

export async function discoverCompanionsLogic(
  deps: Deps,
  caller: Caller,
  input: z.infer<typeof discoverInput>,
): Promise<{ companions: CompanionCardDto[] }> {
  const ctx = await prepare(deps, caller);
  const candidates = await candidatesNear(deps.sql, ctx.seeker, deps.config.discoveryRadiusKm);
  const ranked = rank(deps, ctx, candidates, input.planType ?? null, deps.config.discoverPageSize);
  return { companions: await toDtos(deps.sql, ranked) };
}

// ---------- freeNowCompanions ----------

export const freeNowInput = z.object({ window: z.enum(['next_2h', 'tonight', 'tomorrow']) });

export async function availabilityOf(sql: Sql, uids: string[]): Promise<Map<string, AvailabilityDoc>> {
  if (uids.length === 0) return new Map();
  const rows = await sql<{ uid: string; weekly: AvailabilityDoc['weekly']; exceptions: AvailabilityDoc['exceptions'] }[]>`
    select uid, weekly, exceptions from availability where uid in ${sql(uids)}`;
  return new Map(rows.map((r) => [r.uid, { weekly: r.weekly ?? [], exceptions: r.exceptions ?? [] }]));
}

export async function freeNowCompanionsLogic(
  deps: Deps,
  caller: Caller,
  input: { window: FreeWindow },
): Promise<{ companions: CompanionCardDto[] }> {
  const ctx = await prepare(deps, caller);
  const candidates = await candidatesNear(deps.sql, ctx.seeker, deps.config.discoveryRadiusKm);
  const ranked = rank(deps, ctx, candidates, null, Number.MAX_SAFE_INTEGER);
  const availability = await availabilityOf(deps.sql, ranked.map((r) => r.candidate.uid));

  const spans = new Map<string, FreeSpan>();
  for (const { candidate } of ranked) {
    const span = freeSpanFor(
      input.window,
      { freeNowUntil: candidate.freeNowUntil, availability: availability.get(candidate.uid) ?? null },
      ctx.now,
      { timeZone: deps.config.launchCity.timezone, tonightStartHour: deps.config.tonightStartHour },
    );
    if (span) spans.set(candidate.uid, span);
  }

  const free = ranked
    .filter(({ candidate }) => spans.has(candidate.uid))
    .sort(
      (a, b) =>
        spans.get(a.candidate.uid)!.from.getTime() - spans.get(b.candidate.uid)!.from.getTime() ||
        a.distanceKm - b.distanceKm,
    )
    .slice(0, deps.config.discoverPageSize);
  return { companions: await toDtos(deps.sql, free, spans) };
}

// ---------- getCompanionProfile ----------

export const profileInput = z.object({ uid: uidSchema });

export async function getCompanionProfileLogic(deps: Deps, caller: Caller, input: { uid: string }): Promise<CompanionCardDto> {
  const ctx = await prepare(deps, caller);
  const rows = await indexRows(deps.sql, [input.uid]);
  const ranked = rows.length ? rank(deps, ctx, rows.map(candidateFrom), null, 1) : [];
  // Same answer for "does not exist" and "not visible to you".
  if (ranked.length === 0) throw appError(ErrorCodes.notFound, 'This person is not available.');
  return (await toDtos(deps.sql, ranked))[0];
}

// ---------- savedCompanions ----------

export async function savedCompanionsLogic(deps: Deps, caller: Caller): Promise<{ companions: CompanionCardDto[] }> {
  const ctx = await prepare(deps, caller);
  const saved = await deps.sql<{ companion_uid: string }[]>`
    select companion_uid from saved_companions where uid = ${caller.uid} order by saved_at desc`;
  if (saved.length === 0) return { companions: [] };
  const order = new Map(saved.map((s, i) => [s.companion_uid, i]));
  const rows = await indexRows(deps.sql, saved.map((s) => s.companion_uid));
  const ranked = rank(deps, ctx, rows.map(candidateFrom), null, Number.MAX_SAFE_INTEGER).sort(
    (a, b) => order.get(a.candidate.uid)! - order.get(b.candidate.uid)!,
  );
  return { companions: await toDtos(deps.sql, ranked) };
}
