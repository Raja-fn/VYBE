/** One notification to one person's phones. */
export interface PushMessage {
  title: string;
  body: string;
  /** Where the app opens when the notification is tapped, e.g. "/bookings". */
  route: string;
}

/** Sends notifications to device tokens. */
export interface PushService {
  /** Returns the tokens the push service no longer knows (app removed, signed out), to forget them. */
  send(tokens: readonly string[], message: PushMessage): Promise<{ invalidTokens: string[] }>;
}

/** No push credentials configured: nothing is sent, nothing fails. */
export class NoPush implements PushService {
  async send(): Promise<{ invalidTokens: string[] }> {
    return { invalidTokens: [] };
  }
}

/** Tests: records what would have been sent. */
export class FakePushService implements PushService {
  readonly sent: { tokens: string[]; message: PushMessage }[] = [];
  invalid = new Set<string>();

  async send(tokens: readonly string[], message: PushMessage): Promise<{ invalidTokens: string[] }> {
    this.sent.push({ tokens: [...tokens], message });
    return { invalidTokens: tokens.filter((t) => this.invalid.has(t)) };
  }
}
