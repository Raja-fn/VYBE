import 'bootstrap.dart';
import 'core/config/app_env.dart';

/// Test builds: the test Supabase project, whose server uses the fakes
/// (auto-approved verification, test-store purchases), with test accounts.
///
/// flutter run -t lib/main_dev.dart --dart-define-from-file=config/supabase.dev.json
Future<void> main() => bootstrap(AppEnv.dev);
