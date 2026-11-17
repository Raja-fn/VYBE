import { z } from 'zod';

import { ACTIVE_STATUSES, canSeekerCancel, companionCovers, overlaps, slotState, type BookingStatus, type SlotState } from '../domain/booking';
import type { CompanionCandidate } from '../domain/discovery';
import { rankCandidates } from '../domain/discovery';
import { distanceKm, type LatLng } from '../domain/geo';
import { rankVenues, type VenueCandidate } from '../domain/venues';
import { uidSchema, type Caller } from '../shared/callable';
import type { Sql } from '../shared/db';
import { appError, ErrorCodes } from '../shared/errorCodes';
import { consumeRateLimit } from '../shared/rateLimit';
import { postBookingCard } from './chatCards';
import type { Deps } from './deps';
import { availabilityOf, blockedUids, boundingBox, candidateFrom, indexRows, loadSeeker } from './discovery';
import { ensureDefaultSlots, ensurePlacesNear } from './places';

const planTypeSchema = z.enum(['coffee', 'movie', 'event', 'walk', 'dinner']);

interface VenueRecord extends VenueCandidate {
  name: string;
  category: string;
  addressLine: string;
  ownerUid: string | null;
  perk: string | null;
}

interface VenueRow {
  id: string;
  lat: number;
  lng: number;
  plan_types: string[];
  name: string;
  category: string;
  address_line: string;
  owner_uid: string | null;
  perk: { text?: string } | null;
  verification_status: string;
  is_listed: boolean;
}

function venueFrom(row: VenueRow): VenueRecord {
  return {
    venueId: row.id,
    lat: row.lat,
    lng: row.lng,
    planTypes: row.plan_types ?? [],
    name: row.name,
    category: row.category,
    addressLine: row.address_line,
    ownerUid: row.owner_uid,
    perk: row.perk?.text ?? null,
  };
}

/**
 * The companion as this seeker may see them (radius, matching, blocks), or
 * "not found". Returns the snapped location used for venue reach.
 */
export async function visibleCompanion(deps: Deps, caller: Caller, companionUid: string) {
  const seeker = await loadSeeker(deps.sql, caller.uid);
  const [rows, blocked] = await Promise.all([indexRows(deps.sql, [companionUid]), blockedUids(deps.sql, caller.uid)]);
  const ranked = rows.length
    ? rankCandidates({
        seeker,
        candidates: rows.map(candidateFrom),
        blockedUids: blocked,
        venues: [],
        planType: null,
        radiusKm: deps.config.discoveryRadiusKm,
        distanceStepKm: deps.config.distanceLabelStepKm,
        now: deps.now(),
        limit: 1,
      })
    : [];
  if (ranked.length === 0) throw appError(ErrorCodes.notFound, 'This person is not available.');
  return { seeker, companion: ranked[0].candidate };
}

// ---------- nearbyVenues ----------

export const nearbyVenuesInput = z.object({
  planType: planTypeSchema.nullable().optional(),
  /** When set, only venues within reach of this companion too. */
  companionUid: uidSchema.nullable().optional(),
});

export interface VenueDto {
  venueId: string;
  name: string;
  category: string;
  addressLine: string;
  lat: number;
  lng: number;
  distanceKm: number;
  planTypes: string[];
  perk: string | null;
  popularityScore: number;
  popularityLabel: 'hot' | 'busy' | 'quiet';
  rank: number;
}

async function venuesNear(sql: Sql, center: LatLng, radiusKm: number): Promise<VenueRecord[]> {
  const box = boundingBox(center, radiusKm);
  const rows = await sql<VenueRow[]>`
    select * from venues
    where verification_status = 'verified' and is_listed
      and lat between ${box.minLat} and ${box.maxLat}
      and lng between ${box.minLng} and ${box.maxLng}`;
  return rows.map(venueFrom);
}

