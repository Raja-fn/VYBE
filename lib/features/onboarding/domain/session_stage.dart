import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'account.dart';

/// The signed-in user as far as the app cares.
class AuthUser {
  const AuthUser({required this.uid, this.phoneNumber, this.email});

  final String uid;

  /// Set after a phone login.
  final String? phoneNumber;

  /// Set after a Google login.
  final String? email;

  @override
  bool operator ==(Object other) =>
      other is AuthUser && other.uid == uid && other.phoneNumber == phoneNumber && other.email == email;

  @override
  int get hashCode => Object.hash(uid, phoneNumber, email);
}

/// Where the person is in getting set up. Drives every redirect.
sealed class SessionStage {
  const SessionStage();
}

final class SignedOut extends SessionStage {
  const SignedOut();
}

/// Phone verified, but the account (consent + user doc) is not created yet.
final class NeedsAccount extends SessionStage {
  const NeedsAccount(this.user);

  final AuthUser user;
}

final class NeedsVerification extends SessionStage {
  const NeedsVerification(this.account);

  final Account account;
}

final class Suspended extends SessionStage {
  const Suspended(this.account);

  final Account account;
}

final class NeedsPreferences extends SessionStage {
  const NeedsPreferences(this.account);

  final Account account;
}

final class Ready extends SessionStage {
  const Ready(this.account);

  final Account account;
}

/// Combines the auth user, account doc and preferences into one stage.
///
/// Pure, so every combination is unit-tested.
AsyncValue<SessionStage> deriveSessionStage({
  required AsyncValue<AuthUser?> user,
  required AsyncValue<Account?> Function(String uid) account,
  required AsyncValue<bool> Function(String uid) hasPreferences,
}) {
  if (user.hasError) return AsyncError(user.error!, user.stackTrace ?? StackTrace.empty);
  if (!user.hasValue) return const AsyncLoading();
  final authUser = user.requireValue;
  if (authUser == null) return const AsyncData(SignedOut());

  final accountValue = account(authUser.uid);
  if (accountValue.hasError) return AsyncError(accountValue.error!, accountValue.stackTrace ?? StackTrace.empty);
  if (!accountValue.hasValue) return const AsyncLoading();
  final acc = accountValue.requireValue;
  if (acc == null) return AsyncData(NeedsAccount(authUser));
  if (acc.isSuspended) return AsyncData(Suspended(acc));
  if (!acc.isVerified) return AsyncData(NeedsVerification(acc));

  final prefs = hasPreferences(authUser.uid);
  if (prefs.hasError) return AsyncError(prefs.error!, prefs.stackTrace ?? StackTrace.empty);
  if (!prefs.hasValue) return const AsyncLoading();
  return AsyncData(prefs.requireValue ? Ready(acc) : NeedsPreferences(acc));
}
