import type { PlacesPopularityService, PopularityInput, PopularityScore } from './placesPopularityService';

/**
 * Emulator stand-in: a stable pseudo-random score per venue and hour, so the
 * heatmap looks lived-in and tests are repeatable.
 */
export class FakePlacesPopularityService implements PlacesPopularityService {
  async getPopularity(venues: PopularityInput[], at: Date): Promise<PopularityScore[]> {
    const hour = at.getUTCHours();
    return venues.map((venue) => ({ venueId: venue.venueId, score: hashToUnit(`${venue.venueId}:${hour}`) }));
  }
}

/** FNV-1a hash mapped to [0, 1). */
function hashToUnit(input: string): number {
  let hash = 0x811c9dc5;
  for (let i = 0; i < input.length; i++) {
    hash ^= input.charCodeAt(i);
    hash = Math.imul(hash, 0x01000193);
  }
  return (hash >>> 0) / 0x1_0000_0000;
}
