import type { Sql } from './db';
import { appError, ErrorCodes } from './errorCodes';

/**
 * Fixed-window rate limit stored in `rate_limits` (server-only).
 * Throws `rate_limited` once `limit` calls happen inside `windowMs`.
 * One statement, so concurrent calls cannot both slip through.
 */
export async function consumeRateLimit(sql: Sql, key: string, limit: number, windowMs: number, now: Date): Promise<void> {
  const windowStartBefore = new Date(now.getTime() - windowMs);
  const [row] = await sql<{ count: number }[]>`
    insert into rate_limits as r (key, window_start, count) values (${key}, ${now}, 1)
    on conflict (key) do update set
      window_start = case when r.window_start <= ${windowStartBefore} then ${now} else r.window_start end,
      count = case when r.window_start <= ${windowStartBefore} then 1 else r.count + 1 end
    returning count`;
  if (row.count > limit) throw appError(ErrorCodes.rateLimited, 'Too many requests. Wait a moment.');
}
