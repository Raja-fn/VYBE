import { localDay } from '../domain/availability';
import type { LatLng } from '../domain/geo';
import { NoPublicPlaces } from '../services/places/publicPlacesSource';
import type { Sql } from '../shared/db';
import type { Deps } from './deps';

/**
 * The grid cell a point falls in, and the cell's centre. Each cell is fetched
 * from the places source once per refresh period.
 */
export function placesCell(point: LatLng, degrees: number): { key: string; center: LatLng; halfDiagonalKm: number } {
  const row = Math.floor(point.lat / degrees);
  const col = Math.floor(point.lng / degrees);
  const center = { lat: (row + 0.5) * degrees, lng: (col + 0.5) * degrees };
  const kmLat = degrees * 111.32;
  const kmLng = degrees * 111.32 * Math.cos((center.lat * Math.PI) / 180);
  return { key: `${degrees}:${row}:${col}`, center, halfDiagonalKm: Math.hypot(kmLat, kmLng) / 2 };
}

/**
 * Makes sure public places around [point] are in the venues table. The whole
 * cell is fetched at once, wide enough to cover the discovery radius from any
 * point in it. Failures are logged and swallowed: the person then sees the
 * spots already known, and the next request tries again.
 */
export async function ensurePlacesNear(deps: Deps, point: LatLng): Promise<void> {
  const { config } = deps;
  const cell = placesCell(point, config.placesCellDegrees);
  if (deps.services.publicPlaces instanceof NoPublicPlaces) return; // bulk-imported instead
  const now = deps.now();
  const [done] = await deps.sql<{ fetched_at: Date }[]>`select fetched_at from place_imports where cell = ${cell.key}`;
  if (done && now.getTime() - done.fetched_at.getTime() < config.placesRefreshDays * 86_400_000) return;

  let places;
  try {
    places = await deps.services.publicPlaces.nearby(cell.center, config.discoveryRadiusKm + cell.halfDiagonalKm);
  } catch (error) {
    console.warn(`Public places for ${cell.key} could not be fetched: ${String(error)}`);
    return;
  }

  await deps.sql.begin(async (tx) => {
    if (places.length > 0) {
      const rows = places.map((p) => ({
        id: p.venueId,
        owner_uid: null,
        name: p.name,
        category: p.category,
        address_line: p.addressLine,
        lat: p.lat,
        lng: p.lng,
        plan_types: p.planTypes,
        verification_status: 'verified',
        is_listed: true,
        source: 'osm',
        updated_at: now,
      }));
      // A place a venue partner has claimed (source = partner) is never overwritten.
      await tx`
        insert into venues ${tx(rows)}
        on conflict (id) do update set
          name = excluded.name, category = excluded.category, address_line = excluded.address_line,
          lat = excluded.lat, lng = excluded.lng, plan_types = excluded.plan_types, updated_at = excluded.updated_at
        where venues.source = 'osm'`;
    }
    await tx`
      insert into place_imports (cell, fetched_at, venue_count) values (${cell.key}, ${now}, ${places.length})
      on conflict (cell) do update set fetched_at = excluded.fetched_at, venue_count = excluded.venue_count`;
  });
}

/**
 * Default time slots for a place without a venue partner (public places and
 * spots the VYBE team added): one slot
 * every `slotMinutesDefault` between the opening and closing hours, created
 * the first time someone looks at that day. Partner venues keep their own.
 */
export async function ensureDefaultSlots(sql: Sql, deps: Pick<Deps, 'config' | 'now'>, venueId: string, dayKey: string) {
  const { config } = deps;
  const now = deps.now();
  // Only days that can be booked: today up to bookingDaysAhead.
  let day: ReturnType<typeof localDay> | undefined;
  for (let offset = 0; offset <= config.bookingDaysAhead; offset++) {
    const candidate = localDay(now, offset, config.launchCity.timezone);
    if (candidate.dayKey === dayKey) day = candidate;
  }
  if (!day) return;

  const step = config.slotMinutesDefault;
  const ids: string[] = [];
  const starts: string[] = [];
  const ends: string[] = [];
  for (let minute = config.defaultSlotOpenHour * 60; minute + step <= config.defaultSlotCloseHour * 60; minute += step) {
    ids.push(`d${dayKey.replace(/-/g, '')}-${String(Math.floor(minute / 60)).padStart(2, '0')}${String(minute % 60).padStart(2, '0')}`);
    starts.push(day.at(minute).toISOString());
    ends.push(day.at(minute + step).toISOString());
  }
  if (ids.length === 0) return;
  await sql`
    insert into venue_slots (venue_id, id, day_key, start_at, end_at, capacity, booked, status)
    select ${venueId}, s.id, ${dayKey}, s.start_at, s.end_at, ${config.defaultSlotCapacity}, 0, 'open'
    from unnest(${ids}::text[], ${starts}::timestamptz[], ${ends}::timestamptz[]) as s (id, start_at, end_at)
    where exists (select 1 from venues v where v.id = ${venueId} and v.source in ('osm', 'admin'))
      and not exists (select 1 from venue_slots x where x.venue_id = ${venueId} and x.day_key = ${dayKey})
    on conflict do nothing`;
}

/** True when a place without a partner still has default slots ahead today. */
export function defaultSlotsLeftToday(deps: Pick<Deps, 'config' | 'now'>): boolean {
  const { config } = deps;
  const today = localDay(deps.now(), 0, config.launchCity.timezone);
  const lastStart = config.defaultSlotCloseHour * 60 - config.slotMinutesDefault;
  return today.at(lastStart).getTime() > deps.now().getTime();
}
