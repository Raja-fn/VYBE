import 'package:findx/core/services/image_capture/photo_picker_service.dart';
import 'package:findx/features/discover/presentation/companion_profile_screen.dart';
import 'package:findx/features/profile/domain/profile_details.dart';
import 'package:findx/features/profile/presentation/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';

Future<void> _tap(WidgetTester tester, Finder finder) async {
  // Rows further down are built only once scrolled into view.
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(finder, 200, scrollable: find.byType(Scrollable).first);
  }
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await settle(tester);
}

void main() {
  group('Edit profile', () {
    testWidgets('adds photos from the gallery or camera; the first becomes the main photo', (tester) async {
      final backend = readyBackend();
      await pumpInApp(tester, const EditProfileScreen(), backend: backend, wrapInScaffold: false);
      await settle(tester);

      await _tap(tester, find.bySemanticsLabel('Add photo').first);
      await _tap(tester, find.text('Choose from gallery'));
      expect(backend.photos.picks, [PhotoSource.gallery]);
      expect(backend.accounts.account.value!.photoPaths, hasLength(1));
      expect(find.text('Main'), findsOneWidget);

      await _tap(tester, find.bySemanticsLabel('Add photo').first);
      await _tap(tester, find.text('Take a photo'));
      expect(backend.photos.picks.last, PhotoSource.camera);
      expect(backend.accounts.account.value!.photoPaths, hasLength(2));
    });

    testWidgets('backing out of the picker adds nothing', (tester) async {
      final backend = readyBackend()..photos.next = null;
      await pumpInApp(tester, const EditProfileScreen(), backend: backend, wrapInScaffold: false);
      await settle(tester);
      await _tap(tester, find.bySemanticsLabel('Add photo').first);
      await _tap(tester, find.text('Choose from gallery'));
      expect(backend.accounts.account.value!.photoPaths, isEmpty);
    });

    testWidgets('a photo can become the main one, or be removed', (tester) async {
      final backend = readyBackend();
      backend.accounts.account.value = backend.accounts.account.value!.copyWith(
        photoPaths: ['photos/$testUid/a.jpg', 'photos/$testUid/b.jpg'],
      );
      await pumpInApp(tester, const EditProfileScreen(), backend: backend, wrapInScaffold: false);
      await settle(tester);

      await _tap(tester, find.bySemanticsLabel('Photos').first);
      await _tap(tester, find.text('Make main photo'));
      expect(backend.accounts.account.value!.photoPaths, ['photos/$testUid/b.jpg', 'photos/$testUid/a.jpg']);

      await _tap(tester, find.bySemanticsLabel('Main').first);
      await _tap(tester, find.text('Remove photo'));
      expect(backend.accounts.account.value!.photoPaths, ['photos/$testUid/a.jpg']);
      expect(backend.profile.deletedPhotos, ['photos/$testUid/b.jpg']);
    });

    testWidgets('city, languages, lifestyle and bio are saved from their pickers', (tester) async {
      final backend = readyBackend();
      await pumpInApp(tester, const EditProfileScreen(), backend: backend, wrapInScaffold: false);
      await settle(tester);

      await _tap(tester, find.text('City'));
      await tester.enterText(find.byType(TextField), 'Mumbai');
      await _tap(tester, find.text('Save'));
      expect(backend.profile.details.value.city, 'Mumbai');
      expect(find.text('Mumbai'), findsOneWidget);

      await _tap(tester, find.text('Languages I speak'));
      await _tap(tester, find.text('Hindi'));
      await _tap(tester, find.text('Marathi'));
      await _tap(tester, find.text('Save'));
      expect(backend.profile.details.value.languages, ['hindi', 'marathi']);
      expect(find.text('Hindi + 1 more'), findsOneWidget);

      await _tap(tester, find.text('Drinking'));
      await _tap(tester, find.text('Socially'));
      expect(backend.profile.details.value.drinking, 'socially');

      await _tap(tester, find.text('A few lines about you and the plans you enjoy'));
      await tester.enterText(find.byType(TextField), 'Coffee, books and long walks.');
      await _tap(tester, find.text('Save'));
      expect(backend.profile.details.value.about, 'Coffee, books and long walks.');
    });

    testWidgets('no more than the allowed number of interests can be picked', (tester) async {
      final backend = readyBackend();
      await pumpInApp(tester, const EditProfileScreen(), backend: backend, wrapInScaffold: false);
      await settle(tester);
      await _tap(tester, find.text('Pick up to 8'));
      Finder inSheet(String text) => find.descendant(of: find.byType(BottomSheet), matching: find.text(text));
      for (final label in ['Music', 'Movies', 'Travel', 'Food', 'Coffee', 'Books', 'Fitness', 'Art', 'Photography']) {
        await _tap(tester, inSheet(label));
      }
      await _tap(tester, inSheet('Save'));
      expect(backend.profile.details.value.interests, hasLength(ProfileOptions.maxInterests));
      expect(backend.profile.details.value.interests, isNot(contains('photography')));
    });

    testWidgets('lays out on a small phone with large text', (tester) async {
      await pumpInApp(
        tester,
        const EditProfileScreen(),
        backend: readyBackend(),
        wrapInScaffold: false,
        size: smallPhoneSize,
        textScale: 1.15,
      );
      await settle(tester);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets("a companion's profile shows their city, interests, languages and lifestyle", (tester) async {
    final backend = readyBackend();
    backend.discover.companions = [
      testCompanion('neha', name: 'Neha').copyWith(
        details: const ProfileDetails(
          city: 'Mumbai',
          interests: ['coffee', 'books'],
          languages: ['english', 'marathi'],
          drinking: 'never',
        ),
      ),
    ];
    await pumpInApp(tester, const CompanionProfileScreen(uid: 'neha'), backend: backend, wrapInScaffold: false);
    await settle(tester);
    for (final text in ['Mumbai', 'Coffee', 'Books', 'English', 'Marathi', 'Drinking: Never']) {
      await tester.scrollUntilVisible(find.text(text), 100, scrollable: find.byType(Scrollable).first);
      expect(find.text(text), findsOneWidget, reason: text);
    }
  });
}
