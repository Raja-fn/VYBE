export type IdvStep = 'selfie' | 'government_id';
export type IdvDecision = 'pending' | 'approved' | 'rejected';

export interface IdvSessionInfo {
  providerRef: string;
  step: IdvStep;
  expiresAt: Date;
}

export interface IdvResult {
  providerRef: string;
  step: IdvStep;
  decision: IdvDecision;
  /** yyyy-MM-dd, read from the ID. Only set for an approved government_id. */
  dateOfBirth?: string;
  reason?: string;
}

/** Selfie liveness and government ID checks (provider not chosen yet). */
export interface IdentityVerificationService {
  /** Stored on each verification record, e.g. "fake". */
  readonly name: string;
  createSession(uid: string, step: IdvStep): Promise<IdvSessionInfo>;
  getResult(providerRef: string): Promise<IdvResult>;
}
