import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'core/l10n/l10n.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_dimens.dart';
import 'core/theme/app_theme.dart';

const appLocalizationsDelegates = <LocalizationsDelegate<Object>>[
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

/// Riverpod 3 retries failed providers automatically. FindX shows an explicit
/// "Try again" on every error state instead, so automatic retry is off.
Duration? noAutomaticRetry(int retryCount, Object error) => null;

class FindXApp extends ConsumerWidget {
  const FindXApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final maxTextScale = ref.watch(appConfigProvider).maxTextScale;

    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appName,
      theme: AppTheme.light(),
      themeMode: ThemeMode.light,
      routerConfig: router,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      // Layouts are designed and tested up to this text scale.
      builder: (context, child) =>
          MediaQuery.withClampedTextScaling(maxScaleFactor: maxTextScale, child: child ?? const SizedBox.shrink()),
    );
  }
}

/// Shown if the app cannot finish starting (for example, bad bundled config).
class BootstrapErrorApp extends StatelessWidget {
  const BootstrapErrorApp({required this.onRetry, this.notConfigured = false, super.key});

  final VoidCallback onRetry;

  /// The build has no server settings: retrying cannot help, so say what is wrong.
  final bool notConfigured;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) => Scaffold(
          body: SafeArea(
            child: _BootstrapError(onRetry: onRetry, notConfigured: notConfigured),
          ),
        ),
      ),
    );
  }
}

class _BootstrapError extends StatelessWidget {
  const _BootstrapError({required this.onRetry, required this.notConfigured});

  final VoidCallback onRetry;
  final bool notConfigured;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.bootstrapErrorTitle, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: AppSpacing.screenPadding,
            child: Text(
              notConfigured ? l10n.bootstrapNotConfigured : l10n.bootstrapNoConnection,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            ),
          ),
          if (!notConfigured) TextButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
        ],
      ),
    );
  }
}
