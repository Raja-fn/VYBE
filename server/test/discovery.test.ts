import { freeSpanFor } from '../src/domain/availability';
import { isPlausibleMove, rankCandidates, type CompanionCandidate, type Seeker } from '../src/domain/discovery';
import {
  isVisibleTo,
  showMeIncludes,
  whoCanRequestIncludes,
  type Gender,
  type ShowMe,
  type WhoCanRequest,
} from '../src/domain/matching';

const genders: Gender[] = ['woman', 'man', 'non_binary', 'undisclosed'];

describe('matching', () => {
  it('"Show me" covers exactly the expected genders', () => {
    const table: Record<ShowMe, Gender[]> = {
      women: ['woman'],
      men: ['man'],
      everyone: genders,
    };
    for (const [showMe, expected] of Object.entries(table) as [ShowMe, Gender[]][]) {
      expect(genders.filter((g) => showMeIncludes(showMe, g))).toEqual(expected);
    }
  });

  it('"Who can request you" covers exactly the expected genders', () => {
    const table: Record<WhoCanRequest, Gender[]> = {
      women: ['woman'],
      men: ['man'],
      everyone: genders,
    };
    for (const [who, expected] of Object.entries(table) as [WhoCanRequest, Gender[]][]) {
      expect(genders.filter((g) => whoCanRequestIncludes(who, g))).toEqual(expected);
    }
  });

  const seeker = (gender: Gender, showMe: ShowMe) => ({ gender, showMe, ageMin: 21, ageMax: 35 });
  const companion = (gender: Gender, whoCanRequest: WhoCanRequest, ageYears = 25) => ({ gender, whoCanRequest, ageYears });

  it('needs both directions to agree', () => {
    expect(isVisibleTo(seeker('man', 'women'), companion('woman', 'everyone'))).toBe(true);
    expect(isVisibleTo(seeker('man', 'women'), companion('woman', 'women'))).toBe(false);
    expect(isVisibleTo(seeker('woman', 'everyone'), companion('man', 'women'))).toBe(true);
  });

  it('non-binary and undisclosed companions only appear to "Everyone" seekers', () => {
    for (const g of ['non_binary', 'undisclosed'] as Gender[]) {
      expect(isVisibleTo(seeker('man', 'everyone'), companion(g, 'everyone'))).toBe(true);
      expect(isVisibleTo(seeker('man', 'women'), companion(g, 'everyone'))).toBe(false);
      expect(isVisibleTo(seeker('man', 'men'), companion(g, 'everyone'))).toBe(false);
    }
  });

  it('non-binary and undisclosed seekers only reach "Everyone" companions', () => {
    for (const g of ['non_binary', 'undisclosed'] as Gender[]) {
      expect(isVisibleTo(seeker(g, 'everyone'), companion('woman', 'everyone'))).toBe(true);
      expect(isVisibleTo(seeker(g, 'everyone'), companion('woman', 'women'))).toBe(false);
      expect(isVisibleTo(seeker(g, 'everyone'), companion('man', 'men'))).toBe(false);
    }
  });

  it('respects the age range, inclusive', () => {
    expect(isVisibleTo(seeker('man', 'everyone'), companion('woman', 'everyone', 21))).toBe(true);
    expect(isVisibleTo(seeker('man', 'everyone'), companion('woman', 'everyone', 35))).toBe(true);
    expect(isVisibleTo(seeker('man', 'everyone'), companion('woman', 'everyone', 36))).toBe(false);
  });
});

