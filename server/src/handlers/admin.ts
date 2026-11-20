import { z } from 'zod';

import type { AuthAdmin } from '../services/auth/authAdmin';
import { ageOn, overallStatus, type VerificationSteps } from '../domain/verification';
import { uidSchema } from '../shared/callable';
import { asJson } from '../shared/db';
import { appError, ErrorCodes } from '../shared/errorCodes';
import type { Deps } from './deps';
import { UNDERAGE_REASON } from './onboarding';
import { notify } from './push';

/** What the admin panel's actions need: the usual deps plus signed links to private files. */
export interface AdminDeps extends Deps {
  /** A link to a private storage file ("bucket/name") that works for [seconds]. */
  signUrl(path: string, seconds: number): Promise<string>;
  /** Deletes accounts and stored files. */
  authAdmin: AuthAdmin;
  /** Who on the team is acting (the name typed into the panel), for the activity log. */
  actor: string;
}

const LINK_SECONDS = 15 * 60;

// ---------- adminReviewQueue ----------

export const adminReviewQueueInput = z.object({});

export interface ReviewItem {
  uid: string;
  displayName: string;
  email: string | null;
  phone: string | null;
  /** What the person typed when signing up. */
  dateOfBirth: string | null;
  ageFromDateOfBirth: number | null;
  documentType: string | null;
  submittedAt: string;
  selfieUrl: string | null;
  idUrl: string | null;
  profilePhotoUrl: string | null;
}

/** New members waiting for a person to check their selfie and ID, oldest first. */
export async function adminReviewQueueLogic(deps: AdminDeps): Promise<{ items: ReviewItem[] }> {
  const now = deps.now();
  const rows = await deps.sql<
    {
      id: string;
      display_name: string | null;
      photo_paths: string[];
      updated_at: Date;
      email: string | null;
      phone_e164: string | null;
      date_of_birth: string | null;
    }[]
  >`
    select u.id, u.display_name, u.photo_paths, u.updated_at, p.email, p.phone_e164, p.date_of_birth
    from users u join private_profiles p on p.id = u.id
    where u.account_status = 'active' and u.verification_steps ->> 'id' = 'in_review'
    order by u.updated_at
    limit 50`;

  const sign = async (path: string | null | undefined) => {
    if (!path) return null;
    try {
      return await deps.signUrl(path, LINK_SECONDS);
    } catch {
      return null;
    }
  };

  const items = await Promise.all(
    rows.map(async (row) => {
      const sessions = await deps.sql<{ step: string; upload_path: string; document_type: string | null }[]>`
        select step, upload_path, document_type from verification_sessions
        where uid = ${row.id} and status in ('approved', 'in_review')
        order by created_at desc`;
      const selfie = sessions.find((s) => s.step === 'selfie');
      const id = sessions.find((s) => s.step === 'id');
      const [selfieUrl, idUrl, profilePhotoUrl] = await Promise.all([
        sign(selfie?.upload_path),
        sign(id?.upload_path),
        sign(row.photo_paths?.[0]),
      ]);
      return {
        uid: row.id,
        displayName: row.display_name ?? '',
        email: row.email,
        phone: row.phone_e164,
        dateOfBirth: row.date_of_birth,
        ageFromDateOfBirth: row.date_of_birth ? ageOn(row.date_of_birth, now) : null,
        documentType: id?.document_type ?? null,
        submittedAt: row.updated_at.toISOString(),
        selfieUrl,
        idUrl,
        profilePhotoUrl,
      };
    }),
  );
  return { items };
}

// ---------- adminDecideVerification ----------

export const adminDecideVerificationInput = z.object({
  uid: uidSchema,
  decision: z.enum(['approve', 'reject_selfie', 'reject_id']),
  /** The date of birth on the ID, when it differs from what the person typed. */
  dateOfBirth: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/)
    .optional(),
  note: z.string().max(300).optional(),
});

/**
 * A reviewer's decision.
 * - approve: the person is verified; their age comes from the date of birth
 *   (under the minimum age means a permanent rejection).
 * - reject_selfie: they take a new selfie, then a new ID photo.
 * - reject_id: they take a new ID photo.
 */
export async function adminDecideVerificationLogic(
  deps: AdminDeps,
  input: z.infer<typeof adminDecideVerificationInput>,
): Promise<{ verificationStatus: string }> {
  const now = deps.now();
  const outcome = await deps.sql.begin(async (tx) => {
    const [user] = await tx<{ verification_steps: VerificationSteps }[]>`
      select verification_steps from users where id = ${input.uid} for update`;
    if (!user) throw appError(ErrorCodes.notFound, 'No such member.');
    if (user.verification_steps.id !== 'in_review') {
      throw appError(ErrorCodes.invalidInput, 'This member is not waiting for review (already decided?).');
    }
    const [privateRow] = await tx<{ date_of_birth: string | null }[]>`
      select date_of_birth from private_profiles where id = ${input.uid}`;

    const steps: VerificationSteps = { ...user.verification_steps };
    let reason: string | null = null;
    let ageYears: number | null = null;
    let permanentlyRejected = false;
    const dateOfBirth = input.dateOfBirth ?? privateRow?.date_of_birth ?? null;

    if (input.decision === 'approve') {
      if (!dateOfBirth) throw appError(ErrorCodes.invalidInput, 'Enter the date of birth from the ID.');
      ageYears = ageOn(dateOfBirth, now);
      if (ageYears < deps.config.ageMinimum) {
        steps.id = 'rejected';
        reason = UNDERAGE_REASON;
        permanentlyRejected = true;
      } else {
        steps.selfie = 'approved';
        steps.id = 'approved';
      }
    } else if (input.decision === 'reject_selfie') {
      steps.selfie = 'rejected';
      steps.id = 'not_started';
      reason = 'selfie_rejected';
    } else {
      steps.id = 'rejected';
      reason = 'id_rejected';
    }

    const verificationStatus = overallStatus(steps, permanentlyRejected);
    await tx`
      update users set
        verification_steps = ${tx.json(asJson(steps))},
        verification_status = ${verificationStatus},
        verification_reason = ${reason},
        age_years = coalesce(${verificationStatus === 'approved' ? ageYears : null}::int, age_years),
        updated_at = ${now}
      where id = ${input.uid}`;
    await tx`
      update private_profiles set
        date_of_birth = coalesce(${dateOfBirth}::text, date_of_birth),
        id_verification = ${tx.json({ provider: 'manual', status: steps.id, reviewedAt: now.toISOString() })}
      where id = ${input.uid}`;
    await tx`
      update verification_sessions set status = ${steps.id === 'approved' ? 'approved' : 'rejected'}, decided_at = ${now}
      where uid = ${input.uid} and status = 'in_review'`;
    await tx`
      insert into admin_audit (action, actor, details, at)
      values (${`verification_${input.decision}`}, ${deps.actor},
        ${tx.json({ uid: input.uid, dateOfBirth, note: input.note ?? null, result: verificationStatus })}, ${now})`;
    return { verificationStatus, reason };
  });

  const message =
    outcome.verificationStatus === 'approved'
      ? { title: "You're verified", body: 'Welcome to VYBE. Start exploring people near you.', route: '/discover' }
      : outcome.reason === UNDERAGE_REASON
        ? null
        : {
            title: 'Please retake your photo',
            body:
              outcome.reason === 'selfie_rejected'
                ? 'We could not match your selfie. Take a new one in good light.'
                : 'We could not read your ID. Take a new, clear photo of it.',
            route: '/onboarding/verify',
          };
  if (message) await notify(deps, input.uid, message);
  return { verificationStatus: outcome.verificationStatus };
}
