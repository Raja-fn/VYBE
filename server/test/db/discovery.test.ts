import { distanceKm } from '../../src/domain/geo';
import {
  discoverCompanionsLogic,
  freeNowCompanionsLogic,
  getCompanionProfileLogic,
  savedCompanionsLogic,
  updateMyLocationLogic,
} from '../../src/handlers/discovery';
import { addPerson, addVenue, connect, expectAppError, googleCaller, makeDeps, People, reset, type PersonSpec } from './helpers';

const NOW = new Date('2026-11-10T10:00:00Z'); // Tuesday 15:30 IST
const BANDRA = { lat: 19.0596, lng: 72.8295 };

const sql = connect();
let people: People;

const deps = (config = {}, now = NOW) => makeDeps(sql, config, now);
const caller = (name: string) => googleCaller(people.uid(name));
const person = (spec: Omit<PersonSpec, 'uid'>) => addPerson(sql, { ...spec, uid: people.uid(spec.name), locatedAt: NOW });
const inHours = (h: number) => new Date(NOW.getTime() + h * 3_600_000);

async function venue(name: string, at: { lat: number; lng: number }, openSlotToday: boolean) {
  await addVenue(sql, { id: name, ownerUid: people.uid(`${name}_owner`), name, at }, [
    {
      id: '20261110_1700',
      dayKey: '2026-11-10',
      startAt: new Date('2026-11-10T11:30:00Z'),
      endAt: new Date('2026-11-10T12:30:00Z'),
      status: openSlotToday ? 'open' : 'full',
      capacity: 3,
      booked: openSlotToday ? 0 : 3,
    },
  ]);
}

beforeEach(async () => {
  await reset(sql);
  people = new People();
  // A seeker in Bandra and companions around them.
  await person({ name: 'seeker', gender: 'man', showMe: 'everyone', at: BANDRA });
  await person({ name: 'neha', gender: 'woman', at: { lat: 19.062, lng: 72.833 }, companion: { planTypes: ['coffee', 'walk'], freeNowUntil: inHours(2) } });
  await person({ name: 'riya', gender: 'woman', whoCanRequest: 'women', at: { lat: 19.055, lng: 72.827 }, companion: { planTypes: ['coffee'] } });
  await person({
    name: 'sam',
    gender: 'non_binary',
    at: { lat: 19.0815, lng: 72.8391 },
    companion: { planTypes: ['event'], weekly: [{ weekday: 3, start: '11:00', end: '13:00' }] },
  });
  await person({ name: 'far', gender: 'woman', at: { lat: 19.1176, lng: 72.906 }, companion: { planTypes: ['coffee'], freeNowUntil: inHours(2) } });
  await venue('cafe', { lat: 19.0545, lng: 72.834 }, true);
  await venue('fullcafe', { lat: 19.06, lng: 72.83 }, false);
});

