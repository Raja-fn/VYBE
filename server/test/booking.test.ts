import { canCancel, companionCovers, overlaps, slotState } from '../src/domain/booking';
import { rankVenues } from '../src/domain/venues';

const TZ = 'Asia/Kolkata';
// 2026-11-10 is a Tuesday (weekday 2). 10:00 UTC = 15:30 IST.
const NOW = new Date('2026-11-10T10:00:00Z');
const ist = (hm: string, day = '2026-11-10') => new Date(`${day}T${hm}:00+05:30`);
const span = (from: string, to: string, day?: string) => ({ startAt: ist(from, day), endAt: ist(to, day) });

describe('overlaps', () => {
  it('detects any shared minute but not touching edges', () => {
    expect(overlaps(span('16:00', '17:00'), span('16:30', '17:30'))).toBe(true);
    expect(overlaps(span('16:00', '17:00'), span('17:00', '18:00'))).toBe(false);
    expect(overlaps(span('16:00', '18:00'), span('16:30', '17:00'))).toBe(true);
  });
});

describe('companionCovers', () => {
  const weekly = { weekly: [{ weekday: 2, start: '16:00', end: '20:00' }], exceptions: [] };

  it('covers a slot inside the weekly hours', () => {
    expect(companionCovers(span('17:00', '18:00'), { freeNowUntil: null, availability: weekly }, NOW, TZ)).toBe(true);
  });

  it('does not cover a slot that runs past the hours', () => {
    expect(companionCovers(span('19:30', '20:30'), { freeNowUntil: null, availability: weekly }, NOW, TZ)).toBe(false);
  });

  it('does not cover another weekday or a day marked unavailable', () => {
    expect(companionCovers(span('17:00', '18:00', '2026-11-11'), { freeNowUntil: null, availability: weekly }, NOW, TZ)).toBe(false);
    const off = { ...weekly, exceptions: [{ dayKey: '2026-11-10', unavailable: true }] };
    expect(companionCovers(span('17:00', '18:00'), { freeNowUntil: null, availability: off }, NOW, TZ)).toBe(false);
  });

  it('"free now" covers slots that end before it runs out', () => {
    const until = ist('17:30');
    expect(companionCovers(span('16:00', '17:00'), { freeNowUntil: until, availability: null }, NOW, TZ)).toBe(true);
    expect(companionCovers(span('17:00', '18:00'), { freeNowUntil: until, availability: null }, NOW, TZ)).toBe(false);
  });
});

describe('slotState', () => {
  const base = { ...span('17:00', '18:00'), capacity: 3, booked: 0, status: 'open' };
  const state = (overrides: Partial<typeof base>, companionFree = true, companionBusy = false) =>
    slotState({ slot: { ...base, ...overrides }, now: NOW, companionFree, companionBusy });

  it('is available when open, in the future, with a free companion', () => {
    expect(state({})).toBe('available');
  });

  it('reports why a slot cannot be booked, most fundamental reason first', () => {
    expect(state({ ...span('15:00', '16:00') })).toBe('past');
    expect(state({ status: 'closed' })).toBe('closed');
    expect(state({ booked: 3 })).toBe('full');
    expect(state({}, false)).toBe('companion_unavailable');
    expect(state({}, true, true)).toBe('companion_unavailable');
  });
});

describe('canCancel', () => {
  it('only before the meetup starts, and only while requested or accepted', () => {
    expect(canCancel('requested', ist('17:00'), NOW)).toBe(true);
    expect(canCancel('accepted', ist('17:00'), NOW)).toBe(true);
    expect(canCancel('requested', ist('15:00'), NOW)).toBe(false);
    for (const status of ['declined', 'cancelled', 'checked_in', 'completed', 'disputed'] as const) {
      expect(canCancel(status, ist('17:00'), NOW)).toBe(false);
    }
  });
});

describe('rankVenues', () => {
  const seeker = { lat: 19.0596, lng: 72.8295 };
  const venues = [
    { venueId: 'near-quiet', lat: 19.06, lng: 72.83, planTypes: ['coffee'] },
    { venueId: 'hot', lat: 19.07, lng: 72.835, planTypes: ['coffee', 'dinner'] },
    { venueId: 'far', lat: 19.1176, lng: 72.906, planTypes: ['coffee'] },
    { venueId: 'park', lat: 19.065, lng: 72.823, planTypes: ['walk'] },
  ];
  const scores = new Map([
    ['near-quiet', 0.1],
    ['hot', 0.9],
    ['far', 1],
    ['park', 0.5],
  ]);
  const run = (extra: Partial<Parameters<typeof rankVenues>[0]> = {}) =>
    rankVenues({ venues, seeker, companion: null, planType: null, radiusKm: 5, scores, thresholds: { hot: 0.7, busy: 0.4 }, ...extra });

  it('ranks by popularity, labels hot / busy / quiet, and drops venues beyond 5 km', () => {
    const result = run();
    expect(result.map((r) => [r.venue.venueId, r.popularityLabel, r.rank])).toEqual([
      ['hot', 'hot', 1],
      ['park', 'busy', 2],
      ['near-quiet', 'quiet', 3],
    ]);
    expect(result[2].distanceKm).toBe(0.1);
  });

  it('filters by plan', () => {
    expect(run({ planType: 'walk' }).map((r) => r.venue.venueId)).toEqual(['park']);
  });

  it('keeps only venues the companion can also reach', () => {
    const companion = { lat: 19.02, lng: 72.83 }; // ~4.4 km south of the seeker
    expect(run({ companion }).map((r) => r.venue.venueId)).toEqual(['near-quiet']);
  });
});
