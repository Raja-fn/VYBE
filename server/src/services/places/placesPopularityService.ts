export interface PopularityInput {
  venueId: string;
  lat: number;
  lng: number;
}

export interface PopularityScore {
  venueId: string;
  /** 0 (quiet) to 1 (hottest). */
  score: number;
}

/** How busy a public place usually is at a given time (provider not chosen yet). */
export interface PlacesPopularityService {
  getPopularity(venues: PopularityInput[], at: Date): Promise<PopularityScore[]>;
}

export type PopularityLabel = 'hot' | 'busy' | 'quiet';

/** Maps a score to the heatmap legend using AppConfig thresholds. */
export function popularityLabel(score: number, thresholds: { hot: number; busy: number }): PopularityLabel {
  if (score >= thresholds.hot) return 'hot';
  if (score >= thresholds.busy) return 'busy';
  return 'quiet';
}
