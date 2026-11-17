import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/core/backend/backend_config.dart';
import 'package:vybe/core/config/app_env.dart';

void main() {
  test('every build started without settings uses the live project', () {
    // Tests run without --dart-define-from-file, like VS Code's "Run" link.
    for (final env in AppEnv.values) {
      expect(BackendConfig.forEnv(env).supabaseUrl, BackendConfig.liveProject.supabaseUrl);
      expect(BackendConfig.forEnv(env).isComplete, isTrue);
    }
  });

  test('the built-in project matches both config files', () {
    for (final name in ['supabase.production.json', 'supabase.dev.json']) {
      final file = (jsonDecode(File('config/$name').readAsStringSync()) as Map).cast<String, String>();
      expect(BackendConfig.liveProject.supabaseUrl, file['SUPABASE_URL'], reason: name);
      expect(BackendConfig.liveProject.supabaseKey, file['SUPABASE_KEY'], reason: name);
      expect(BackendConfig.liveProject.googleWebClientId, file['GOOGLE_WEB_CLIENT_ID'], reason: name);
    }
  });
}
