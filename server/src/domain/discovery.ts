import { distanceKm, roundedDistanceKm, type LatLng } from './geo';
import { isVisibleTo, type SeekerMatchProfile, type CompanionMatchProfile } from './matching';

/** One row of the server-only `companionLocations` index. */
export interface CompanionCandidate extends CompanionMatchProfile, LatLng {
  uid: string;
  planTypes: string[];
  isListed: boolean;
  verified: boolean;
  banned: boolean;
  freeNowUntil: Date | null;
}

export interface Seeker extends SeekerMatchProfile, LatLng {
  uid: string;
}

export interface VenuePoint extends LatLng {
  venueId: string;
}

export interface RankedCandidate {
  candidate: CompanionCandidate;
  /** Rounded; the only distance the seeker ever sees. */
  distanceKm: number;
  /** Verified venues with an open slot today within reach of both people. */
  spotsNearby: number;
  freeNow: boolean;
}

/**
 * Filters and orders discovery results. Pure, so every rule is unit-tested.
 *
 * Distances use the companion's snapped point, never an exact location.
 */
export function rankCandidates(input: {
  seeker: Seeker;
  candidates: CompanionCandidate[];
  blockedUids: ReadonlySet<string>;
  venues: VenuePoint[];
  planType: string | null;
  radiusKm: number;
  distanceStepKm: number;
  now: Date;
  limit: number;
}): RankedCandidate[] {
  const { seeker, radiusKm, now } = input;

  return input.candidates
    .filter((c) => c.uid !== seeker.uid && c.isListed && c.verified && !c.banned)
    .filter((c) => !input.blockedUids.has(c.uid))
    .filter((c) => input.planType === null || c.planTypes.includes(input.planType))
    .filter((c) => isVisibleTo(seeker, c))
    .map((c) => ({ candidate: c, exactKm: distanceKm(seeker, c) }))
    .filter(({ exactKm }) => exactKm <= radiusKm)
    .map(({ candidate, exactKm }) => ({
      candidate,
      exactKm,
      distanceKm: roundedDistanceKm(exactKm, input.distanceStepKm),
      spotsNearby: input.venues.filter((v) => distanceKm(seeker, v) <= radiusKm && distanceKm(candidate, v) <= radiusKm)
        .length,
      freeNow: candidate.freeNowUntil !== null && candidate.freeNowUntil.getTime() > now.getTime(),
    }))
    .sort((a, b) => Number(b.freeNow) - Number(a.freeNow) || a.exactKm - b.exactKm)
    .slice(0, input.limit)
    .map(({ candidate, distanceKm: km, spotsNearby, freeNow }) => ({ candidate, distanceKm: km, spotsNearby, freeNow }));
}

/** Rejects GPS jumps no person could make, to blunt location spoofing. */
export function isPlausibleMove(
  previous: (LatLng & { at: Date }) | null,
  next: LatLng & { at: Date },
  maxSpeedKmh: number,
): boolean {
  if (!previous) return true;
  const hours = (next.at.getTime() - previous.at.getTime()) / 3_600_000;
  if (hours <= 0) return distanceKm(previous, next) < 1;
  return distanceKm(previous, next) / hours <= maxSpeedKmh;
}
