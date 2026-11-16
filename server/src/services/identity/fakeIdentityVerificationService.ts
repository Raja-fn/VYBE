import type {
  IdentityVerificationService,
  IdvResult,
  IdvSessionInfo,
  IdvStep,
} from './identityVerificationService';

export interface FakeIdvOptions {
  sessionMinutes: number;
  now?: () => Date;
  /** Users whose checks are rejected. */
  rejectUids?: ReadonlySet<string>;
  /** Date of birth the fake "reads" from each user's ID. */
  dateOfBirthFor: (uid: string) => string;
}

const PREFIX = 'fake-idv';

/**
 * Emulator stand-in: decides instantly and deterministically.
 *
 * Stateless (Cloud Functions instances share no memory), so the uid and step
 * are encoded in the provider reference itself.
 */
export class FakeIdentityVerificationService implements IdentityVerificationService {
  readonly name = 'fake';

  constructor(private readonly options: FakeIdvOptions) {}

  async createSession(uid: string, step: IdvStep): Promise<IdvSessionInfo> {
    const now = this.options.now?.() ?? new Date();
    const providerRef = [PREFIX, uid, step, now.getTime().toString(36)].join(':');
    return { providerRef, step, expiresAt: new Date(now.getTime() + this.options.sessionMinutes * 60_000) };
  }

  async getResult(providerRef: string): Promise<IdvResult> {
    const [prefix, uid, step] = providerRef.split(':');
    if (prefix !== PREFIX || !uid || (step !== 'selfie' && step !== 'government_id')) {
      throw new Error(`Unknown verification session ${providerRef}`);
    }
    if (this.options.rejectUids?.has(uid)) {
      return { providerRef, step, decision: 'rejected', reason: 'fake_rejection' };
    }
    return {
      providerRef,
      step,
      decision: 'approved',
      ...(step === 'government_id' ? { dateOfBirth: this.options.dateOfBirthFor(uid) } : {}),
    };
  }
}
