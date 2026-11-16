import 'dart:convert';
import 'dart:io';

import 'package:findx/core/backend/backend_config.dart';
import 'package:findx/core/config/app_env.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('test builds started without settings use the test project', () {
    // Tests run without --dart-define-from-file, like a plain `flutter run`.
    expect(BackendConfig.forEnv(AppEnv.dev).supabaseUrl, BackendConfig.testProject.supabaseUrl);
    expect(BackendConfig.forEnv(AppEnv.dev).isComplete, isTrue);
  });

  test('production builds never fall back to the test project', () {
    expect(BackendConfig.forEnv(AppEnv.production).isComplete, isFalse);
  });

  test('the built-in test project matches config/supabase.dev.json', () {
    final file = (jsonDecode(File('config/supabase.dev.json').readAsStringSync()) as Map).cast<String, String>();
    expect(BackendConfig.testProject.supabaseUrl, file['SUPABASE_URL']);
    expect(BackendConfig.testProject.supabaseKey, file['SUPABASE_KEY']);
    expect(BackendConfig.testProject.googleWebClientId, file['GOOGLE_WEB_CLIENT_ID']);
  });
}
