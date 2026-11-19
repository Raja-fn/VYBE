import type { IdentityVerificationService, IdvResult, IdvSessionInfo, IdvStep } from './identityVerificationService';

export interface ManualReviewOptions {
  sessionMinutes: number;
  now?: () => Date;
}

const PREFIX = 'manual';

/**
 * A person on the VYBE team checks every new member (launch decision).
 *
 * The selfie is only collected (it moves the person on to the ID photo); the
 * ID step stays "in review" until a reviewer approves or rejects the pair in
 * the review page (adminDecideVerification), comparing the selfie, the ID
 * and the date of birth the person typed.
 */
export class ManualReviewIdentityService implements IdentityVerificationService {
  readonly name = 'manual';

  constructor(private readonly options: ManualReviewOptions) {}

  async createSession(uid: string, step: IdvStep): Promise<IdvSessionInfo> {
    const now = this.options.now?.() ?? new Date();
    const providerRef = [PREFIX, uid, step, now.getTime().toString(36)].join(':');
    return { providerRef, step, expiresAt: new Date(now.getTime() + this.options.sessionMinutes * 60_000) };
  }

  async getResult(providerRef: string): Promise<IdvResult> {
    const [prefix, , step] = providerRef.split(':');
    if (prefix !== PREFIX || (step !== 'selfie' && step !== 'government_id')) {
      throw new Error(`Unknown verification session ${providerRef}`);
    }
    return { providerRef, step, decision: step === 'selfie' ? 'approved' : 'pending' };
  }
}
