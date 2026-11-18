import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/features/safety/data/safety_services.dart';
import 'package:vybe/features/safety/presentation/safety_hub_screen.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await tester.pump();
  await tester.tap(finder.first);
  await settle(tester);
}

Future<TestBackend> _openSafety(WidgetTester tester, {TrustedContact? contact}) async {
  final backend = readyBackend();
  backend.trustedContact.contact = contact;
  await pumpFullApp(tester, backend: backend);
  await _tap(tester, find.byTooltip('Profile'));
  await _tap(tester, find.text('Safety'));
  expect(find.byType(SafetyHubScreen), findsOneWidget);
  return backend;
}

void main() {
  group('Safety Hub', () {
    testWidgets('opens from Bookings too', (tester) async {
      await pumpFullApp(tester, backend: readyBackend());
      await _tap(tester, find.byTooltip('Bookings'));
      await _tap(tester, find.byTooltip('Safety'));
      expect(find.byType(SafetyHubScreen), findsOneWidget);
      expect(find.text('SOS'), findsOneWidget);
    });

    testWidgets('SOS calls only after a full hold', (tester) async {
      final backend = await _openSafety(tester);
      expect(find.text('Press and hold for 3 seconds to call 112.'), findsOneWidget);
      final sos = find.byType(SosButton);

      // A short press does nothing.
      var gesture = await tester.startGesture(tester.getCenter(sos));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await gesture.up();
      await settle(tester);
      expect(backend.launcher.calls, isEmpty);

      gesture = await tester.startGesture(tester.getCenter(sos));
      await tester.pump();
      await tester.pump(const Duration(seconds: 3, milliseconds: 100));
      await gesture.up();
      await settle(tester);
      expect(backend.launcher.calls, ['112']);
    });

    testWidgets('when the phone app cannot open, it says to call yourself', (tester) async {
      final backend = await _openSafety(tester);
      backend.launcher.opens = false;
      final gesture = await tester.startGesture(tester.getCenter(find.byType(SosButton)));
      await tester.pump();
      await tester.pump(const Duration(seconds: 4));
      await gesture.up();
      await settle(tester);
      expect(find.text("Couldn't open the phone app. Call 112 yourself."), findsOneWidget);
    });

    testWidgets('add a trusted contact, then send them my location', (tester) async {
      final backend = await _openSafety(tester);
      expect(find.text('Add someone you trust. You can send them where you are in one tap.'), findsOneWidget);
      await _tap(tester, find.text('Add'));
      await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Mum');
      await tester.enterText(find.byType(TextField).last, '98765 43210');
      await _tap(tester, find.text('Save'));
      expect(backend.trustedContact.saved.single, const TrustedContact(name: 'Mum', phoneE164: '+919876543210'));
      expect(find.text('Mum · +919876543210'), findsOneWidget);

      await _tap(tester, find.text('Send my location'));
      final (phone, body) = backend.launcher.texts.single;
      expect(phone, '+919876543210');
      expect(body, startsWith("I'm at a VYBE meetup. This is where I am: https://maps.google.com/?q="));
    });

    testWidgets('a bad number is refused', (tester) async {
      final backend = await _openSafety(tester);
      await _tap(tester, find.text('Add'));
      await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Mum');
      await tester.enterText(find.byType(TextField).last, '123');
      await _tap(tester, find.text('Save'));
      expect(find.text('Enter a valid phone number.'), findsOneWidget);
      expect(backend.trustedContact.saved, isEmpty);
    });

    testWidgets('the contact can be removed', (tester) async {
      final backend = await _openSafety(
        tester,
        contact: const TrustedContact(name: 'Mum', phoneE164: '+447700900123'),
      );
      await _tap(tester, find.text('Change'));
      await _tap(tester, find.text('Remove contact'));
      expect(backend.trustedContact.saved, [null]);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('without a contact, the location goes to the share sheet', (tester) async {
      final backend = await _openSafety(tester);
      await _tap(tester, find.text('Send my location'));
      expect(backend.launcher.shares.single, contains('https://maps.google.com/?q='));
      expect(backend.launcher.texts, isEmpty);
    });

    testWidgets('location switched off is explained', (tester) async {
      final backend = readyBackend()..location = DeniedLocationService();
      await pumpFullApp(tester, backend: backend);
      await _tap(tester, find.byTooltip('Profile'));
      await _tap(tester, find.text('Safety'));
      await _tap(tester, find.text('Send my location'));
      expect(backend.launcher.shares, isEmpty);
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });

  group('trusted phone numbers', () {
    String? parse(String raw) => trustedPhoneE164(raw, countryCode: '+91', nationalLength: 10);

    test('local numbers get the home country code; international numbers are kept', () {
      expect(parse('98765 43210'), '+919876543210');
      expect(parse('098765-43210'), '+919876543210');
      expect(parse('+44 7700 900123'), '+447700900123');
      expect(parse('0044 7700 900123'), '+447700900123');
      expect(parse('+1 (415) 555-0100'), '+14155550100');
    });

    test('rejects what is not a phone number', () {
      expect(parse('123'), isNull);
      expect(parse('call me'), isNull);
      expect(parse('+0123456789'), isNull);
    });

    test('map links have five decimals', () {
      expect(mapLink(19.0596123, 72.8295456), 'https://maps.google.com/?q=19.05961,72.82955');
    });
  });
}
