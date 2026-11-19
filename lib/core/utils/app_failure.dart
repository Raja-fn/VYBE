import 'package:flutter/foundation.dart';

/// Every kind of failure the UI can show a message for.
///
/// Server error codes (the error body's `code`) map 1:1 to
/// these values; see `functions/src/shared/errorCodes.ts`.
enum FailureKind {
  network,
  offline,
  unauthenticated,
  permissionDenied,
  notVerified,
  insufficientCredits,
  slotFull,
  blocked,
  moderationBlocked,
  notFound,
  rateLimited,
  invalidInput,

  /// The server has no location for this person yet.
  locationRequired,

  /// Location is switched off or VYBE is not allowed to use it.
  locationDenied,

  /// The companion is not free (or already booked) at that time.
  companionUnavailable,

  /// The SMS code was not right.
  wrongCode,

  /// The SMS code is too old; a new one is needed.
  codeExpired,

  /// The person closed the Google account picker.
  signInCanceled,

  /// Google sign-in is not set up for this build (missing SHA fingerprint
  /// or Google web client id is not set up).
  googleSignInUnavailable,

  /// The login SMS could not be sent.
  otpSendFailed,

  /// The store could not confirm a purchase.
  purchaseInvalid,

  /// Below the minimum age (18).
  underage,

  /// Google Play / the App Store cannot be reached on this device.
  storeUnavailable,
  unknown,
}

@immutable
class AppFailure {
  const AppFailure(this.kind, {this.debugMessage});

  final FailureKind kind;

  /// For logs and Crashlytics only. Never shown to users.
  final String? debugMessage;

  @override
  bool operator ==(Object other) => other is AppFailure && other.kind == kind;

  @override
  int get hashCode => kind.hashCode;

  @override
  String toString() => 'AppFailure(${kind.name}${debugMessage == null ? '' : ': $debugMessage'})';
}
