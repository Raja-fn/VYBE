import type { AppConfig } from '../config/appConfig';
import type { Services } from '../services/factory';
import type { Db } from '../shared/db';

/** Everything a handler needs. Tests build their own. */
export interface Deps {
  sql: Db;
  config: AppConfig;
  services: Services;
  now: () => Date;
}

/** Splits "bucket/object/name" into the storage bucket and object name. */
export function splitStoragePath(path: string): { bucket: string; name: string } {
  const slash = path.indexOf('/');
  return { bucket: path.slice(0, slash), name: path.slice(slash + 1) };
}

/** True when the file was uploaded to Supabase Storage. */
export async function storageFileExists(sql: Db, path: string): Promise<boolean> {
  const { bucket, name } = splitStoragePath(path);
  const rows = await sql`select 1 from storage.objects where bucket_id = ${bucket} and name = ${name} limit 1`;
  return rows.length > 0;
}
