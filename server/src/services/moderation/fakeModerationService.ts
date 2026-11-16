import type { ModerationService, ModerationVerdict } from './moderationService';

/** Emulator stand-in: flags text containing any of the given test terms. */
export class FakeModerationService implements ModerationService {
  private readonly terms: string[];

  constructor(blockedTerms: readonly string[]) {
    this.terms = blockedTerms.map((t) => t.toLowerCase());
  }

  async checkText(text: string): Promise<ModerationVerdict> {
    const lower = text.toLowerCase();
    return this.terms.some((term) => lower.includes(term)) ? { allowed: false, reason: 'explicit' } : { allowed: true };
  }
}
