import { z } from 'zod';

import { appError, ErrorCodes } from './errorCodes';

export interface Caller {
  uid: string;
  /** Set only for phone login, from server-written account metadata. */
  phoneNumber: string | undefined;
  /** Set only when Supabase Auth confirmed the address (Google, or a test account). */
  verifiedEmail?: string;
}

/** Validates request input against a zod schema. */
export function parseInput<T extends z.ZodType>(schema: T, data: unknown): z.infer<T> {
  const parsed = schema.safeParse(data ?? {});
  if (!parsed.success) throw appError(ErrorCodes.invalidInput, parsed.error.issues.map((i) => i.message).join('; '));
  return parsed.data;
}

/** A user id (Supabase Auth uuid). */
export const uidSchema = z.string().regex(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i, 'Unknown person.');
