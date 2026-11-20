import '../config/app_env.dart';

/// Which Supabase project this build talks to. Every value is public: it
/// ships inside the app (security comes from row-level security on the
/// server, never from hiding these).
///
/// VYBE has one Supabase project, built into the app as [liveProject], so
/// every build works however it is started (VS Code "Run", `flutter run`,
/// a release build). A config file given at build time still takes priority:
///   flutter run --dart-define-from-file=config/supabase.production.json
/// See config/supabase.example.json and docs/supabase-setup.md.
class BackendConfig {
  const BackendConfig({required this.supabaseUrl, required this.supabaseKey, required this.googleWebClientId});

  /// The values compiled into this build.
  static const fromBuild = BackendConfig(
    supabaseUrl: String.fromEnvironment('SUPABASE_URL'),
    supabaseKey: String.fromEnvironment('SUPABASE_KEY'),
    googleWebClientId: String.fromEnvironment('GOOGLE_WEB_CLIENT_ID'),
  );

  /// For example `https://abcdefghijklmnop.supabase.co`.
  final String supabaseUrl;

  /// The project's publishable key (`sb_publishable_...`) or its legacy anon key.
  final String supabaseKey;

  /// Google Cloud OAuth client of type **Web application**, also entered in
  /// Supabase -> Authentication -> Providers -> Google. Google sign-in on
  /// Android needs it to issue a token Supabase accepts.
  final String googleWebClientId;

  bool get isComplete => supabaseUrl.startsWith('https://') && supabaseKey.isNotEmpty;

  /// The live project. Keep in sync with config/supabase.production.json.
  static const liveProject = BackendConfig(
    supabaseUrl: 'https://stgfjguoytqzmliurbvp.supabase.co',
    supabaseKey: 'sb_publishable_1xJlFdyZXpg5R6dm_V1k-w_9lQvUKup',
    googleWebClientId: '433440115032-61hqqel2qi721g80mq656v5irjgncfj1.apps.googleusercontent.com',
  );

  /// What this build connects to: the build's own settings, else the live project.
  static BackendConfig forEnv(AppEnv env) => fromBuild.isComplete ? fromBuild : liveProject;
}

