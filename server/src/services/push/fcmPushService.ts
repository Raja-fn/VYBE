import { ServiceAccountToken, type ServiceAccountKey } from '../google/serviceAccountToken';
import type { PushMessage, PushService } from './pushService';

export interface FcmOptions {
  serviceAccount: ServiceAccountKey & { project_id: string };
  fetchFn?: typeof fetch;
  now?: () => Date;
}

/** Firebase Cloud Messaging (HTTP v1), with a service account of the Firebase project. */
export class FcmPushService implements PushService {
  private readonly token: ServiceAccountToken;
  private readonly fetchFn: typeof fetch;

  constructor(private readonly options: FcmOptions) {
    this.fetchFn = options.fetchFn ?? fetch;
    this.token = new ServiceAccountToken(
      options.serviceAccount,
      'https://www.googleapis.com/auth/firebase.messaging',
      this.fetchFn,
      options.now,
      'notifications',
    );
  }

  async send(tokens: readonly string[], message: PushMessage): Promise<{ invalidTokens: string[] }> {
    if (tokens.length === 0) return { invalidTokens: [] };
    const access = await this.token.get();
    const url = `https://fcm.googleapis.com/v1/projects/${encodeURIComponent(this.options.serviceAccount.project_id)}/messages:send`;
    const results = await Promise.all(
      tokens.map(async (token) => {
        const response = await this.fetchFn(url, {
          method: 'POST',
          headers: { Authorization: `Bearer ${access}`, 'Content-Type': 'application/json' },
          body: JSON.stringify({
            message: {
              token,
              notification: { title: message.title, body: message.body },
              data: { route: message.route },
              android: { priority: 'high' },
            },
          }),
        });
        // 404 UNREGISTERED / 400 bad token: the app was removed or the token is stale.
        return response.status === 404 || response.status === 400 ? token : null;
      }),
    );
    return { invalidTokens: results.filter((t): t is string => t !== null) };
  }
}
