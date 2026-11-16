/** Venue slot generation. Pure, so the seed script and Phase 4 share it. */

export interface OpeningHours {
  /** ISO weekday: 1 = Monday ... 7 = Sunday. */
  weekday: number;
  /** "HH:mm" local time. */
  open: string;
  close: string;
}

export interface SlotTemplate {
  slotMinutes: number;
  tablesPerSlot: number;
  openingHours: OpeningHours[];
}

export interface GeneratedSlot {
  /** yyyyMMdd_HHmm in local time. */
  slotId: string;
  /** yyyy-MM-dd in local time. */
  dayKey: string;
  startAt: Date;
  endAt: Date;
  capacity: number;
}

/** UTC offset of `timeZone` at `at`, in minutes (Asia/Kolkata = 330). */
export function utcOffsetMinutes(timeZone: string, at: Date): number {
  const name = new Intl.DateTimeFormat('en-US', { timeZone, timeZoneName: 'longOffset' })
    .formatToParts(at)
    .find((part) => part.type === 'timeZoneName')?.value;
  const match = name?.match(/GMT([+-])(\d{2}):?(\d{2})?/);
  if (!match) return 0;
  const sign = match[1] === '-' ? -1 : 1;
  return sign * (Number(match[2]) * 60 + Number(match[3] ?? '0'));
}

function parseHm(hm: string): number {
  const [h, m] = hm.split(':').map(Number);
  return h * 60 + m;
}

const pad = (n: number) => String(n).padStart(2, '0');

/**
 * Slots for `days` local days starting with the local day containing `from`.
 * Slots that already started are skipped. A slot must end by closing time.
 */
export function buildSlots(template: SlotTemplate, from: Date, days: number, timeZone: string): GeneratedSlot[] {
  const offset = utcOffsetMinutes(timeZone, from);
  const localNow = new Date(from.getTime() + offset * 60_000);
  const slots: GeneratedSlot[] = [];

  for (let d = 0; d < days; d++) {
    const day = new Date(Date.UTC(localNow.getUTCFullYear(), localNow.getUTCMonth(), localNow.getUTCDate() + d));
    const isoWeekday = day.getUTCDay() === 0 ? 7 : day.getUTCDay();
    const dayKey = `${day.getUTCFullYear()}-${pad(day.getUTCMonth() + 1)}-${pad(day.getUTCDate())}`;

    for (const hours of template.openingHours.filter((h) => h.weekday === isoWeekday)) {
      const close = parseHm(hours.close);
      for (let start = parseHm(hours.open); start + template.slotMinutes <= close; start += template.slotMinutes) {
        const startAt = new Date(day.getTime() + (start - offset) * 60_000);
        if (startAt.getTime() <= from.getTime()) continue;
        slots.push({
          slotId: `${dayKey.replace(/-/g, '')}_${pad(Math.floor(start / 60))}${pad(start % 60)}`,
          dayKey,
          startAt,
          endAt: new Date(startAt.getTime() + template.slotMinutes * 60_000),
          capacity: template.tablesPerSlot,
        });
      }
    }
  }
  return slots;
}
