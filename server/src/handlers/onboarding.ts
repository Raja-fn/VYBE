import { z } from 'zod';

import {
  ageOn,
  canStartStep,
  INITIAL_STEPS,
  overallStatus,
  type StepStatus,
  type VerificationStepName,
  type VerificationSteps,
} from '../domain/verification';
import { uidSchema, type Caller } from '../shared/callable';
import { asJson } from '../shared/db';
import { appError, ErrorCodes } from '../shared/errorCodes';
import { storageFileExists, type Deps } from './deps';

export const UNDERAGE_REASON = 'underage';

// ---------- acceptRules ----------

export const acceptRulesInput = z.object({
  rulesVersion: z.number().int(),
  ageConfirmed: z.literal(true),
});

/**
 * Records consent and, the first time, creates the member account:
 * user row, private row, credit account with the signup bonus, Free plan.
 * Idempotent: calling it again only refreshes the consent.
 */
export async function acceptRulesLogic(
  deps: Deps,
  caller: Caller,
  input: z.infer<typeof acceptRulesInput>,
): Promise<{ created: boolean }> {
  if (!caller.phoneNumber && !caller.verifiedEmail) {
    throw appError(ErrorCodes.invalidInput, 'Sign in with Google or a verified phone number first.');
  }
  if (input.rulesVersion !== deps.config.rulesVersion) {
    throw appError(ErrorCodes.invalidInput, 'Please review the latest rules.');
  }
  const { config } = deps;
  const now = deps.now();
  const consent = { rulesVersion: input.rulesVersion, ageConfirmed: true, acceptedAt: now.toISOString() };
  const uid = caller.uid;

  return deps.sql.begin(async (tx) => {
    // Insert-or-skip decides "first time" atomically, even for two calls at once.
    const inserted = await tx`
      insert into users (id, account_type, display_name, photo_paths, active_mode, consent, verification_status,
        verification_steps, verification_reason, age_years, account_status, created_at, updated_at)
      values (${uid}, 'member', null, '{}', 'seeker', ${tx.json(consent)}, 'pending',
        ${tx.json(asJson(INITIAL_STEPS))}, null, null, 'active', ${now}, ${now})
      on conflict (id) do nothing
      returning id`;
    if (inserted.length === 0) {
      const [user] = await tx<{ account_status: string }[]>`select account_status from users where id = ${uid} for update`;
      if (user.account_status === 'banned') throw appError(ErrorCodes.blocked, 'This account is suspended.');
      await tx`update users set consent = ${tx.json(consent)}, updated_at = ${now} where id = ${uid}`;
      return { created: false };
    }
    await tx`
      insert into private_profiles (id, phone_e164, email)
      values (${uid}, ${caller.phoneNumber ?? null}, ${caller.verifiedEmail ?? null})`;
    await tx`insert into credit_accounts (uid, balance, updated_at) values (${uid}, ${config.signupBonusCredits}, ${now})`;
    await tx`
      insert into credit_ledger (id, uid, delta, balance_after, reason, ref_type, ref_id, idempotency_key, created_at)
      values (${`signup_${uid}`}, ${uid}, ${config.signupBonusCredits}, ${config.signupBonusCredits}, 'signup_bonus',
        'user', ${uid}, ${`signup_${uid}`}, ${now})`;
    await tx`
      insert into subscriptions (uid, tier, status, auto_renew, updated_at) values (${uid}, 'free', 'active', false, ${now})`;
    return { created: true };
  });
}

// ---------- startVerification ----------

export const startVerificationInput = z.object({
  step: z.enum(['selfie', 'id']),
  documentType: z.enum(['aadhaar', 'passport', 'driving_licence']).optional(),
});

export interface StartVerificationResult {
  sessionId: string;
  uploadPath: string;
  expiresAt: string;
}

interface MemberRow {
  verification_steps: VerificationSteps;
  verification_reason: string | null;
  account_status: string;
}

async function loadMember(deps: Deps, uid: string): Promise<MemberRow> {
  const [user] = await deps.sql<MemberRow[]>`
    select verification_steps, verification_reason, account_status from users where id = ${uid}`;
  if (!user) throw appError(ErrorCodes.notFound, 'Accept the rules first.');
  if (user.account_status === 'banned') throw appError(ErrorCodes.blocked, 'This account is suspended.');
  return user;
}

export async function startVerificationLogic(
  deps: Deps,
  caller: Caller,
  input: z.infer<typeof startVerificationInput>,
): Promise<StartVerificationResult> {
  if (input.step === 'id' && !input.documentType) {
    throw appError(ErrorCodes.invalidInput, 'Choose an ID type.');
  }
  const user = await loadMember(deps, caller.uid);
  const permanentlyRejected = user.verification_reason === UNDERAGE_REASON;
  if (!canStartStep(user.verification_steps, input.step, permanentlyRejected)) {
    throw appError(ErrorCodes.invalidInput, 'This step is not available right now.');
  }

  const identity = deps.services.identity;
  const session = await identity.createSession(caller.uid, input.step === 'id' ? 'government_id' : 'selfie');
  const sessionId = crypto.randomUUID();
  const uploadPath = `verification/${caller.uid}/${sessionId}.jpg`;

  await deps.sql`
    insert into verification_sessions (id, uid, step, document_type, provider, provider_ref, status, upload_path,
      created_at, expires_at)
    values (${sessionId}, ${caller.uid}, ${input.step}, ${input.documentType ?? null}, ${identity.name},
      ${session.providerRef}, 'awaiting_upload', ${uploadPath}, ${deps.now()}, ${session.expiresAt})`;

  return { sessionId, uploadPath, expiresAt: session.expiresAt.toISOString() };
}

