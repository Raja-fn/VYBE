import { distanceKm, roundedDistanceKm, snapToGrid } from '../src/domain/geo';
import { buildSlots, utcOffsetMinutes } from '../src/domain/slots';

describe('snapToGrid', () => {
  const bandra = { lat: 19.0596, lng: 72.8295 };

  it('moves a point by at most about half the grid diagonal', () => {
    const snapped = snapToGrid(bandra, 500);
    expect(distanceKm(bandra, snapped)).toBeLessThanOrEqual(0.36);
  });

  it('maps nearby points in the same cell to the same location', () => {
    const a = snapToGrid({ lat: 19.06001, lng: 72.83001 }, 500);
    const b = snapToGrid({ lat: 19.06003, lng: 72.83003 }, 500);
    expect(a).toEqual(b);
  });

  it('is idempotent', () => {
    const once = snapToGrid(bandra, 500);
    expect(snapToGrid(once, 500)).toEqual(once);
  });
});

describe('roundedDistanceKm', () => {
  it('never shows less than one step', () => {
    expect(roundedDistanceKm(0.2, 1)).toBe(1);
  });

  it('rounds to the nearest step', () => {
    expect(roundedDistanceKm(1.4, 1)).toBe(1);
    expect(roundedDistanceKm(1.6, 1)).toBe(2);
    expect(roundedDistanceKm(4.7, 1)).toBe(5);
  });
});

describe('buildSlots', () => {
  const template = {
    slotMinutes: 60,
    tablesPerSlot: 3,
    openingHours: [1, 2, 3, 4, 5, 6, 7].map((weekday) => ({ weekday, open: '09:00', close: '12:00' })),
  };

  it('knows the India offset', () => {
    expect(utcOffsetMinutes('Asia/Kolkata', new Date('2026-11-10T00:00:00Z'))).toBe(330);
  });

  it('creates slots in local time with the right capacity and ids', () => {
    // 2026-11-10 02:00 UTC = 07:30 IST, before opening.
    const slots = buildSlots(template, new Date('2026-11-10T02:00:00Z'), 1, 'Asia/Kolkata');
    expect(slots.map((s) => s.slotId)).toEqual(['20261110_0900', '20261110_1000', '20261110_1100']);
    expect(slots[0].startAt.toISOString()).toBe('2026-11-10T03:30:00.000Z');
    expect(slots[0].endAt.toISOString()).toBe('2026-11-10T04:30:00.000Z');
    expect(slots.every((s) => s.capacity === 3 && s.dayKey === '2026-11-10')).toBe(true);
  });

  it('skips slots that already started', () => {
    // 04:00 UTC = 09:30 IST: the 09:00 slot has started.
    const slots = buildSlots(template, new Date('2026-11-10T04:00:00Z'), 1, 'Asia/Kolkata');
    expect(slots.map((s) => s.slotId)).toEqual(['20261110_1000', '20261110_1100']);
  });

  it('covers the requested number of days and only open weekdays', () => {
    const mondaysOnly = { ...template, openingHours: [{ weekday: 1, open: '09:00', close: '10:00' }] };
    // 2026-11-10 is a Tuesday; the next Monday is 2026-11-16.
    const slots = buildSlots(mondaysOnly, new Date('2026-11-10T02:00:00Z'), 7, 'Asia/Kolkata');
    expect(slots.map((s) => s.slotId)).toEqual(['20261116_0900']);
  });

  it('does not create a slot that would run past closing', () => {
    const slots = buildSlots({ ...template, slotMinutes: 90 }, new Date('2026-11-10T02:00:00Z'), 1, 'Asia/Kolkata');
    expect(slots.map((s) => s.slotId)).toEqual(['20261110_0900', '20261110_1030']);
  });
});
