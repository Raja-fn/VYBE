import 'bootstrap.dart';
import 'core/config/app_env.dart';

/// Production entry point: the launch Supabase project and real providers.
///
/// flutter build appbundle --dart-define-from-file=config/supabase.production.json
Future<void> main() => bootstrap(AppEnv.production);
