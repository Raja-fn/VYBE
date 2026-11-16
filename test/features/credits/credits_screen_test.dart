import 'dart:async';

import 'package:findx/core/router/app_router.dart';
import 'package:findx/core/utils/app_failure.dart';
import 'package:findx/features/credits/domain/credit_models.dart';
import 'package:findx/features/credits/presentation/credits_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';
import 'credits_data_test.dart' show ScriptedStore;

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await tester.pump();
  await tester.tap(finder.first);
  await settle(tester);
}

Future<void> _open(WidgetTester tester, TestBackend backend, {Size size = phoneSize}) async {
  await pumpFullApp(tester, backend: backend, size: size);
  final router = ProviderScope.containerOf(tester.element(find.byType(Navigator).first)).read(appRouterProvider);
  unawaited(router.push('/credits'));
  await settle(tester);
}

void main() {
  group('Credits and plans (screen 11)', () {
    testWidgets('shows Free, Plus, Premium and three packs, credits only', (tester) async {
      await _open(tester, readyBackend());
      expect(find.text('Get more credits'), findsOneWidget);
      expect(find.text('Unlock chats and bookings.'), findsOneWidget);
      expect(find.text('Free'), findsOneWidget);
      expect(find.text('₹0'), findsOneWidget);
      expect(find.text('20 credits when you join'), findsOneWidget);
      expect(find.text('Popular'), findsOneWidget);
      expect(find.text('100 credits a month · unused credits stay'), findsOneWidget);
      expect(find.text('200 credits a month · unused credits stay'), findsOneWidget);
      expect(find.text('Or top up credits'), findsOneWidget);
      for (final n in ['10', '30', '75']) {
        expect(find.text(n), findsOneWidget);
      }
      expect(find.text('Your plan'), findsOneWidget);
      expect(find.textContaining('Test store'), findsOneWidget);
      expect(find.text('Continue with Plus'), findsOneWidget);
      for (final banned in ['swipe', 'like', 'boost']) {
        expect(find.textContaining(RegExp(banned, caseSensitive: false)), findsNothing);
      }
    });

    testWidgets('buying a pack adds its credits', (tester) async {
      final backend = readyBackend();
      await _open(tester, backend);
      await _tap(tester, find.text('30'));
      expect(find.text('Buy 30 credits'), findsOneWidget);
      await _tap(tester, find.text('Buy 30 credits'));
      expect(backend.credits.balance.value, 50);
      expect(find.text('30 credits added.'), findsOneWidget);
    });

    testWidgets('Continue with Plus activates the plan', (tester) async {
      final backend = readyBackend();
      await _open(tester, backend);
      await _tap(tester, find.text('Continue with Plus'));
      expect(find.text('Plus is active. 100 credits added.'), findsOneWidget);
      expect(find.textContaining('Renews'), findsOneWidget);
      expect(find.text('Continue with Premium'), findsOneWidget);
    });

    testWidgets('on Premium, choosing Plus waits for the renewal', (tester) async {
      final backend = readyBackend();
      backend.purchases.subscription.value = SubscriptionInfo(tier: PlanTier.premium, renewsAt: DateTime(2026, 12, 12));
      await _open(tester, backend);
      expect(find.text('Renews Dec 12'), findsNothing);
      expect(find.textContaining('Renews Dec 1'), findsOneWidget);
      await _tap(tester, find.text('Plus'));
      await _tap(tester, find.text('Switch to Plus at renewal'));
      expect(find.text('You will move to Plus when your current plan renews.'), findsOneWidget);
      expect(find.textContaining('Moves to Plus on'), findsOneWidget);
      await _tap(tester, find.text('Plus'));
      expect(find.text('This is your plan'), findsOneWidget);
    });

    testWidgets('a rejected purchase is explained', (tester) async {
      final backend = readyBackend()..purchases.failure = const AppFailure(FailureKind.purchaseInvalid);
      await _open(tester, backend);
      await _tap(tester, find.text('Continue with Plus'));
      expect(
        find.text('The store could not confirm this purchase. You have not been charged credits.'),
        findsOneWidget,
      );
      expect(find.text('Try again'), findsNothing);
    });

    testWidgets('offline after paying offers Try again', (tester) async {
      final backend = readyBackend()..purchases.failure = const AppFailure(FailureKind.network);
      await _open(tester, backend);
      await _tap(tester, find.text('Continue with Plus'));
      expect(find.text('Try again'), findsOneWidget);
      backend.purchases.failure = null;
      await _tap(tester, find.text('Try again'));
      expect(find.text('Plus is active. 100 credits added.'), findsOneWidget);
      expect(find.text('Try again'), findsNothing);
    });

    testWidgets('real store prices are shown per month', (tester) async {
      final backend = readyBackend()..store = ScriptedStore();
      await _open(tester, backend);
      expect(find.text('₹99/mo'), findsNWidgets(2));
      expect(find.text('₹99'), findsNWidgets(3));
      expect(find.textContaining('Test store'), findsNothing);
    });

    testWidgets('when the store is unavailable nothing can be bought', (tester) async {
      final backend = readyBackend()..store = (ScriptedStore()..available = false);
      await _open(tester, backend);
      expect(find.text('Purchases are not available on this device right now.'), findsOneWidget);
      final button = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Continue with Plus'));
      expect(button.onPressed, isNull);
    });

    testWidgets('the credits pill on Discover opens it', (tester) async {
      await pumpFullApp(tester, backend: readyBackend());
      await _tap(tester, find.bySemanticsLabel(RegExp('Open credits and plans')));
      expect(find.byType(CreditsScreen), findsOneWidget);
    });
  });

  group('Get credits', () {
    testWidgets('not enough credits to start a chat offers Get credits', (tester) async {
      final backend = readyBackend()
        ..discover.companions = [testCompanion('neha', name: 'Neha')]
        ..chat.startFailure = const AppFailure(FailureKind.insufficientCredits);
      await pumpFullApp(tester, backend: backend);
      await _tap(tester, find.bySemanticsLabel('Message'));
      await _tap(tester, find.text('Start chat'));
      await _tap(tester, find.text('Get credits'));
      expect(find.byType(CreditsScreen), findsOneWidget);
    });
  });

  testWidgets('text scale 1.3 on a small phone', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final backend = readyBackend();
    backend.purchases.subscription.value = SubscriptionInfo(
      tier: PlanTier.premium,
      renewsAt: DateTime(2026, 12, 12),
      pendingTier: PlanTier.plus,
    );
    await _open(tester, backend, size: smallPhoneSize);
    expect(tester.takeException(), isNull);
  });
}
