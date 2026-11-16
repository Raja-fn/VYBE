/** Verification state rules. Pure, so they are unit-tested without Firebase. */

export type StepStatus = 'not_started' | 'in_review' | 'approved' | 'rejected';
export type VerificationStatus = 'pending' | 'approved' | 'rejected';
export type VerificationStepName = 'selfie' | 'id';

export interface VerificationSteps {
  phone: StepStatus;
  selfie: StepStatus;
  id: StepStatus;
}

export const INITIAL_STEPS: VerificationSteps = {
  phone: 'approved',
  selfie: 'not_started',
  id: 'not_started',
};

/**
 * Overall status. Approved only when every step is approved.
 * `permanentlyRejected` (for example under 18) can never be retried.
 */
export function overallStatus(steps: VerificationSteps, permanentlyRejected: boolean): VerificationStatus {
  if (permanentlyRejected) return 'rejected';
  if (steps.phone === 'approved' && steps.selfie === 'approved' && steps.id === 'approved') return 'approved';
  return 'pending';
}

/** Steps run in order: the ID check starts only after the selfie is approved. */
export function canStartStep(steps: VerificationSteps, step: VerificationStepName, permanentlyRejected: boolean): boolean {
  if (permanentlyRejected) return false;
  if (steps[step] === 'approved' || steps[step] === 'in_review') return false;
  if (step === 'id') return steps.selfie === 'approved';
  return steps.phone === 'approved';
}

/** Age in whole years on `on`, from a yyyy-MM-dd date of birth. */
export function ageOn(dateOfBirth: string, on: Date): number {
  const [y, m, d] = dateOfBirth.split('-').map(Number);
  let age = on.getUTCFullYear() - y;
  if (on.getUTCMonth() + 1 < m || (on.getUTCMonth() + 1 === m && on.getUTCDate() < d)) age -= 1;
  return age;
}
