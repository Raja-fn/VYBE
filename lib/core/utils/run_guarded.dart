import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../backend/callable_client.dart';
import 'app_failure.dart';
import 'result.dart';

/// Runs [body] and converts any thrown error into an [Err].
///
/// Every repository method goes through this, so raw exceptions never reach
/// the UI.
Future<Result<T>> runGuarded<T>(Future<T> Function() body) async {
  try {
    return Ok(await body());
  } on Object catch (error, stack) {
    final failure = mapError(error);
    // Debug builds only: the real cause behind a friendly message.
    if (kDebugMode) debugPrint('VYBE failure: $failure | $error | $stack');
    return Err(failure);
  }
}

/// VYBE's own reasons, sent by the server in the error body's `code`.
/// Keep in sync with server/src/shared/errorCodes.ts.
const _serverCodes = <String, FailureKind>{
  'not_verified': FailureKind.notVerified,
  'insufficient_credits': FailureKind.insufficientCredits,
  'slot_full': FailureKind.slotFull,
  'blocked': FailureKind.blocked,
  'moderation_blocked': FailureKind.moderationBlocked,
  'rate_limited': FailureKind.rateLimited,
  'not_found': FailureKind.notFound,
  'invalid_input': FailureKind.invalidInput,
  'location_required': FailureKind.locationRequired,
  'companion_unavailable': FailureKind.companionUnavailable,
  'purchase_invalid': FailureKind.purchaseInvalid,
  'otp_wrong': FailureKind.wrongCode,
  'otp_expired': FailureKind.codeExpired,
  'otp_send_failed': FailureKind.otpSendFailed,
  'underage': FailureKind.underage,
};

/// Generic statuses of server actions.
const _statuses = <String, FailureKind>{
  'unavailable': FailureKind.network,
  'unauthenticated': FailureKind.unauthenticated,
  'permission-denied': FailureKind.permissionDenied,
  'not-found': FailureKind.notFound,
  'resource-exhausted': FailureKind.rateLimited,
  'invalid-argument': FailureKind.invalidInput,
};

/// Postgres error codes from direct table reads and writes.
const _postgresCodes = <String, FailureKind>{
  '42501': FailureKind.permissionDenied, // refused by row-level security or a grant
  'PGRST301': FailureKind.unauthenticated, // expired or invalid sign-in
  '23514': FailureKind.invalidInput, // a check constraint
  '22P02': FailureKind.invalidInput, // malformed value
};

AppFailure mapError(Object error) {
  if (error is AppFailure) return error;

  if (error is ServerException) {
    final kind = _serverCodes[error.code] ?? _statuses[error.status] ?? FailureKind.unknown;
    return AppFailure(kind, debugMessage: '${error.status}/${error.code}: ${error.message}');
  }

  if (error is PostgrestException) {
    return AppFailure(
      _postgresCodes[error.code] ?? FailureKind.unknown,
      debugMessage: 'postgrest/${error.code}: ${error.message}',
    );
  }

  if (error is AuthException) {
    final kind = switch (error.statusCode) {
      '429' => FailureKind.rateLimited,
      '401' || '403' => FailureKind.unauthenticated,
      _ when error is AuthRetryableFetchException => FailureKind.network,
      _ => FailureKind.unknown,
    };
    return AppFailure(kind, debugMessage: 'auth/${error.statusCode}/${error.code}: ${error.message}');
  }

  if (error is StorageException) {
    final kind = switch (error.statusCode) {
      '401' || '403' => FailureKind.permissionDenied,
      '413' => FailureKind.invalidInput,
      _ => FailureKind.unknown,
    };
    return AppFailure(kind, debugMessage: 'storage/${error.statusCode}: ${error.message}');
  }

  if (error is SocketException || error is TimeoutException || error is ClientException) {
    return AppFailure(FailureKind.network, debugMessage: '$error');
  }

  return AppFailure(FailureKind.unknown, debugMessage: '$error');
}
