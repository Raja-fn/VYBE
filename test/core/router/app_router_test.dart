import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/core/router/app_router.dart';
import 'package:vybe/core/router/screens/not_found_screen.dart';
import 'package:vybe/core/router/screens/start_screen.dart';
import 'package:vybe/core/utils/app_failure.dart';
import 'package:vybe/core/widgets/async_state_view.dart';
import 'package:vybe/features/discover/presentation/discover_screen.dart';
import 'package:vybe/features/onboarding/presentation/rules_screen.dart';
import 'package:vybe/features/onboarding/presentation/session_providers.dart';

import '../../helpers/test_app.dart';

ProviderContainer _container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(Navigator).first));

void main() {
  testWidgets('a signed-out person lands on the rules screen', (tester) async {
    await pumpFullApp(tester);
    expect(find.byType(RulesScreen), findsOneWidget);
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
      expect(find.bySemanticsLabel('Getting things ready'), findsOneWidget);
      expect(find.text('Open component gallery'), findsNothing);
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
  });
}
