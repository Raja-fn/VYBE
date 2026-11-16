import { nearbyVenuesLogic, venueSlotsLogic } from '../../src/handlers/booking';
import { discoverCompanionsLogic } from '../../src/handlers/discovery';
import { placesCell } from '../../src/handlers/places';
import type { PublicPlace, PublicPlacesSource } from '../../src/services/places/publicPlacesSource';
import { addPerson, connect, googleCaller, makeDeps, People, reset } from './helpers';

// Tuesday 10 Nov 2026, 15:30 in India.
const NOW = new Date('2026-11-10T10:00:00Z');
const JAIPUR = { lat: 26.9124, lng: 75.7873 };
const sql = connect();
let people: People;

class RecordingPlaces implements PublicPlacesSource {
  calls: { lat: number; lng: number; radiusKm: number }[] = [];
  fail = false;
  constructor(private readonly places: PublicPlace[]) {}
  async nearby(center: { lat: number; lng: number }, radiusKm: number) {
    this.calls.push({ ...center, radiusKm });
    if (this.fail) throw new Error('Overpass is busy');
    return this.places;
  }
}

const cafe = (id: string, name: string, dLat: number): PublicPlace => ({
  venueId: `osm-node-${id}`,
  name,
  category: 'cafe',
  planTypes: ['coffee'],
  addressLine: 'C Scheme, Jaipur',
  lat: JAIPUR.lat + dLat,
  lng: JAIPUR.lng,
});

function deps(source: PublicPlacesSource, now = NOW) {
  const d = makeDeps(sql, { discoverCallsPerMinute: 1000 }, now);
  // As in production: no popularity data yet, so spots rank by distance.
  const places = { getPopularity: async (venues: { venueId: string }[]) => venues.map((v) => ({ venueId: v.venueId, score: 0 })) };
  return { ...d, services: { ...d.services, publicPlaces: source, places } };
}

beforeEach(async () => {
  await reset(sql);
  people = new People();
  await addPerson(sql, { uid: people.uid('raja'), name: 'raja', gender: 'man', at: JAIPUR, locatedAt: NOW });
  await addPerson(sql, {
    uid: people.uid('neha'),
    name: 'neha',
    gender: 'woman',
    at: { lat: JAIPUR.lat + 0.005, lng: JAIPUR.lng },
    locatedAt: NOW,
    companion: { planTypes: ['coffee'], weekly: [{ weekday: 2, start: '09:00', end: '23:00' }] },
  });
});

describe('public places near the person', () => {
  it('fetches the area once, wide enough for anyone in it, and lists the spots by distance', async () => {
    const source = new RecordingPlaces([cafe('1', 'Far Cafe', 0.03), cafe('2', 'Near Cafe', 0.002), cafe('3', 'Way Off', 0.2)]);
    const raja = googleCaller(people.uid('raja'));

    const { venues } = await nearbyVenuesLogic(deps(source), raja, {});
    expect(venues.map((v) => v.name)).toEqual(['Near Cafe', 'Far Cafe']);
    expect(venues[0]).toMatchObject({ category: 'cafe', planTypes: ['coffee'], popularityLabel: 'quiet', rank: 1 });

    const cell = placesCell(JAIPUR, 0.02);
    expect(source.calls).toEqual([{ ...cell.center, radiusKm: 5 + cell.halfDiagonalKm }]);
    await nearbyVenuesLogic(deps(source), raja, {});
    expect(source.calls).toHaveLength(1);

    // A month later the area is fetched again.
    await nearbyVenuesLogic(deps(source, new Date(NOW.getTime() + 31 * 86_400_000)), raja, {});
    expect(source.calls).toHaveLength(2);
  });

  it('when the source is down, nothing breaks and the next request tries again', async () => {
    const source = new RecordingPlaces([cafe('1', 'Near Cafe', 0.002)]);
    source.fail = true;
    const raja = googleCaller(people.uid('raja'));
    await expect(nearbyVenuesLogic(deps(source), raja, {})).resolves.toEqual({ venues: [] });
    source.fail = false;
    expect((await nearbyVenuesLogic(deps(source), raja, {})).venues).toHaveLength(1);
  });

  it('never overwrites a place a venue partner has claimed', async () => {
    const source = new RecordingPlaces([cafe('1', 'OSM name', 0.002)]);
    await sql`
      insert into venues (id, name, category, address_line, lat, lng, plan_types, verification_status, is_listed, source)
      values ('osm-node-1', 'Partner name', 'cafe', 'x', ${JAIPUR.lat}, ${JAIPUR.lng}, '{coffee}', 'verified', true, 'partner')`;
    const { venues } = await nearbyVenuesLogic(deps(source), googleCaller(people.uid('raja')), {});
    expect(venues[0].name).toBe('Partner name');
  });

  it('a public place gets default slots for the day someone opens it, in local time', async () => {
    const source = new RecordingPlaces([cafe('1', 'Near Cafe', 0.002)]);
    const d = deps(source);
    const raja = googleCaller(people.uid('raja'));
    const neha = people.uid('neha');
    await nearbyVenuesLogic(d, raja, {});

    const { slots } = await venueSlotsLogic(d, raja, { venueId: 'osm-node-1', dayKey: '2026-11-10', companionUid: neha });
    // 10:00 to 22:00 local time, one slot per slotMinutesDefault.
    const perDay = ((22 - 10) * 60) / d.config.slotMinutesDefault;
    expect(slots).toHaveLength(perDay);
    expect(slots[0].startAt).toBe('2026-11-10T04:30:00.000Z');
    expect(slots[0].state).toBe('past');
    expect(slots.some((s) => s.state === 'available')).toBe(true);

    await venueSlotsLogic(d, raja, { venueId: 'osm-node-1', dayKey: '2026-11-10', companionUid: neha });
    expect((await sql`select count(*)::int as n from venue_slots`)[0].n).toBe(perDay);

    // Days that cannot be booked get nothing.
    await venueSlotsLogic(d, raja, { venueId: 'osm-node-1', dayKey: '2027-01-01', companionUid: neha });
    expect((await sql`select count(*)::int as n from venue_slots`)[0].n).toBe(perDay);
  });

  it('companions near public places show spots nearby before any slot exists', async () => {
    const source = new RecordingPlaces([cafe('1', 'Near Cafe', 0.002), cafe('2', 'Second', 0.004)]);
    const { companions } = await discoverCompanionsLogic(deps(source), googleCaller(people.uid('raja')), {});
    expect(companions.find((c) => c.uid === people.uid('neha'))?.spotsNearby).toBe(2);
  });
});
