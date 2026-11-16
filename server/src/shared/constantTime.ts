import { timingSafeEqual } from 'node:crypto';

/**
 * Compares two secrets without leaking where they differ. Works in Node and
 * in the Supabase Edge runtime (no Buffer needed).
 */
export function sameSecret(a: string, b: string): boolean {
  const left = new TextEncoder().encode(a);
  const right = new TextEncoder().encode(b);
  return left.length === right.length && timingSafeEqual(left, right);
}
