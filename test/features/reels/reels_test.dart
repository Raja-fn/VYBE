import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/core/backend/file_storage.dart';
import 'package:vybe/core/utils/app_failure.dart';
import 'package:vybe/features/booking/presentation/book_spot_screen.dart';
import 'package:vybe/features/reels/data/reels_repository.dart';
import 'package:vybe/features/reels/domain/reel.dart';
import 'package:vybe/features/reels/presentation/new_reel_screen.dart';
import 'package:vybe/features/reels/presentation/reels_screen.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';

/// Taps without scrolling first (that would nudge the reels page).
Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.tap(finder.first);
  await settle(tester);
}

Future<TestBackend> _openReels(WidgetTester tester, {List<Reel> reels = const []}) async {
  final backend = readyBackend();
  backend.reels.all = [...reels];
  backend.discover.companions = [testCompanion('neha', name: 'Neha')];
  await pumpFullApp(tester, backend: backend);
  await _tap(tester, find.byTooltip('Reels'));
  return backend;
}

void main() {
  group('Reels tab', () {
    testWidgets('shows who posted, the caption, and the next reel on swipe', (tester) async {
      await _openReels(
        tester,
        reels: [
          testReel('r1', caption: 'Sunday at the sea face'),
          testReel('r2', author: 'sam', name: 'Sam'),
        ],
      );
      expect(find.byType(ReelsScreen), findsOneWidget);
      expect(find.text('Neha'), findsOneWidget);
      expect(find.text('Sunday at the sea face'), findsOneWidget);
      await tester.fling(find.byType(PageView), const Offset(0, -500), 1500);
      await settle(tester);
      expect(find.text('Sam'), findsOneWidget);
    });

    testWidgets('no reels: explains and offers to post', (tester) async {
      await _openReels(tester);
      expect(find.text('No reels yet'), findsOneWidget);
      expect(find.text('Post a reel'), findsOneWidget);
    });

    testWidgets('a server error offers a retry', (tester) async {
      final backend = readyBackend()..reels.failure = const AppFailure(FailureKind.network);
      await pumpFullApp(tester, backend: backend);
      await _tap(tester, find.byTooltip('Reels'));
      expect(find.text('Something went wrong'), findsOneWidget);
      backend.reels
        ..failure = null
        ..all = [testReel('r1', caption: 'Back again')];
      await _tap(tester, find.text('Try again'));
      expect(find.text('Back again'), findsOneWidget);
    });

    testWidgets('loads more near the end', (tester) async {
      final backend = readyBackend();
      backend.reels
        ..all = [for (var i = 0; i < 6; i++) testReel('r$i', caption: 'Reel $i')]
        ..pageSize = 4;
      await pumpFullApp(tester, backend: backend);
      await _tap(tester, find.byTooltip('Reels'));
      expect(backend.reels.feedCalls, [null]);
      for (var i = 0; i < 4; i++) {
        await tester.fling(find.byType(PageView), const Offset(0, -500), 1500);
        await settle(tester);
      }
      expect(backend.reels.feedCalls, [null, 'r3']);
      expect(find.text('Reel 4'), findsOneWidget);
    });

    testWidgets("Book and Message show on companions' reels and Book opens booking", (tester) async {
      await _openReels(tester, reels: [testReel('r1', bookable: true)]);
      expect(find.bySemanticsLabel('Message'), findsOneWidget);
      await _tap(tester, find.bySemanticsLabel('Book a meetup with Neha'));
      expect(find.byType(BookSpotScreen), findsOneWidget);
    });

    testWidgets('other reels can be reported', (tester) async {
      final backend = await _openReels(tester, reels: [testReel('r1')]);
      expect(find.bySemanticsLabel('Book a meetup with Neha'), findsNothing);
      await _tap(tester, find.bySemanticsLabel('Report or block'));
      await _tap(tester, find.text('Something else'));
      await tester.ensureVisible(find.text('Send report'));
      await _tap(tester, find.text('Send report'));
      expect(backend.chat.reports.single['refId'], 'r1');
    });

    testWidgets('my own reel can be deleted', (tester) async {
      final backend = await _openReels(tester, reels: [testReel('mine', isMine: true, caption: 'Hello')]);
      expect(find.text('You'), findsOneWidget);
      await _tap(tester, find.bySemanticsLabel('Delete'));
      expect(find.text('Delete this reel?'), findsOneWidget);
      await _tap(tester, find.widgetWithText(TextButton, 'Delete'));
      expect(backend.reels.deleted, ['mine']);
      expect(find.text('No reels yet'), findsOneWidget);
    });
  });

  group('Posting a reel', () {
    testWidgets('pick a video, add a caption, post: it shows first in the feed', (tester) async {
      final backend = await _openReels(tester);
      await _tap(tester, find.byTooltip('Post a reel'));
      await _tap(tester, find.text('Choose from gallery'));
      expect(backend.videos.picks, [VideoSource.gallery]);
      expect(find.byType(NewReelScreen), findsOneWidget);
      await tester.enterText(find.byType(TextField), '  First reel  ');
      await _tap(tester, find.text('Post'));
      expect(backend.reels.posted.single.caption, 'First reel');
      expect(backend.reels.posted.single.localFile, '/tmp/clip.mp4');
      expect(find.byType(ReelsScreen), findsOneWidget);
      expect(find.text('First reel'), findsOneWidget);
      expect(find.text('Your reel is posted'), findsOneWidget);
    });

    testWidgets('a video that is too big is refused before upload', (tester) async {
      final backend = await _openReels(tester);
      backend.videos.next = (path: '/tmp/big.mp4', bytes: reelMaxBytes + 1);
      await _tap(tester, find.byTooltip('Post a reel'));
      await _tap(tester, find.text('Record a video'));
      expect(find.text('This video is too big. Pick one under 50 MB.'), findsOneWidget);
      expect(find.byType(NewReelScreen), findsNothing);
    });

    testWidgets('a failed post stays on the screen with the reason', (tester) async {
      final backend = await _openReels(tester);
      await _tap(tester, find.byTooltip('Post a reel'));
      await _tap(tester, find.text('Choose from gallery'));
      backend.reels.failure = const AppFailure(FailureKind.rateLimited);
      await _tap(tester, find.text('Post'));
      expect(find.byType(NewReelScreen), findsOneWidget);
      expect(backend.reels.posted, isEmpty);
    });
  });

  group('helpers', () {
    test('reel ids are version 4 UUIDs', () {
      final id = newReelId(Random(1));
      expect(id, matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')));
      expect(newReelId(), isNot(newReelId()));
    });

    test('video types follow the file name', () {
      expect(videoContentType('/x/clip.MOV'), 'video/quicktime');
      expect(videoContentType('/x/clip.3gp'), 'video/3gpp');
      expect(videoContentType('/x/clip.mp4'), 'video/mp4');
      expect(reelVideoPath('u1', 'r1'), 'reels/u1/r1.mp4');
    });
  });
}
