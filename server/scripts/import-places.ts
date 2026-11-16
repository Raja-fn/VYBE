/**
 * Turns the places extracted from OpenStreetMap into SQL files that load them
 * as venues (same rules as the server: placesFromOsm).
 *
 *   python -E -P tool/places/extract_osm_places.py india-latest.osm.pbf places.jsonl
 *   npx tsx server/scripts/import-places.ts places.jsonl <out dir>
 *   for f in <out dir>/*.sql; do npx supabase db query --linked --yes -f "$f"; done
 *
 * Re-running updates names and positions. A place a venue partner has claimed
 * (source = partner) is never changed.
 */
import { createReadStream, mkdirSync, rmSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { createInterface } from 'node:readline';

import { placesFromOsm, type PublicPlace } from '../src/services/places/publicPlacesSource';

const BATCH = 4000;
const TAG = '$findx_places$';

export function batchSql(places: PublicPlace[]): string {
  const rows = places.map((p) => ({
    id: p.venueId,
    name: p.name,
    category: p.category,
    address_line: p.addressLine,
    lat: p.lat,
    lng: p.lng,
    plan_types: p.planTypes,
  }));
  const json = JSON.stringify(rows);
  if (json.includes(TAG)) throw new Error('Place data contains the SQL quote tag.');
  return `insert into public.venues (id, owner_uid, name, category, address_line, lat, lng, plan_types,
  verification_status, is_listed, source, updated_at)
select r.id, null, r.name, r.category, r.address_line, r.lat, r.lng, r.plan_types, 'verified', true, 'osm', now()
from jsonb_to_recordset(${TAG}${json}${TAG}::jsonb)
  as r (id text, name text, category text, address_line text, lat double precision, lng double precision, plan_types text[])
on conflict (id) do update set
  name = excluded.name, category = excluded.category, address_line = excluded.address_line,
  lat = excluded.lat, lng = excluded.lng, plan_types = excluded.plan_types, updated_at = excluded.updated_at
where venues.source = 'osm';
`;
}

async function main(input: string, outDir: string) {
  const elements = [];
  const lines = createInterface({ input: createReadStream(input, 'utf-8'), crlfDelay: Infinity });
  for await (const line of lines) if (line.trim()) elements.push(JSON.parse(line));
  const places = placesFromOsm(elements);

  rmSync(outDir, { recursive: true, force: true });
  mkdirSync(outDir, { recursive: true });
  let files = 0;
  for (let i = 0; i < places.length; i += BATCH) {
    writeFileSync(join(outDir, `places-${String(++files).padStart(3, '0')}.sql`), batchSql(places.slice(i, i + BATCH)));
  }
  const byKind: Record<string, number> = {};
  for (const p of places) byKind[p.category] = (byKind[p.category] ?? 0) + 1;
  console.log(`${elements.length} OSM elements -> ${places.length} places in ${files} SQL files`, byKind);
}

const [input, outDir] = process.argv.slice(2);
if (!input || !outDir) {
  console.error('Usage: npx tsx server/scripts/import-places.ts <places.jsonl> <out dir>');
  process.exit(1);
}
main(input, outDir).catch((error) => {
  console.error(error);
  process.exit(1);
});
