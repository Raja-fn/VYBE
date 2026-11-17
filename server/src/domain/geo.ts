export interface LatLng {
  lat: number;
  lng: number;
}

const METERS_PER_DEGREE_LAT = 111_320;

/**
 * Snaps a point to a grid of roughly `meters` squares.
 *
 * Companion locations are snapped before any distance is computed, so a
 * seeker who calls discovery from many places cannot trilaterate the exact
 * position. The latitude is snapped first and the longitude step uses the
 * snapped latitude, so the result is deterministic.
 */
export function snapToGrid(point: LatLng, meters: number): LatLng {
  const latStep = meters / METERS_PER_DEGREE_LAT;
  const lat = Math.round(point.lat / latStep) * latStep;
  const lngStep = meters / (METERS_PER_DEGREE_LAT * Math.cos((lat * Math.PI) / 180));
  const lng = Math.round(point.lng / lngStep) * lngStep;
  return { lat: round6(lat), lng: round6(lng) };
}

const EARTH_RADIUS_KM = 6371;
const toRad = (degrees: number) => (degrees * Math.PI) / 180;

/** Great-circle distance in km (haversine). */
export function distanceKm(a: LatLng, b: LatLng): number {
  const dLat = toRad(b.lat - a.lat);
  const dLng = toRad(b.lng - a.lng);
  const h = Math.sin(dLat / 2) ** 2 + Math.cos(toRad(a.lat)) * Math.cos(toRad(b.lat)) * Math.sin(dLng / 2) ** 2;
  return 2 * EARTH_RADIUS_KM * Math.asin(Math.min(1, Math.sqrt(h)));
}

/**
 * The only distance another user ever sees: rounded to `stepKm`,
 * never below one step ("About 1 km").
 */
export function roundedDistanceKm(km: number, stepKm: number): number {
  return Math.max(stepKm, Math.round(km / stepKm) * stepKm);
}

function round6(value: number): number {
  return Math.round(value * 1e6) / 1e6;
}