export async function nearbyVenuesLogic(
  deps: Deps,
  caller: Caller,
  input: z.infer<typeof nearbyVenuesInput>,
): Promise<{ venues: VenueDto[] }> {
  const now = deps.now();
  await consumeRateLimit(deps.sql, `${caller.uid}_discovery`, deps.config.discoverCallsPerMinute, 60_000, now);
  const { seeker, companion } = input.companionUid
    ? await visibleCompanion(deps, caller, input.companionUid)
    : { seeker: await loadSeeker(deps.sql, caller.uid), companion: null as CompanionCandidate | null };

  await ensurePlacesNear(deps, seeker);
  const venues = await venuesNear(deps.sql, seeker, deps.config.discoveryRadiusKm);
  const scores = new Map((await deps.services.places.getPopularity(venues, now)).map((s) => [s.venueId, s.score] as const));
  const ranked = rankVenues({
    venues,
    seeker,
    companion,
    planType: input.planType ?? null,
    radiusKm: deps.config.discoveryRadiusKm,
    scores,
    thresholds: { hot: deps.config.popularityHotThreshold, busy: deps.config.popularityBusyThreshold },
  });
  return {
    venues: ranked.slice(0, deps.config.venuesListLimit).map(({ venue, distanceKm: km, popularityScore, popularityLabel, rank }) => ({
      venueId: venue.venueId,
      name: venue.name,
      category: venue.category,
      addressLine: venue.addressLine,
      lat: venue.lat,
      lng: venue.lng,
      distanceKm: km,
      planTypes: venue.planTypes,
      perk: venue.perk,
      popularityScore,
      popularityLabel,
      rank,
    })),
  };
}

// ---------- venueSlots ----------

export const venueSlotsInput = z.object({
  venueId: z.string().min(1),
  dayKey: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  companionUid: uidSchema,
});

export interface SlotDto {
  slotId: string;
  startAt: string;
  endAt: string;
  state: SlotState;
}

interface SlotRow {
  id: string;
  day_key: string;
  start_at: Date;
  end_at: Date;
  capacity: number;
  booked: number;
  status: string;
}

/** Active bookings where this person is the companion on this day. */
async function companionBusyOn(sql: Sql, uid: string, dayKey: string) {
  const rows = await sql<{ start_at: Date; end_at: Date }[]>`
    select start_at, end_at from bookings
    where companion_uid = ${uid} and day_key = ${dayKey} and status in ${sql(ACTIVE_STATUSES as string[])}`;
  return rows.map((r) => ({ startAt: r.start_at, endAt: r.end_at }));
}

/** Active bookings where this person is the seeker on this day. */
async function seekerBusyOn(sql: Sql, uid: string, dayKey: string) {
  const rows = await sql<{ start_at: Date; end_at: Date }[]>`
    select start_at, end_at from bookings
    where seeker_uid = ${uid} and day_key = ${dayKey} and status in ${sql(ACTIVE_STATUSES as string[])}`;
  return rows.map((r) => ({ startAt: r.start_at, endAt: r.end_at }));
}

async function loadReachableVenue(deps: Deps, venueId: string, seeker: LatLng, companion: LatLng) {
  const [row] = await deps.sql<VenueRow[]>`select * from venues where id = ${venueId}`;
  const radius = deps.config.discoveryRadiusKm;
  if (!row || row.verification_status !== 'verified' || !row.is_listed) {
    throw appError(ErrorCodes.notFound, 'This spot is not available.');
  }
  const venue = venueFrom(row);
  if (distanceKm(seeker, venue) > radius || distanceKm(companion, venue) > radius) {
    throw appError(ErrorCodes.notFound, 'This spot is not available.');
  }
  return venue;
}

export async function venueSlotsLogic(
  deps: Deps,
  caller: Caller,
  input: z.infer<typeof venueSlotsInput>,
): Promise<{ slots: SlotDto[] }> {
  const now = deps.now();
  const { seeker, companion } = await visibleCompanion(deps, caller, input.companionUid);
  await loadReachableVenue(deps, input.venueId, seeker, companion);
  await ensureDefaultSlots(deps.sql, deps, input.venueId, input.dayKey);

  const [slots, availability, companionBusy] = await Promise.all([
    deps.sql<SlotRow[]>`
      select id, day_key, start_at, end_at, capacity, booked, status from venue_slots
      where venue_id = ${input.venueId} and day_key = ${input.dayKey} order by start_at`,
    availabilityOf(deps.sql, [companion.uid]),
    companionBusyOn(deps.sql, companion.uid, input.dayKey),
  ]);

  return {
    slots: slots.map((slot) => {
      const span = { startAt: slot.start_at, endAt: slot.end_at };
      const state = slotState({
        slot: { ...span, capacity: slot.capacity, booked: slot.booked, status: slot.status },
        now,
        companionFree: companionCovers(
          span,
          { freeNowUntil: companion.freeNowUntil, availability: availability.get(companion.uid) ?? null },
          now,
          deps.config.launchCity.timezone,
        ),
        companionBusy: companionBusy.some((b) => overlaps(b, span)),
      });
      return { slotId: slot.id, startAt: span.startAt.toISOString(), endAt: span.endAt.toISOString(), state };
    }),
  };
}

