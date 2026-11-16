import type { PgServer } from './globalSetup';

export default async function globalTeardown(): Promise<void> {
  await (globalThis as { __FINDX_PG__?: PgServer }).__FINDX_PG__?.stop();
}
