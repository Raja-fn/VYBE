import 'package:findx/core/config/app_env.dart';
import 'package:findx/core/dev/component_gallery_screen.dart';
import 'package:findx/core/router/app_router.dart';
import 'package:findx/core/router/screens/not_found_screen.dart';
import 'package:findx/core/router/screens/start_screen.dart';
import 'package:findx/core/utils/app_failure.dart';
import 'package:findx/core/widgets/async_state_view.dart';
import 'package:findx/features/discover/presentation/discover_screen.dart';
import 'package:findx/features/onboarding/presentation/rules_screen.dart';
import 'package:findx/features/onboarding/presentation/session_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';

ProviderContainer _container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(Navigator).first));

void main() {
  testWidgets('a signed-out person lands on the rules screen', (tester) async {
    await pumpFullApp(tester);
    expect(find.byType(RulesScreen), findsOneWidget);
  });

  testWidgets('test builds can open the component gallery', (tester) async {
    await pumpFullApp(tester);
    _container(tester).read(appRouterProvider).go('/dev/components');
    await settle(tester);
    expect(find.byType(ComponentGalleryScreen), findsOneWidget);
  });

  testWidgets('production builds have no component gallery', (tester) async {
    await pumpFullApp(tester, env: AppEnv.production);
    _container(tester).read(appRouterProvider).go('/dev/components');
    await settle(tester);
    expect(find.byType(NotFoundScreen), findsOneWidget);
  });

  testWidgets('a signed-out person is sent to the rules even from an unknown address', (tester) async {
    await pumpFullApp(tester);
    _container(tester).read(appRouterProvider).go('/does-not-exist');
    await settle(tester);
    expect(find.byType(RulesScreen), findsOneWidget);
  });

  testWidgets('unknown routes show the not-found screen with a way back', (tester) async {
    await pumpFullApp(tester, backend: readyBackend());
    _container(tester).read(appRouterProvider).go('/does-not-exist');
    await settle(tester);
    expect(find.byType(NotFoundScreen), findsOneWidget);

    await tester.tap(find.text('Go to start'));
    await settle(tester);
    expect(find.byType(DiscoverScreen), findsOneWidget);
  });

  testWidgets('shows the offline banner when offline', (tester) async {
    await pumpFullApp(tester, online: false);
    expect(find.byType(OfflineBanner), findsOneWidget);
  });

  testWidgets('text scale is clamped to the configured maximum', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpFullApp(tester);
    final context = tester.element(find.byType(RulesScreen));
    expect(MediaQuery.textScalerOf(context).scale(10), closeTo(11.5, 0.001));
  });

  group('start screen', () {
    testWidgets('shows loading while the session is worked out', (tester) async {
      await pumpInApp(
        tester,
        const StartScreen(),
        wrapInScaffold: false,
        overrides: [sessionStageProvider.overrideWithValue(const AsyncLoading())],
      );
      expect(find.text('Getting things ready'), findsOneWidget);
      expect(find.text('Open component gallery'), findsOneWidget);
    });

    testWidgets('shows the error with a retry when the session fails to load', (tester) async {
      await pumpInApp(
        tester,
        const StartScreen(),
        wrapInScaffold: false,
        overrides: [
          sessionStageProvider.overrideWithValue(const AsyncError(AppFailure(FailureKind.network), StackTrace.empty)),
        ],
      );
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('hides the gallery button in production', (tester) async {
      await pumpInApp(
        tester,
        const StartScreen(),
        wrapInScaffold: false,
        env: AppEnv.production,
        overrides: [sessionStageProvider.overrideWithValue(const AsyncLoading())],
      );
      expect(find.text('Open component gallery'), findsNothing);
    });
  });
}
