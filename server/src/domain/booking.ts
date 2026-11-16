import { localDay, type AvailabilityDoc } from './availability';
import { utcOffsetMinutes } from './slots';

/** Booking states (spec §7). There is deliberately no "expired": requests never expire. */
export type BookingStatus =
  | 'requested'
  | 'accepted'
  | 'declined'
  | 'cancelled'
  | 'checked_in'
  | 'completed'
  | 'disputed';

/** States that hold a table and the two people's time. */
export const ACTIVE_STATUSES: readonly BookingStatus[] = ['requested', 'accepted', 'checked_in'];

export interface TimeSpan {
  startAt: Date;
  endAt: Date;
}

export function overlaps(a: TimeSpan, b: TimeSpan): boolean {
  return a.startAt.getTime() < b.endAt.getTime() && b.startAt.getTime() < a.endAt.getTime();
}

const minutesOf = (hm: string) => {
  const [h, m] = hm.split(':').map(Number);
  return h * 60 + m;
};

/**
 * Whether the companion is free for the whole slot: either "I am free now"
 * covers it, or it sits inside their weekly hours for that day (and the day
 * is not marked unavailable).
 */
export function companionCovers(
  slot: TimeSpan,
  input: { freeNowUntil: Date | null; availability: AvailabilityDoc | null },
  now: Date,
  timeZone: string,
): boolean {
  if (input.freeNowUntil && slot.startAt.getTime() >= now.getTime() - 60_000 && slot.endAt <= input.freeNowUntil) {
    return true;
  }
  const availability = input.availability;
  if (!availability) return false;

  const offset = utcOffsetMinutes(timeZone, slot.startAt);
  const localStart = new Date(slot.startAt.getTime() + offset * 60_000);
  const startMin = localStart.getUTCHours() * 60 + localStart.getUTCMinutes();
  const endMin = startMin + Math.round((slot.endAt.getTime() - slot.startAt.getTime()) / 60_000);
  const day = localDay(slot.startAt, 0, timeZone);
  if (availability.exceptions.some((e) => e.dayKey === day.dayKey && e.unavailable)) return false;

  return availability.weekly.some(
    (w) => w.weekday === day.weekday && minutesOf(w.start) <= startMin && minutesOf(w.end) >= endMin,
  );
}

export type SlotState = 'available' | 'past' | 'closed' | 'full' | 'companion_unavailable';

/** What the seeker can do with one venue slot for one companion. */
export function slotState(input: {
  slot: TimeSpan & { capacity: number; booked: number; status: string };
  now: Date;
  companionFree: boolean;
  companionBusy: boolean;
}): SlotState {
  const { slot } = input;
  if (slot.startAt.getTime() <= input.now.getTime()) return 'past';
  if (slot.status === 'closed') return 'closed';
  if (slot.booked >= slot.capacity) return 'full';
  if (!input.companionFree || input.companionBusy) return 'companion_unavailable';
  return 'available';
}

/**
 * The seeker may cancel while the meetup has not started. Credits are never
 * refunded (owner decision); cancelling only frees the table.
 */
export function canSeekerCancel(status: BookingStatus, startAt: Date, now: Date): boolean {
  return (status === 'requested' || status === 'accepted') && startAt.getTime() > now.getTime();
}
