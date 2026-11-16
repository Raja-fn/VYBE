/** Sends a one-time login code by SMS. */
export interface OtpSender {
  /** [phoneE164] is a validated Indian number, e.g. +919876543210. Throws if the SMS was not accepted. */
  send(phoneE164: string, code: string): Promise<void>;
}

export class OtpSendError extends Error {}
