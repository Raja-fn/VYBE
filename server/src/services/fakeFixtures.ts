import { seedUid } from './seedIds';

/** Fixed inputs for the fake services (test project and tests). Never used in production. */

/** Accounts whose fake selfie / ID checks are rejected: the seeded "Nikhil" (u_rejected). */
export const FAKE_REJECTED_UIDS: ReadonlySet<string> = new Set([seedUid('u_rejected')]);

/** Text the fake moderation service flags as explicit. */
export const FAKE_MODERATION_TERMS: readonly string[] = ['fake-explicit-term'];

/** Date of birth the fake "reads" from a new user's ID. */
export const FAKE_DEFAULT_DATE_OF_BIRTH = '2000-01-15';

export function fakeDateOfBirthFor(_uid: string): string {
  return FAKE_DEFAULT_DATE_OF_BIRTH;
}
