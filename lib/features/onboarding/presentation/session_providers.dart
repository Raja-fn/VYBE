import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/backend/backend_config.dart';
import '../../../core/backend/backend_providers.dart';
import '../../../core/config/app_env.dart';
import '../../preferences/presentation/preferences_providers.dart';
import '../data/account_repository.dart';
import '../data/auth_repository.dart';
import '../domain/account.dart';
import '../domain/session_stage.dart';

part 'session_providers.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => SupabaseAuthRepository(
  ref.watch(supabaseClientProvider).auth,
  functions: ref.watch(callableClientProvider),
  google: PluginGoogleAccountPicker(
    GoogleSignIn.instance,
    serverClientId: BackendConfig.forEnv(ref.watch(appEnvProvider)).googleWebClientId,
  ),
  allowTestAccounts: ref.watch(appEnvProvider).isDev,
  testAccountPassword: testAccountPassword,
);

@Riverpod(keepAlive: true)
AccountRepository accountRepository(Ref ref) =>
    SupabaseAccountRepository(tables: ref.watch(tablesProvider), functions: ref.watch(callableClientProvider));

@Riverpod(keepAlive: true)
Stream<AuthUser?> authUser(Ref ref) => ref.watch(authRepositoryProvider).watchUser();

@Riverpod(keepAlive: true)
Stream<Account?> account(Ref ref, String uid) => ref.watch(accountRepositoryProvider).watchAccount(uid);

/// Where the person is in getting set up. The router redirects on this.
@Riverpod(keepAlive: true)
AsyncValue<SessionStage> sessionStage(Ref ref) => deriveSessionStage(
  user: ref.watch(authUserProvider),
  account: (uid) => ref.watch(accountProvider(uid)),
  hasPreferences: (uid) => ref.watch(preferencesProvider(uid)).whenData((prefs) => prefs != null),
);

/// Whether the rules were accepted on this device in this session.
///
/// Consent is recorded on the server (with the rules version) as soon as the
/// phone is verified; this only carries it from the rules screen to sign-in.
@Riverpod(keepAlive: true)
class ConsentGiven extends _$ConsentGiven {
  @override
  bool build() => false;

  void give() => state = true;

  void reset() => state = false;
}
