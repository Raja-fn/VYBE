import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_env.g.dart';

/// Which kind of build this is.
///
/// [dev] talks to the **test** Supabase project: its server uses the fake
/// services (auto-approved verification, test-store purchases), and the app
/// offers test accounts, the component gallery and a fixed Mumbai location.
/// [production] talks to the launch project with real providers.
enum AppEnv {
  dev,
  production;

  /// Test accounts, the component gallery and the fixed test location.
  bool get isDev => this == AppEnv.dev;

  /// Purchases go through the built-in test store instead of Google Play /
  /// the App Store (the server accepts them only where fakes are allowed).
  bool get usesTestStore => this != AppEnv.production;
}

/// Set once in `bootstrap()` through a provider override.
@Riverpod(keepAlive: true)
AppEnv appEnv(Ref ref) => throw StateError('appEnvProvider is set in bootstrap(). Override it in tests.');
