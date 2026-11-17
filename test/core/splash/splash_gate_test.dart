import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/core/splash/splash_gate.dart';

const _app = Directionality(textDirection: TextDirection.ltr, child: Text('the app'));

void main() {
  testWidgets('plays the intro, then opens onto the app once it is ready', (tester) async {
    await tester.pumpWidget(SplashGate(app: Future.value(_app)));
    await tester.pump();
    // Ready straight away, but the intro still plays first.
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.byKey(SplashGate.overlayKey), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('the app'), findsOneWidget);
    expect(find.byKey(SplashGate.overlayKey), findsNothing);
  });

  testWidgets('waits as long as the app needs, then opens', (tester) async {
    final app = Completer<Widget>();
    await tester.pumpWidget(SplashGate(app: app.future));
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('the app'), findsNothing);
    expect(find.byKey(SplashGate.overlayKey), findsOneWidget);

    app.complete(_app);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('the app'), findsOneWidget);
    expect(find.byKey(SplashGate.overlayKey), findsNothing);
  });

  testWidgets('with animations turned off, it goes straight to the app', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: SplashGate(app: Future.value(_app)),
      ),
    );
    await tester.pump();
    expect(find.text('the app'), findsOneWidget);
    expect(tester.hasRunningAnimations, isFalse);
  });
}
