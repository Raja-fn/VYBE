import type { LatLng } from '../../domain/geo';

/** A public place that can be a meeting spot. */
export interface PublicPlace {
  /** Stable id, e.g. `osm-node-123`. */
  venueId: string;
  name: string;
  category: 'cafe' | 'restaurant' | 'food_court' | 'cinema' | 'mall' | 'open_park' | 'theatre';
  planTypes: string[];
  addressLine: string;
  lat: number;
  lng: number;
}

/** Where public places come from. Behind an interface for tests. */
export interface PublicPlacesSource {
  /** Places within [radiusKm] of [center]. Throws when the source is unreachable. */
  nearby(center: LatLng, radiusKm: number): Promise<PublicPlace[]>;
}

/** Test project and tests: no outside calls. */
export class NoPublicPlaces implements PublicPlacesSource {
  async nearby(): Promise<PublicPlace[]> {
    return [];
  }
}

/** What each kind of place is good for. Only public, alcohol-free kinds are fetched. */
const KINDS: { filter: string; max: number; category: PublicPlace['category']; planTypes: string[] }[] = [
  { filter: '["amenity"="cafe"]', max: 60, category: 'cafe', planTypes: ['coffee'] },
  { filter: '["amenity"="restaurant"]', max: 60, category: 'restaurant', planTypes: ['dinner'] },
  { filter: '["amenity"="food_court"]', max: 20, category: 'food_court', planTypes: ['dinner', 'coffee'] },
  { filter: '["amenity"="cinema"]', max: 20, category: 'cinema', planTypes: ['movie'] },
  { filter: '["shop"="mall"]', max: 20, category: 'mall', planTypes: ['walk', 'coffee'] },
  { filter: '["leisure"="park"]', max: 30, category: 'open_park', planTypes: ['walk'] },
  { filter: '["amenity"~"^(theatre|arts_centre)$"]', max: 20, category: 'theatre', planTypes: ['event'] },
];

interface OsmElement {
  type: 'node' | 'way' | 'relation';
  id: number;
  lat?: number;
  lon?: number;
  center?: { lat: number; lon: number };
  tags?: Record<string, string>;
}

/** Builds the Overpass query: each kind capped separately, named places only. */
export function overpassQuery(center: LatLng, radiusKm: number, timeoutSeconds: number): string {
  const around = `(around:${Math.round(radiusKm * 1000)},${center.lat.toFixed(5)},${center.lng.toFixed(5)})`;
  const parts = KINDS.map((k) => `nwr${k.filter}["name"]${around};out center ${k.max};`);
  return `[out:json][timeout:${Math.ceil(timeoutSeconds)}];\n${parts.join('\n')}`;
}

/** Names that only say what the place is ("Cafe", "Park"): not useful as a spot name. */
const GENERIC_NAMES = new Set([
  'cafe', 'café', 'coffee', 'coffee shop', 'restaurant', 'hotel', 'dhaba', 'food court', 'cinema', 'theatre', 'theater',
  'mall', 'park', 'garden', 'playground', 'auditorium', 'arts centre', 'canteen', 'tea stall', 'tea shop',
]);

/** Turns Overpass elements into places (unnamed, generic, unpositioned or private ones are dropped). */
export function placesFromOsm(elements: OsmElement[]): PublicPlace[] {
  const places = new Map<string, PublicPlace>();
  for (const el of elements) {
    const tags = el.tags ?? {};
    const name = tags.name?.trim();
    const lat = el.lat ?? el.center?.lat;
    const lng = el.lon ?? el.center?.lon;
    if (!name || lat === undefined || lng === undefined) continue;
    if (GENERIC_NAMES.has(name.toLowerCase())) continue;
    if (tags.access === 'private' || tags.access === 'no') continue;
    const kind = KINDS.find((k) => matches(k.filter, tags));
    if (!kind) continue;
    const address = [tags['addr:street'], tags['addr:suburb'] ?? tags['addr:neighbourhood'], tags['addr:city']]
      .filter((p): p is string => !!p && p.trim().length > 0)
      .join(', ');
    const venueId = `osm-${el.type}-${el.id}`;
    places.set(venueId, {
      venueId,
      name: name.slice(0, 80),
      category: kind.category,
      planTypes: kind.planTypes,
      addressLine: address.slice(0, 120),
      lat,
      lng,
    });
  }
  return [...places.values()];
}

function matches(filter: string, tags: Record<string, string>): boolean {
  const m = /^\["(\w+)"(=|~)"([^"]+)"\]$/.exec(filter);
  if (!m) return false;
  const value = tags[m[1]];
  if (value === undefined) return false;
  return m[2] === '=' ? value === m[3] : new RegExp(m[3]).test(value);
}

/** Public Overpass servers, tried in order (the main one is often busy). */
export const OVERPASS_ENDPOINTS = [
  'https://overpass-api.de/api/interpreter',
  'https://overpass.private.coffee/api/interpreter',
  'https://overpass.kumi.systems/api/interpreter',
];

export interface OpenStreetMapOptions {
  endpoints?: string[];
  timeoutSeconds: number;
  fetchFn?: typeof fetch;
}

/** Public places from OpenStreetMap through the Overpass API (free, no key). */
export class OpenStreetMapPlaces implements PublicPlacesSource {
  constructor(private readonly options: OpenStreetMapOptions) {}

  async nearby(center: LatLng, radiusKm: number): Promise<PublicPlace[]> {
    const fetchFn = this.options.fetchFn ?? fetch;
    const body = new URLSearchParams({ data: overpassQuery(center, radiusKm, this.options.timeoutSeconds) }).toString();
    const errors: string[] = [];
    for (const endpoint of this.options.endpoints ?? OVERPASS_ENDPOINTS) {
      try {
        const response = await fetchFn(endpoint, {
          method: 'POST',
          headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'User-Agent': 'VYBE-server/1.0' },
          body,
          signal: AbortSignal.timeout(this.options.timeoutSeconds * 1000),
        });
        if (!response.ok) {
          errors.push(`HTTP ${response.status}`);
          continue;
        }
        const json = (await response.json()) as { elements?: OsmElement[] };
        return placesFromOsm(json.elements ?? []);
      } catch (error) {
        errors.push(String(error));
      }
    }
    throw new Error(`OpenStreetMap places failed: ${errors.join('; ')}`);
  }
}