describe('rankCandidates', () => {
  const now = new Date('2026-11-10T10:00:00Z');
  const seeker: Seeker = { uid: 's', lat: 19.0596, lng: 72.8295, gender: 'man', showMe: 'everyone', ageMin: 18, ageMax: 60 };
  const base: Omit<CompanionCandidate, 'uid' | 'lat' | 'lng'> = {
    gender: 'woman',
    whoCanRequest: 'everyone',
    ageYears: 25,
    planTypes: ['coffee'],
    isListed: true,
    verified: true,
    banned: false,
    freeNowUntil: null,
  };
  const at = (uid: string, lat: number, lng: number, extra: Partial<CompanionCandidate> = {}): CompanionCandidate => ({
    ...base,
    uid,
    lat,
    lng,
    ...extra,
  });
  const run = (candidates: CompanionCandidate[], extra: Partial<Parameters<typeof rankCandidates>[0]> = {}) =>
    rankCandidates({
      seeker,
      candidates,
      blockedUids: new Set(),
      venues: [],
      planType: null,
      radiusKm: 5,
      distanceStepKm: 1,
      now,
      limit: 20,
      ...extra,
    });

  it('drops self, unlisted, unverified, banned, blocked and far-away companions', () => {
    const result = run(
      [
        at('s', 19.06, 72.83),
        at('ok', 19.065, 72.83),
        at('unlisted', 19.06, 72.83, { isListed: false }),
        at('unverified', 19.06, 72.83, { verified: false }),
        at('banned', 19.06, 72.83, { banned: true }),
        at('blocked', 19.06, 72.83),
        at('far', 19.1176, 72.906),
      ],
      { blockedUids: new Set(['blocked']) },
    );
    expect(result.map((r) => r.candidate.uid)).toEqual(['ok']);
  });

  it('filters by plan type', () => {
    const result = run([at('coffee', 19.06, 72.83), at('walk', 19.06, 72.83, { planTypes: ['walk'] })], { planType: 'walk' });
    expect(result.map((r) => r.candidate.uid)).toEqual(['walk']);
  });

  it('puts "free now" first, then the nearest, and rounds the distance', () => {
    const result = run([
      at('near', 19.0605, 72.8295),
      at('farther-free', 19.08, 72.8295, { freeNowUntil: new Date('2026-11-10T12:00:00Z') }),
      at('expired-free', 19.061, 72.8295, { freeNowUntil: new Date('2026-11-10T09:00:00Z') }),
    ]);
    expect(result.map((r) => r.candidate.uid)).toEqual(['farther-free', 'near', 'expired-free']);
    expect(result.map((r) => r.distanceKm)).toEqual([2, 1, 1]);
    expect(result[0].freeNow).toBe(true);
    expect(result[2].freeNow).toBe(false);
  });

  it('counts only venues within reach of both people', () => {
    const venues = [
      { venueId: 'both', lat: 19.07, lng: 72.83 },
      { venueId: 'seeker-only', lat: 19.02, lng: 72.83 },
    ];
    const [result] = run([at('c', 19.1, 72.83)], { venues });
    expect(result.spotsNearby).toBe(1);
  });

  it('applies the limit', () => {
    expect(run([at('a', 19.06, 72.83), at('b', 19.06, 72.83)], { limit: 1 })).toHaveLength(1);
  });
});

describe('isPlausibleMove', () => {
  const t0 = new Date('2026-11-10T10:00:00Z');
  const bandra = { lat: 19.0596, lng: 72.8295 };
  const delhi = { lat: 28.6139, lng: 77.209 };

  it('allows the first location and normal travel', () => {
    expect(isPlausibleMove(null, { ...bandra, at: t0 }, 300)).toBe(true);
    expect(isPlausibleMove({ ...bandra, at: t0 }, { lat: 19.1, lng: 72.85, at: new Date(t0.getTime() + 600_000) }, 300)).toBe(true);
  });

  it('rejects teleporting across the country', () => {
    expect(isPlausibleMove({ ...bandra, at: t0 }, { ...delhi, at: new Date(t0.getTime() + 600_000) }, 300)).toBe(false);
  });
});

describe('freeSpanFor', () => {
  const tz = { timeZone: 'Asia/Kolkata', tonightStartHour: 18 };
  // 2026-11-10 is a Tuesday. 10:00 UTC = 15:30 IST.
  const now = new Date('2026-11-10T10:00:00Z');
  const availability = {
    weekly: [
      { weekday: 2, start: '16:00', end: '20:00' },
      { weekday: 3, start: '11:00', end: '13:00' },
    ],
    exceptions: [],
  };

  it('next 2 hours means "I am free now" is on', () => {
    const until = new Date('2026-11-10T11:00:00Z');
    expect(freeSpanFor('next_2h', { freeNowUntil: until, availability: null }, now, tz)).toEqual({ from: now, until });
    expect(freeSpanFor('next_2h', { freeNowUntil: null, availability }, now, tz)).toBeNull();
  });

  it('tonight clips today\'s hours to the evening', () => {
    const span = freeSpanFor('tonight', { freeNowUntil: null, availability }, now, tz);
    // 18:00 to 20:00 IST.
    expect(span).toEqual({ from: new Date('2026-11-10T12:30:00Z'), until: new Date('2026-11-10T14:30:00Z') });
  });

  it('tomorrow uses tomorrow\'s hours', () => {
    const span = freeSpanFor('tomorrow', { freeNowUntil: null, availability }, now, tz);
    expect(span).toEqual({ from: new Date('2026-11-11T05:30:00Z'), until: new Date('2026-11-11T07:30:00Z') });
  });

  it('a day marked unavailable never counts', () => {
    const blocked = { ...availability, exceptions: [{ dayKey: '2026-11-11', unavailable: true }] };
    expect(freeSpanFor('tomorrow', { freeNowUntil: null, availability: blocked }, now, tz)).toBeNull();
  });

  it('hours that already ended do not count for tonight', () => {
    const late = new Date('2026-11-10T15:00:00Z'); // 20:30 IST
    expect(freeSpanFor('tonight', { freeNowUntil: null, availability }, late, tz)).toBeNull();
  });
});
