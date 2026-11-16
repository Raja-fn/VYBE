/**
 * Content classification for chat text (explicit content).
 *
 * Contact-detail blocking (phone numbers, emails, handles, links) is FindX's
 * own rule set and lives in the chat domain (Phase 5), not in a provider.
 */
export type ModerationVerdict = { allowed: true } | { allowed: false; reason: 'explicit' };

export interface ModerationService {
  checkText(text: string): Promise<ModerationVerdict>;
}
