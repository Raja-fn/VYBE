import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/backend/backend_bootstrap.dart';
import 'core/backend/backend_config.dart';
import 'core/backend/tables.dart';
import 'core/config/app_config.dart';
import 'core/config/app_config_repository.dart';
import 'core/config/app_env.dart';
import 'core/config/remote_config_source.dart';
import 'core/utils/result.dart';

/// Shared start-up for every entry point.
Future<void> bootstrap(AppEnv env) async {
  WidgetsFlutterBinding.ensureInitialized();
  await _connect(env);
}

/// Never leaves the person on the splash screen: any start-up failure shows
/// the error screen with "Try again".
Future<void> _connect(AppEnv env) async {
  final backend = BackendConfig.forEnv(env);
  if (!backend.isComplete) {
    debugPrint('FindX start-up failed: this production build has no Supabase settings.');
    runApp(BootstrapErrorApp(onRetry: () => _connect(env), notConfigured: true));
    return;
  }
  try {
    if (!_backendReady) {
      await initBackend(backend).timeout(const Duration(seconds: 20));
      _backendReady = true;
    }
  } on Object catch (error) {
    debugPrint('FindX start-up failed: $error');
    runApp(BootstrapErrorApp(onRetry: () => _connect(env)));
    return;
  }
  await _start(env);
}

bool _backendReady = false;

Future<void> _start(AppEnv env) async {
  final remote = SupabaseConfigSource(SupabaseTables(Supabase.instance.client));
  final config = await AppConfigRepository(bundle: rootBundle, remote: remote).load();

  switch (config) {
    case Ok(:final value):
      runApp(
        ProviderScope(
          retry: noAutomaticRetry,
          overrides: [appEnvProvider.overrideWithValue(env), appConfigProvider.overrideWithValue(value)],
          child: const FindXApp(),
        ),
      );
    case Err():
      runApp(BootstrapErrorApp(onRetry: () => _start(env)));
  }
}
