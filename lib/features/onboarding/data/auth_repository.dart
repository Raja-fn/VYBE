import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import '../../../core/backend/callable_client.dart';
import '../../../core/utils/app_failure.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/run_guarded.dart';
import '../domain/session_stage.dart';

/// Result of asking for a one-time code.
sealed class OtpRequest {
  const OtpRequest();
}

/// A code was sent by SMS.
final class OtpCodeSent extends OtpRequest {
  const OtpCodeSent({required this.verificationId, this.resendToken});

  final String verificationId;
  final int? resendToken;
}

/// Sign-in (Google now; phone OTP later) and the signed-in user.
abstract interface class AuthRepository {
  Stream<AuthUser?> watchUser();

  /// Opens the Google account picker and signs in. Fails with
  /// [FailureKind.signInCanceled] when the picker is closed.
  Future<Result<void>> signInWithGoogle();

  /// Phone login (switched off for now with `phoneLoginEnabled`).
  Future<Result<OtpRequest>> requestOtp(String phoneE164, {int? resendToken});

  Future<Result<void>> confirmOtp({required String verificationId, required String code});

  /// Refreshes the session after the server changed the account.
  Future<Result<void>> refreshClaims();

  Future<Result<void>> signOut();

  /// Deletes the account and everything personal in it, then signs out.
  Future<Result<void>> deleteAccount();
}

/// The Google account picker, behind an interface for tests.
abstract interface class GoogleAccountPicker {
  /// A Google ID token for the chosen account, or null when the picker was closed.
  Future<String?> pickIdToken();

  /// Forgets the chosen account, so the picker shows again next time.
  Future<void> signOut();
}

/// The real picker (`google_sign_in`). [serverClientId] is the Google Cloud
/// OAuth **Web** client id that Supabase's Google provider is set up with;
/// this app's package name and SHA-1 must be registered as an Android OAuth
/// client in the same Google Cloud project.
class PluginGoogleAccountPicker implements GoogleAccountPicker {
  PluginGoogleAccountPicker(this._google, {required this.serverClientId});

  final GoogleSignIn _google;
  final String serverClientId;
  Future<void>? _initialized;

  Future<void> _init() =>
      _initialized ??= _google.initialize(serverClientId: serverClientId.isEmpty ? null : serverClientId);

  @override
  Future<String?> pickIdToken() async {
    if (serverClientId.isEmpty) {
      throw const AppFailure(FailureKind.googleSignInUnavailable, debugMessage: 'GOOGLE_WEB_CLIENT_ID is not set');
    }
    await _init();
    try {
      final account = await _google.authenticate();
      return account.authentication.idToken;
    } on GoogleSignInException catch (error) {
      switch (error.code) {
        case GoogleSignInExceptionCode.canceled || GoogleSignInExceptionCode.interrupted:
          return null;
        case GoogleSignInExceptionCode.clientConfigurationError ||
            GoogleSignInExceptionCode.providerConfigurationError ||
            GoogleSignInExceptionCode.uiUnavailable:
          throw AppFailure(FailureKind.googleSignInUnavailable, debugMessage: '${error.code}: ${error.description}');
        default:
          rethrow;
      }
    }
  }

  @override
  Future<void> signOut() async {
    await _init();
    await _google.signOut();
  }
}

/// Supabase Auth, plus the Google picker and the server's phone-login actions.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(
    this._auth, {
    required CallableClient functions,
    required GoogleAccountPicker google,
  }) : _functions = functions,
       _google = google;

  final GoTrueClient _auth;
  final CallableClient _functions;
  final GoogleAccountPicker _google;

  static AuthUser? toAuthUser(User? user) {
    if (user == null) return null;
    final phone = user.appMetadata['phone_e164'];
    final email = user.email;
    return AuthUser(
      uid: user.id,
      phoneNumber: phone is String ? phone : null,
      // Phone-login accounts carry a placeholder address; it is not theirs.
      email: email == null || email.endsWith('@phone.findx.invalid') ? null : email,
    );
  }

  @override
  Stream<AuthUser?> watchUser() async* {
    yield toAuthUser(_auth.currentUser);
    yield* _auth.onAuthStateChange.map((state) => toAuthUser(state.session?.user)).distinct();
  }

  @override
  Future<Result<void>> signInWithGoogle() => runGuarded(() async {
    final idToken = await _google.pickIdToken();
    if (idToken == null) throw const AppFailure(FailureKind.signInCanceled);
    await _auth.signInWithIdToken(provider: OAuthProvider.google, idToken: idToken);
  });

  /// Phone login with our own SMS codes: the server creates the code, sends
  /// it through the SMS provider (Renflair) and, when the right code comes
  /// back, returns a one-time sign-in token. The "verification id" is the
  /// phone number the code was sent to.
  @override
  Future<Result<OtpRequest>> requestOtp(String phoneE164, {int? resendToken}) => runGuarded(() async {
    await _functions.call('requestLoginOtp', {'phone': phoneE164});
    return OtpCodeSent(verificationId: phoneE164);
  });

  @override
  Future<Result<void>> confirmOtp({required String verificationId, required String code}) => runGuarded(() async {
    final data = await _functions.call('verifyLoginOtp', {'phone': verificationId, 'code': code.trim()});
    await _auth.verifyOTP(type: OtpType.magiclink, tokenHash: data['tokenHash']! as String);
  });

  @override
  Future<Result<void>> refreshClaims() => runGuarded(() async {
    if (_auth.currentSession != null) await _auth.refreshSession();
  });

  @override
  Future<Result<void>> deleteAccount() => runGuarded(() async {
    await _functions.call('deleteAccount');
    // The account is gone on the server; forget the local session too.
    await _auth.signOut();
    try {
      await _google.signOut();
    } on Object {
      // The picker simply shows the last account next time.
    }
  });

  @override
  Future<Result<void>> signOut() => runGuarded(() async {
    await _auth.signOut();
    try {
      await _google.signOut();
    } on Object {
      // Already signed out of VYBE; the picker simply shows the last account.
    }
  });
}
