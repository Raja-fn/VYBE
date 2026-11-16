import { readdirSync, readFileSync, rmSync } from 'node:fs';
import { join } from 'node:path';

import postgres from 'postgres';

import { TEST_DB_PORT, TEST_DB_URL } from './connection';

export interface PgServer {
  initialise(): Promise<void>;
  start(): Promise<void>;
  stop(): Promise<void>;
}

const dataDir = join(process.env.TEMP ?? process.env.TMP ?? '/tmp', 'findx-pg-test');

/**
 * Starts a throwaway Postgres for the database tests, then applies the
 * Supabase stand-in and every migration in supabase/migrations, in order.
 */
export default async function globalSetup(): Promise<void> {
  rmSync(dataDir, { recursive: true, force: true });
  // ESM-only package: a real dynamic import (not rewritten to require).
  const load = new Function('m', 'return import(m)') as (m: string) => Promise<{ default: new (o: object) => PgServer }>;
  const EmbeddedPostgres = (await load('embedded-postgres')).default;
  const pg = new EmbeddedPostgres({ databaseDir: dataDir, user: 'postgres', password: 'postgres', port: TEST_DB_PORT, persistent: false, onLog: () => {} });
  await pg.initialise();
  await pg.start();
  (globalThis as { __FINDX_PG__?: PgServer }).__FINDX_PG__ = pg;

  const sql = postgres(TEST_DB_URL, { onnotice: () => {} });
  try {
    await sql.unsafe(readFileSync(join(__dirname, 'supabaseShim.sql'), 'utf8'));
    const dir = join(__dirname, '..', '..', '..', 'supabase', 'migrations');
    for (const file of readdirSync(dir).filter((f) => f.endsWith('.sql')).sort()) {
      try {
        await sql.unsafe(readFileSync(join(dir, file), 'utf8'));
      } catch (error) {
        throw new Error(`Migration ${file} failed: ${String(error)}`);
      }
    }
  } finally {
    await sql.end();
  }
}
