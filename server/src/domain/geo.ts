import { distanceBetween, geohashForLocation } from 'geofire-common';

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

/** Great-circle distance in km. */
export function distanceKm(a: LatLng, b: LatLng): number {
  return distanceBetween([a.lat, a.lng], [b.lat, b.lng]);
}

/**
 * The only distance another user ever sees: rounded to `stepKm`,
 * never below one step ("About 1 km").
 */
export function roundedDistanceKm(km: number, stepKm: number): number {
  return Math.max(stepKm, Math.round(km / stepKm) * stepKm);
}

export function geohashFor(point: LatLng): string {
  return geohashForLocation([point.lat, point.lng]);
}

function round6(value: number): number {
  return Math.round(value * 1e6) / 1e6;
}
