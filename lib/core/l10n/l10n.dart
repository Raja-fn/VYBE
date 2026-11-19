import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import '../utils/app_failure.dart';

export '../../l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// The user-facing message for a failure.
String failureMessage(AppLocalizations l10n, AppFailure failure) {
  return switch (failure.kind) {
    FailureKind.network => l10n.failureNetwork,
    FailureKind.offline => l10n.failureOffline,
    FailureKind.unauthenticated => l10n.failureUnauthenticated,
    FailureKind.permissionDenied => l10n.failurePermissionDenied,
    FailureKind.notVerified => l10n.failureNotVerified,
    FailureKind.insufficientCredits => l10n.failureInsufficientCredits,
    FailureKind.slotFull => l10n.failureSlotFull,
    FailureKind.blocked => l10n.failureBlocked,
    FailureKind.moderationBlocked => l10n.failureModerationBlocked,
    FailureKind.notFound => l10n.failureNotFound,
    FailureKind.rateLimited => l10n.failureRateLimited,
    FailureKind.invalidInput => l10n.failureInvalidInput,
    FailureKind.locationRequired => l10n.failureLocationRequired,
    FailureKind.locationDenied => l10n.failureLocationDenied,
    FailureKind.companionUnavailable => l10n.failureCompanionUnavailable,
    FailureKind.wrongCode => l10n.failureWrongCode,
    FailureKind.codeExpired => l10n.failureCodeExpired,
    FailureKind.otpSendFailed => l10n.failureOtpSendFailed,
    FailureKind.signInCanceled => l10n.failureSignInCanceled,
    FailureKind.googleSignInUnavailable => l10n.failureGoogleSignInUnavailable,
    FailureKind.purchaseInvalid => l10n.failurePurchaseInvalid,
    FailureKind.underage => l10n.failureUnderage,
    FailureKind.storeUnavailable => l10n.failureStoreUnavailable,
    FailureKind.unknown => l10n.failureUnknown,
  };
}