// ---------- requestBooking ----------

export const requestBookingInput = z.object({
  /** Client-generated id: retries with the same id never double-charge. */
  requestId: z.string().regex(/^[A-Za-z0-9_-]{8,40}$/),
  companionUid: uidSchema,
  venueId: z.string().min(1),
  slotId: z.string().min(1),
  planType: planTypeSchema,
  kind: z.enum(['scheduled', 'instant']),
});

async function balanceOf(sql: Sql, uid: string): Promise<number> {
  const [row] = await sql<{ balance: number }[]>`select balance from credit_accounts where uid = ${uid}`;
  return row?.balance ?? 0;
}

export async function requestBookingLogic(
  deps: Deps,
  caller: Caller,
  input: z.infer<typeof requestBookingInput>,
): Promise<{ bookingId: string; balance: number }> {
  const { sql, config } = deps;
  const now = deps.now();
  const bookingId = `${caller.uid}_${input.requestId}`;

  const [existing] = await sql`select 1 from bookings where id = ${bookingId}`;
  if (existing) return { bookingId, balance: await balanceOf(sql, caller.uid) };

  const { seeker, companion } = await visibleCompanion(deps, caller, input.companionUid);
  const venue = await loadReachableVenue(deps, input.venueId, seeker, companion);
  if (!companion.planTypes.includes(input.planType) || !venue.planTypes.includes(input.planType)) {
    throw appError(ErrorCodes.invalidInput, 'This plan is not offered here.');
  }
  const availability = (await availabilityOf(sql, [companion.uid])).get(companion.uid) ?? null;
  // Booking is free by default (both costs 0); a cost above 0 charges credits.
  const cost = input.kind === 'instant' ? config.creditCostInstantRequest : config.creditCostBookSpot;
  const ledgerId = cost > 0 ? `${bookingId}_charge` : null;

  const result = await sql.begin(async (tx) => {
    // Lock both people (in a fixed order) so neither can be double-booked by a parallel request.
    const people = await tx<{ id: string; display_name: string | null; age_years: number | null }[]>`
      select id, display_name, age_years from users where id in ${tx([caller.uid, companion.uid])} order by id for update`;
    const [again] = await tx`select 1 from bookings where id = ${bookingId}`;
    if (again) return null;

    const [slot] = await tx<SlotRow[]>`
      select id, day_key, start_at, end_at, capacity, booked, status from venue_slots
      where venue_id = ${venue.venueId} and id = ${input.slotId} for update`;
    if (!slot) throw appError(ErrorCodes.notFound, 'This time is not available.');
    const span = { startAt: slot.start_at, endAt: slot.end_at };
    const [companionDay, seekerDay] = await Promise.all([
      companionBusyOn(tx, companion.uid, slot.day_key),
      seekerBusyOn(tx, caller.uid, slot.day_key),
    ]);

    const state = slotState({
      slot: { ...span, capacity: slot.capacity, booked: slot.booked, status: slot.status },
      now,
      companionFree: companionCovers(span, { freeNowUntil: companion.freeNowUntil, availability }, now, config.launchCity.timezone),
      companionBusy: companionDay.some((b) => overlaps(b, span)),
    });
    if (state === 'full') throw appError(ErrorCodes.slotFull, 'That time just filled up.');
    if (state === 'companion_unavailable') throw appError(ErrorCodes.companionUnavailable, 'They are not free at that time.');
    if (state !== 'available') throw appError(ErrorCodes.invalidInput, 'This time is not available.');
    if (seekerDay.some((b) => overlaps(b, span))) throw appError(ErrorCodes.invalidInput, 'You already have a meetup at that time.');

    const [account] = await tx<{ balance: number }[]>`select balance from credit_accounts where uid = ${caller.uid} for update`;
    const current = account?.balance ?? 0;
    if (cost > 0 && current < cost) throw appError(ErrorCodes.insufficientCredits, 'Not enough credits.');
    const after = current - cost;
    const booked = slot.booked + 1;
    const me = people.find((p) => p.id === caller.uid);
    const them = people.find((p) => p.id === companion.uid);

    await tx`
      update venue_slots set booked = ${booked}, status = ${booked >= slot.capacity ? 'full' : 'open'}
      where venue_id = ${venue.venueId} and id = ${input.slotId}`;
    if (ledgerId) {
      await tx`
        insert into credit_accounts (uid, balance, updated_at) values (${caller.uid}, ${after}, ${now})
        on conflict (uid) do update set balance = excluded.balance, updated_at = excluded.updated_at`;
      await tx`
        insert into credit_ledger (id, uid, delta, balance_after, reason, ref_type, ref_id, idempotency_key, created_at)
        values (${ledgerId}, ${caller.uid}, ${-cost}, ${after}, ${input.kind === 'instant' ? 'instant_request' : 'booking'},
          'booking', ${bookingId}, ${ledgerId}, ${now})`;
    }
    await tx`
      insert into bookings (id, seeker_uid, seeker_name, seeker_age, companion_uid, companion_name, companion_age,
        venue_id, venue_name, venue_category, venue_owner_uid, slot_id, day_key, start_at, end_at, plan_type, kind,
        status, status_reason, credit_cost, charge_ledger_id, participants, cancelled_by, created_at, updated_at)
      values (${bookingId}, ${caller.uid}, ${me?.display_name ?? ''}, ${me?.age_years ?? null}, ${companion.uid},
        ${them?.display_name ?? ''}, ${companion.ageYears}, ${venue.venueId}, ${venue.name}, ${venue.category},
        ${venue.ownerUid}, ${input.slotId}, ${slot.day_key}, ${span.startAt}, ${span.endAt}, ${input.planType},
        ${input.kind}, 'requested', null, ${cost}, ${ledgerId}, ${[caller.uid, companion.uid]}::uuid[], null, ${now}, ${now})`;
    return { balance: after, startAt: span.startAt };
  });

  if (!result) return { bookingId, balance: await balanceOf(sql, caller.uid) };
  await postBookingCard(
    sql,
    {
      bookingId,
      seekerUid: caller.uid,
      companionUid: companion.uid,
      planType: input.planType,
      startAt: result.startAt,
      venueName: venue.name,
    },
    now,
  );
  return { bookingId, balance: result.balance };
}