describe('discoverCompanions', () => {
  it('applies radius and two-way matching, free-now first', async () => {
    const { companions } = await discoverCompanionsLogic(deps(), caller('seeker'), {});
    // riya only accepts women; far is ~9 km away.
    expect(people.names(companions)).toEqual(['neha', 'sam']);
  });

  it('adds sample profiles after real people while showSampleProfiles is on, marked as samples', async () => {
    const { companions } = await discoverCompanionsLogic(deps({ showSampleProfiles: true }), caller('seeker'), {});
    expect(people.names(companions.filter((c) => !c.isSample))).toEqual(['neha', 'sam']);
    const samples = companions.filter((c) => c.isSample);
    expect(samples.length).toBeGreaterThan(0);
    expect(companions.findIndex((c) => c.isSample)).toBe(2);
    for (const s of samples) {
      expect(s.uid).toMatch(/^sample_/);
      expect(s.photoPaths[0]).toMatch(/^https:\/\/.+\/samples\/.+-1\.jpg$/);
    }
  });

  it('sample profiles follow the plan filter, and are off by default in tests', async () => {
    const walk = await discoverCompanionsLogic(deps({ showSampleProfiles: true }), caller('seeker'), { planType: 'walk' });
    for (const s of walk.companions.filter((c) => c.isSample)) expect(s.planTypes).toContain('walk');
    const off = await discoverCompanionsLogic(deps(), caller('seeker'), {});
    expect(off.companions.some((c) => c.isSample)).toBe(false);
  });

  it('never sends coordinates, only a rounded distance', async () => {
    const { companions } = await discoverCompanionsLogic(deps(), caller('seeker'), {});
    for (const c of companions) {
      expect(JSON.stringify(c)).not.toMatch(/"lat"|"lng"|geohash/);
      expect(Number.isInteger(c.distanceKm)).toBe(true);
      expect(c.distanceKm).toBeGreaterThanOrEqual(1);
    }
  });

  it('fills in the card details and shows gender only when the companion chose to', async () => {
    const { companions } = await discoverCompanionsLogic(deps(), caller('seeker'), {});
    const neha = companions.find((c) => c.uid === people.uid('neha'))!;
    const sam = companions.find((c) => c.uid === people.uid('sam'))!;
    expect(neha).toMatchObject({ displayName: 'neha', ageYears: 25, gender: 'woman', about: 'About neha' });
    expect(neha.freeNowUntil).toBe(inHours(2).toISOString());
    expect(neha.prompt).toEqual({ promptId: 'ideal_sunday', answer: 'Coffee and a walk' });
    expect(sam.gender).toBeNull();
    expect(sam.freeNowUntil).toBeNull();
  });

  it("shows the companion's profile details, never anyone's exact place", async () => {
    await sql`insert into profile_details (uid, about, city, languages, interests, drinking)
      values (${people.uid('sam')}, 'Theatre nerd.', 'Mumbai', '{english,marathi}', '{theatre,books}', 'never')`;
    const { companions } = await discoverCompanionsLogic(deps(), caller('seeker'), {});
    const sam = companions.find((c) => c.uid === people.uid('sam'))!;
    expect(sam.about).toBe('About sam'); // the companion bio wins over the general one
    expect(sam.details).toEqual({
      city: 'Mumbai',
      languages: ['english', 'marathi'],
      education: null,
      profession: null,
      interests: ['theatre', 'books'],
      personality: [],
      socialEnergy: null,
      drinking: 'never',
      smoking: null,
      fitness: null,
    });
    expect(companions.find((c) => c.uid === people.uid('neha'))!.details.languages).toEqual([]);
  });

  it('counts only venues with an open slot today', async () => {
    const { companions } = await discoverCompanionsLogic(deps(), caller('seeker'), {});
    expect(companions.find((c) => c.uid === people.uid('neha'))!.spotsNearby).toBe(1);
  });

  it('filters by plan', async () => {
    const { companions } = await discoverCompanionsLogic(deps(), caller('seeker'), { planType: 'event' });
    expect(people.names(companions)).toEqual(['sam']);
  });

  it('a woman seeker also sees companions who accept only women', async () => {
    await person({ name: 'diya', gender: 'woman', at: BANDRA });
    const { companions } = await discoverCompanionsLogic(deps(), caller('diya'), {});
    expect(people.names(companions)).toEqual(['neha', 'riya', 'sam']);
  });

  it('blocks hide people in both directions', async () => {
    await sql`insert into blocks (blocker_uid, blocked_uid) values (${people.uid('seeker')}, ${people.uid('neha')})`;
    await sql`insert into blocks (blocker_uid, blocked_uid) values (${people.uid('sam')}, ${people.uid('seeker')})`;
    const { companions } = await discoverCompanionsLogic(deps(), caller('seeker'), {});
    expect(companions).toEqual([]);
  });

  it('refuses unverified seekers and seekers without a location', async () => {
    await person({ name: 'pending', gender: 'man', at: BANDRA, verified: false });
    await expectAppError(discoverCompanionsLogic(deps(), caller('pending'), {}), 'not_verified');
    await sql`delete from user_locations where uid = ${people.uid('seeker')}`;
    await expectAppError(discoverCompanionsLogic(deps(), caller('seeker'), {}), 'location_required');
  });

  it('rate-limits repeated calls', async () => {
    const limited = deps({ discoverCallsPerMinute: 2 });
    await discoverCompanionsLogic(limited, caller('seeker'), {});
    await discoverCompanionsLogic(limited, caller('seeker'), {});
    await expectAppError(discoverCompanionsLogic(limited, caller('seeker'), {}), 'rate_limited');
  });

  it('banned and unlisted companions disappear from the index results', async () => {
    await sql`update users set account_status = 'banned' where id = ${people.uid('neha')}`;
    await sql`update companion_profiles set is_listed = false where uid = ${people.uid('sam')}`;
    const { companions } = await discoverCompanionsLogic(deps(), caller('seeker'), {});
    expect(companions).toEqual([]);
  });
});

