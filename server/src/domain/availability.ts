import { utcOffsetMinutes } from './slots';

/** "Free right now" filter chips. */
export type FreeWindow = 'next_2h' | 'tonight' | 'tomorrow';

export interface WeeklyAvailability {
  /** ISO weekday: 1 = Monday ... 7 = Sunday. */
  weekday: number;
  /** "HH:mm" local time. */
  start: string;
  end: string;
}

export interface AvailabilityDoc {
  weekly: WeeklyAvailability[];
  exceptions: { dayKey: string; unavailable: boolean }[];
}

export interface FreeSpan {
  from: Date;
  until: Date;
}

const toMinutes = (hm: string) => {
  const [h, m] = hm.split(':').map(Number);
  return h * 60 + m;
};

const pad = (n: number) => String(n).padStart(2, '0');

/** Local calendar day `dayOffset` days after the local day containing `now`. */
export function localDay(now: Date, dayOffset: number, timeZone: string) {
  const offset = utcOffsetMinutes(timeZone, now);
  const local = new Date(now.getTime() + offset * 60_000);
  const day = new Date(Date.UTC(local.getUTCFullYear(), local.getUTCMonth(), local.getUTCDate() + dayOffset));
  const weekday = day.getUTCDay() === 0 ? 7 : day.getUTCDay();
  const dayKey = `${day.getUTCFullYear()}-${pad(day.getUTCMonth() + 1)}-${pad(day.getUTCDate())}`;
  /** Converts minutes after local midnight of this day to a UTC instant. */
  const at = (minutes: number) => new Date(day.getTime() + (minutes - offset) * 60_000);
  return { weekday, dayKey, at };
}

/**
 * When a companion is free within the chosen window, or null.
 *
 * - next_2h: they switched on "I am free now" and it has not expired.
 * - tonight: today's weekly hours overlap the evening (from `tonightStartHour`)
 *   and have not ended yet.
 * - tomorrow: they have weekly hours tomorrow.
 * A day marked unavailable in `exceptions` never counts.
 */
export function freeSpanFor(
  window: FreeWindow,
  input: { freeNowUntil: Date | null; availability: AvailabilityDoc | null },
  now: Date,
  options: { timeZone: string; tonightStartHour: number },
): FreeSpan | null {
  if (window === 'next_2h') {
    const until = input.freeNowUntil;
    return until && until.getTime() > now.getTime() ? { from: now, until } : null;
  }

  const availability = input.availability;
  if (!availability) return null;
  const day = localDay(now, window === 'tonight' ? 0 : 1, options.timeZone);
  if (availability.exceptions.some((e) => e.dayKey === day.dayKey && e.unavailable)) return null;

  const spans = availability.weekly
    .filter((w) => w.weekday === day.weekday)
    .map((w) => ({ from: day.at(toMinutes(w.start)), until: day.at(toMinutes(w.end)) }))
    .map((span) => {
      if (window !== 'tonight') return span;
      const eveningStart = day.at(options.tonightStartHour * 60);
      const from = new Date(Math.max(span.from.getTime(), eveningStart.getTime(), now.getTime()));
      return { from, until: span.until };
    })
    .filter((span) => span.until.getTime() > span.from.getTime())
    .sort((a, b) => a.from.getTime() - b.from.getTime());

  return spans[0] ?? null;
}
