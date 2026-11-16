import { createHash } from 'node:crypto';

/**
 * The fixed account id of a seeded test person (`c_neha`, `s_aarav`, ...),
 * so re-seeding updates the same accounts. A valid version-4 style uuid made
 * from the name; no real account can collide with it in practice.
 */
export function seedUid(name: string): string {
  const hex = createHash('sha256').update(`findx-seed:${name}`).digest('hex').slice(0, 32).split('');
  hex[12] = '4';
  hex[16] = ((parseInt(hex[16], 16) & 0x3) | 0x8).toString(16);
  const h = hex.join('');
  return `${h.slice(0, 8)}-${h.slice(8, 12)}-${h.slice(12, 16)}-${h.slice(16, 20)}-${h.slice(20)}`;
}
