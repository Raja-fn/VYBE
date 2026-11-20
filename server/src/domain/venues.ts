import { distanceKm, type LatLng } from './geo';
import { popularityLabel, type PopularityLabel } from '../services/places/placesPopularityService';

export interface VenueCandidate extends LatLng {
  venueId: string;
  planTypes: string[];
  /** Picked by the VYBE team: suggested before the others. */
  featured?: boolean;
}

export interface RankedVenue<T extends VenueCandidate> {
  venue: T;
  /** Exact, rounded to 0.1 km: venue locations are public. */
  distanceKm: number;
  popularityScore: number;
  popularityLabel: PopularityLabel;
  rank: number;
}

/**
 * "Best spots to meet": venues within reach of the seeker (and of the
 * companion, when one is chosen), optionally for one plan. Featured spots
 * come first, then by popularity, then distance.
 */
export function rankVenues<T extends VenueCandidate>(input: {
  venues: T[];
  seeker: LatLng;
  companion: LatLng | null;
  planType: string | null;
  radiusKm: number;
  scores: ReadonlyMap<string, number>;
  thresholds: { hot: number; busy: number };
}): RankedVenue<T>[] {
  return input.venues
    .filter((v) => input.planType === null || v.planTypes.includes(input.planType))
    .map((venue) => ({ venue, exact: distanceKm(input.seeker, venue) }))
    .filter(({ venue, exact }) => exact <= input.radiusKm && (!input.companion || distanceKm(input.companion, venue) <= input.radiusKm))
    .map(({ venue, exact }) => {
      const score = input.scores.get(venue.venueId) ?? 0;
      return { venue, exact, score };
    })
    .sort((a, b) => Number(b.venue.featured ?? false) - Number(a.venue.featured ?? false) || b.score - a.score || a.exact - b.exact)
    .map(({ venue, exact, score }, i) => ({
      venue,
      distanceKm: Math.round(exact * 10) / 10,
      popularityScore: Math.round(score * 100) / 100,
      popularityLabel: popularityLabel(score, input.thresholds),
      rank: i + 1,
    }));
}
