import { z } from 'zod';

import type { PushMessage } from '../services/push/pushService';
import type { Caller } from '../shared/callable';
import type { Deps } from './deps';

/** A person keeps notifications on at most this many phones. */
const MAX_TOKENS = 5;

/**
 * Sends a notification to everyone of [uid]'s phones. Never throws: a
 * notification that cannot be sent must not undo what just happened.
 */
export async function notify(deps: Pick<Deps, 'sql' | 'services'>, uid: string, message: PushMessage): Promise<void> {
  try {
    const [row] = await deps.sql<{ fcm_tokens: string[] }[]>`select fcm_tokens from private_profiles where id = ${uid}`;
    const tokens = row?.fcm_tokens ?? [];
    if (tokens.length === 0) return;
    const { invalidTokens } = await deps.services.push.send(tokens, message);
    if (invalidTokens.length > 0) {
      await deps.sql`
        update private_profiles
        set fcm_tokens = array(select t from unnest(fcm_tokens) as t where not t = any(${invalidTokens}::text[]))
        where id = ${uid}`;
    }
  } catch (error) {
    console.error('notify failed', error instanceof Error ? error.message : String(error));
  }
}

const tokenSchema = z.string().min(10).max(4096);

// ---------- registerPushToken ----------

export const registerPushTokenInput = z.object({ token: tokenSchema });

/**
 * This phone gets this person's notifications. A token moves with the phone:
 * it is taken off any other account that signed in on it before.
 */
export async function registerPushTokenLogic(
  deps: Deps,
  caller: Caller,
  input: z.infer<typeof registerPushTokenInput>,
): Promise<{ registered: true }> {
  await deps.sql.begin(async (tx) => {
    await tx`
      update private_profiles set fcm_tokens = array_remove(fcm_tokens, ${input.token})
      where ${input.token} = any(fcm_tokens) and id <> ${caller.uid}`;
    await tx`
      update private_profiles set fcm_tokens = (
        select coalesce(array_agg(t order by ord), '{}') from (
          select t, ord from unnest(array_append(array_remove(fcm_tokens, ${input.token}), ${input.token}))
            with ordinality as u(t, ord)
          order by ord desc limit ${MAX_TOKENS}
        ) latest)
      where id = ${caller.uid}`;
  });
  return { registered: true };
}

// ---------- unregisterPushToken ----------

export const unregisterPushTokenInput = z.object({ token: tokenSchema });

/** Signing out: this phone stops getting this person's notifications. */
export async function unregisterPushTokenLogic(
  deps: Deps,
  caller: Caller,
  input: z.infer<typeof unregisterPushTokenInput>,
): Promise<{ registered: false }> {
  await deps.sql`update private_profiles set fcm_tokens = array_remove(fcm_tokens, ${input.token}) where id = ${caller.uid}`;
  return { registered: false };
}
