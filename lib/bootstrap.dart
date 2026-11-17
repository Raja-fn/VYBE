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
import 'core/splash/splash_gate.dart';
import 'core/utils/result.dart';

/// Shared start-up for every entry point: the animated splash plays while
/// the app connects, then opens onto the app (or the error screen).
Future<void> bootstrap(AppEnv env) async {
  WidgetsFlutterBinding.ensureInitialized();
  _show(env);
}

void _show(AppEnv env) => runApp(SplashGate(app: _prepare(env)));

/// Never leaves the person on the splash screen: any start-up failure gives
/// the error screen with "Try again".
Future<Widget> _prepare(AppEnv env) async {
  void retry() => _show(env);
  final backend = BackendConfig.forEnv(env);
  try {
    if (!_backendReady) {
      await initBackend(backend).timeout(const Duration(seconds: 20));
      _backendReady = true;
    }
  } on Object catch (error) {
    debugPrint('VYBE start-up failed: $error');
    return BootstrapErrorApp(onRetry: retry);
  }

  final remote = SupabaseConfigSource(SupabaseTables(Supabase.instance.client));
  final config = await AppConfigRepository(bundle: rootBundle, remote: remote).load();
  return switch (config) {
    Ok(:final value) => ProviderScope(
      retry: noAutomaticRetry,
      overrides: [appEnvProvider.overrideWithValue(env), appConfigProvider.overrideWithValue(value)],
      child: const VybeApp(),
    ),
    Err() => BootstrapErrorApp(onRetry: retry),
  };
}

bool _backendReady = false;
