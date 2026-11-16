import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'backend_config.dart';

/// Connects to the Supabase project compiled into this build, and turns on
/// crash reports (Firebase Crashlytics, free plan; Firebase holds no data).
///
/// Throws [StateError] when the build has no Supabase settings.
Future<void> initBackend(BackendConfig config) async {
  if (!config.isComplete) {
    throw StateError(
      'This build has no Supabase settings. Run with '
      '--dart-define-from-file=config/supabase.dev.json (see docs/supabase-setup.md).',
    );
  }
  await Supabase.initialize(url: config.supabaseUrl, publishableKey: config.supabaseKey);
  await _reportCrashes();
}

Future<void> _reportCrashes() async {
  try {
    await Firebase.initializeApp();
  } on Object catch (error) {
    // Crash reports are optional: a build without Firebase files still runs.
    debugPrint('Crash reports are off: $error');
    return;
  }
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}