// ---------- cancelBooking ----------

export const cancelBookingInput = z.object({ bookingId: z.string().min(1) });

/** Releases the table a booking held (never below 0; a closed slot stays closed). */
export async function releaseSlot(tx: Sql, venueId: string, slotId: string): Promise<void> {
  await tx`
    update venue_slots set
      booked = greatest(booked - 1, 0),
      status = case when status = 'closed' then 'closed' else 'open' end
    where venue_id = ${venueId} and id = ${slotId}`;
}

/** The seeker cancels. The table is freed; credits are not refunded. */
export async function cancelBookingLogic(
  deps: Deps,
  caller: Caller,
  input: z.infer<typeof cancelBookingInput>,
): Promise<{ status: 'cancelled' }> {
  const now = deps.now();
  await deps.sql.begin(async (tx) => {
    const [booking] = await tx<{ seeker_uid: string; status: BookingStatus; start_at: Date; venue_id: string; slot_id: string }[]>`
      select seeker_uid, status, start_at, venue_id, slot_id from bookings where id = ${input.bookingId} for update`;
    if (!booking || booking.seeker_uid !== caller.uid) throw appError(ErrorCodes.notFound, 'Booking not found.');
    if (!canSeekerCancel(booking.status, booking.start_at, now)) {
      throw appError(ErrorCodes.invalidInput, 'This booking can no longer be cancelled.');
    }
    await releaseSlot(tx, booking.venue_id, booking.slot_id);
    await tx`
      update bookings set status = 'cancelled', status_reason = 'seeker_cancelled', cancelled_by = ${caller.uid},
        updated_at = ${now}
      where id = ${input.bookingId}`;
  });
  return { status: 'cancelled' };
}