// ---------- submitVerification ----------

export const submitVerificationInput = z.object({ sessionId: uidSchema });

export interface SubmitVerificationResult {
  step: VerificationStepName;
  stepStatus: StepStatus;
  verificationStatus: 'pending' | 'approved' | 'rejected';
  reason: string | null;
}

interface SessionRow {
  uid: string;
  step: VerificationStepName;
  status: string;
  expires_at: Date;
  upload_path: string;
  provider_ref: string;
}

export async function submitVerificationLogic(
  deps: Deps,
  caller: Caller,
  input: z.infer<typeof submitVerificationInput>,
): Promise<SubmitVerificationResult> {
  const { sql } = deps;
  const [session] = await sql<SessionRow[]>`
    select uid, step, status, expires_at, upload_path, provider_ref
    from verification_sessions where id = ${input.sessionId}`;
  if (!session || session.uid !== caller.uid) throw appError(ErrorCodes.notFound, 'Unknown session.');
  if (session.status !== 'awaiting_upload') throw appError(ErrorCodes.invalidInput, 'This session is already used.');
  const now = deps.now();
  if (session.expires_at.getTime() <= now.getTime()) {
    throw appError(ErrorCodes.invalidInput, 'This session expired. Start again.');
  }
  if (!(await storageFileExists(sql, session.upload_path))) throw appError(ErrorCodes.invalidInput, 'Upload the photo first.');

  const step = session.step;
  const identity = deps.services.identity;
  const result = await identity.getResult(session.provider_ref);

  return sql.begin(async (tx) => {
    const [user] = await tx<{ verification_steps: VerificationSteps; verification_reason: string | null }[]>`
      select verification_steps, verification_reason from users where id = ${caller.uid} for update`;
    if (!user) throw appError(ErrorCodes.notFound, 'Accept the rules first.');
    // Claim the session inside the transaction so it can only be used once.
    const claimed = await tx`
      update verification_sessions set status = 'deciding'
      where id = ${input.sessionId} and status = 'awaiting_upload' returning id`;
    if (claimed.length === 0) throw appError(ErrorCodes.invalidInput, 'This session is already used.');

    const steps = { ...user.verification_steps };
    let stepStatus: StepStatus;
    let reason: string | null = null;
    let ageYears: number | null = null;
    let permanentlyRejected = user.verification_reason === UNDERAGE_REASON;

    if (result.decision === 'pending') {
      stepStatus = 'in_review';
    } else if (result.decision === 'rejected') {
      stepStatus = 'rejected';
      reason = result.reason ?? 'not_verified';
    } else if (step === 'id') {
      const dob = result.dateOfBirth;
      ageYears = dob ? ageOn(dob, now) : null;
      if (ageYears === null) {
        stepStatus = 'rejected';
        reason = 'no_date_of_birth';
      } else if (ageYears < deps.config.ageMinimum) {
        stepStatus = 'rejected';
        reason = UNDERAGE_REASON;
        permanentlyRejected = true;
      } else {
        stepStatus = 'approved';
      }
    } else {
      stepStatus = 'approved';
    }

    steps[step] = stepStatus;
    const verificationStatus = overallStatus(steps, permanentlyRejected);
    const finalReason = permanentlyRejected ? UNDERAGE_REASON : reason;
    const approvedAge = ageYears !== null && stepStatus === 'approved' ? ageYears : null;

    await tx`
      update users set
        verification_steps = ${tx.json(asJson(steps))},
        verification_status = ${verificationStatus},
        verification_reason = ${finalReason},
        age_years = coalesce(${approvedAge}::int, age_years),
        updated_at = ${now}
      where id = ${caller.uid}`;
    const idVerification = {
      provider: identity.name,
      providerRef: session.provider_ref,
      status: stepStatus,
      reviewedAt: now.toISOString(),
    };
    const dateOfBirth = step === 'id' && stepStatus === 'approved' ? (result.dateOfBirth ?? null) : null;
    await tx`
      update private_profiles set
        id_verification = ${tx.json(idVerification)},
        date_of_birth = coalesce(${dateOfBirth}::text, date_of_birth)
      where id = ${caller.uid}`;
    await tx`update verification_sessions set status = ${stepStatus}, decided_at = ${now} where id = ${input.sessionId}`;

    return { step, stepStatus, verificationStatus, reason: finalReason };
  });
}
