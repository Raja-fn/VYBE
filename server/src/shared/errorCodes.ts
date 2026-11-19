/**
 * Error codes sent to the app in the error body's `code`.
 * Keep in sync with `_serverCodes` in lib/core/utils/run_guarded.dart.
 */
export const ErrorCodes = {
  notVerified: 'not_verified',
  insufficientCredits: 'insufficient_credits',
  slotFull: 'slot_full',
  blocked: 'blocked',
  moderationBlocked: 'moderation_blocked',
  rateLimited: 'rate_limited',
  notFound: 'not_found',
  invalidInput: 'invalid_input',
  locationRequired: 'location_required',
  companionUnavailable: 'companion_unavailable',
  purchaseInvalid: 'purchase_invalid',
  otpWrong: 'otp_wrong',
  otpExpired: 'otp_expired',
  otpSendFailed: 'otp_send_failed',
  underage: 'underage',
} as const;

export type ErrorCode = (typeof ErrorCodes)[keyof typeof ErrorCodes];

/** Generic statuses the app understands (same names the app used with Firebase). */
export type ErrorStatus =
  | 'invalid-argument'
  | 'failed-precondition'
  | 'permission-denied'
  | 'unauthenticated'
  | 'not-found'
  | 'resource-exhausted'
  | 'unavailable'
  | 'internal';

export const httpStatusFor: Record<ErrorStatus, number> = {
  'invalid-argument': 400,
  'failed-precondition': 412,
  'permission-denied': 403,
  unauthenticated: 401,
  'not-found': 404,
  'resource-exhausted': 429,
  unavailable: 503,
  internal: 500,
};

const statusFor: Record<ErrorCode, ErrorStatus> = {
  not_verified: 'failed-precondition',
  insufficient_credits: 'failed-precondition',
  slot_full: 'failed-precondition',
  blocked: 'permission-denied',
  moderation_blocked: 'invalid-argument',
  rate_limited: 'resource-exhausted',
  not_found: 'not-found',
  invalid_input: 'invalid-argument',
  location_required: 'failed-precondition',
  companion_unavailable: 'failed-precondition',
  purchase_invalid: 'failed-precondition',
  otp_wrong: 'invalid-argument',
  otp_expired: 'failed-precondition',
  otp_send_failed: 'unavailable',
  underage: 'failed-precondition',
};

/** An error the app is meant to see. Anything else becomes "internal". */
export class AppError extends Error {
  constructor(
    readonly status: ErrorStatus,
    message: string,
    readonly code: ErrorCode | null = null,
  ) {
    super(message);
  }
}

/** Builds an error the app maps to a typed failure. */
export function appError(code: ErrorCode, message: string): AppError {
  return new AppError(statusFor[code], message, code);
}