describe('freeNowCompanions', () => {
  it('next 2 hours lists companions who switched on "free now"', async () => {
    const { companions } = await freeNowCompanionsLogic(deps(), caller('seeker'), { window: 'next_2h' });
    expect(people.names(companions)).toEqual(['neha']);
  });

  it('tomorrow uses weekly availability', async () => {
    const { companions } = await freeNowCompanionsLogic(deps(), caller('seeker'), { window: 'tomorrow' });
    expect(people.names(companions)).toEqual(['sam']);
    expect(companions[0].freeFrom).toBe('2026-11-11T05:30:00.000Z');
    expect(companions[0].freeUntil).toBe('2026-11-11T07:30:00.000Z');
  });
});

describe('getCompanionProfile', () => {
  it('returns a visible companion', async () => {
    const profile = await getCompanionProfileLogic(deps(), caller('seeker'), { uid: people.uid('neha') });
    expect(profile.displayName).toBe('neha');
  });

  it('gives the same "not found" for hidden, far away and missing people', async () => {
    for (const target of ['riya', 'far', 'nobody']) {
      await expectAppError(getCompanionProfileLogic(deps(), caller('seeker'), { uid: people.uid(target) }), 'not_found');
    }
  });
});

describe('savedCompanions', () => {
  it('returns saved companions newest first, skipping anyone no longer visible', async () => {
    const save = (name: string, at: number) =>
      sql`insert into saved_companions (uid, companion_uid, saved_at) values (${people.uid('seeker')}, ${people.uid(name)}, ${new Date(at)})`;
    await save('sam', 1);
    await save('neha', 2);
    await save('riya', 3);
    const { companions } = await savedCompanionsLogic(deps(), caller('seeker'));
    expect(people.names(companions)).toEqual(['neha', 'sam']);
  });
});

describe('updateMyLocation and the companion index', () => {
  it('stores the exact point privately and only a snapped point in the index', async () => {
    const exact = { lat: 19.06123, lng: 72.83321 };
    await updateMyLocationLogic(deps(), caller('neha'), { ...exact, accuracyM: 5 });
    const [stored] = await sql<{ lat: number; lng: number }[]>`select lat, lng from user_locations where uid = ${people.uid('neha')}`;
    expect(stored).toMatchObject(exact);
    const [index] = await sql<{ lat: number; lng: number }[]>`select lat, lng from companion_index where uid = ${people.uid('neha')}`;
    expect(index.lat).not.toBe(exact.lat);
    expect(distanceKm(exact, index)).toBeLessThan(0.4);
  });

  it('snaps exactly like the server code does', async () => {
    const { snapToGrid } = await import('../../src/domain/geo');
    const [index] = await sql<{ lat: number; lng: number }[]>`select lat, lng from companion_index where uid = ${people.uid('neha')}`;
    expect(index).toEqual(snapToGrid({ lat: 19.062, lng: 72.833 }, 500));
  });

  it('rejects an impossible jump', async () => {
    const later = new Date(NOW.getTime() + 60_000);
    await expectAppError(updateMyLocationLogic(deps({}, later), caller('seeker'), { lat: 28.6139, lng: 77.209, accuracyM: 5 }), 'invalid_input');
  });

  it('removes a companion from the index when their profile is gone', async () => {
    await sql`delete from companion_profiles where uid = ${people.uid('neha')}`;
    const rows = await sql`select 1 from companion_index where uid = ${people.uid('neha')}`;
    expect(rows).toHaveLength(0);
  });
});
