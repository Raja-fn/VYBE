import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/app.dart';
import 'package:vybe/core/backend/callable_client.dart';
import 'package:vybe/core/location/location_service.dart';
import 'package:vybe/core/utils/app_failure.dart';
import 'package:vybe/features/discover/data/discover_repository.dart';
import 'package:vybe/features/discover/domain/companion_summary.dart';
import 'package:vybe/features/discover/presentation/discover_controller.dart';
import 'package:vybe/features/profile/presentation/my_profile_controller.dart';

import '../../helpers/fake_tables.dart';
import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';

Map<String, Object?> _dto(String uid, {String? freeNowUntil}) => {
  'uid': uid,
  'displayName': 'Neha',
  'ageYears': 24,
  'gender': null,
  'photoPaths': <String>[],
  'about': 'Designer',
  'activityTags': ['coffee'],
  'planTypes': ['coffee', 'walk'],
  'prompt': {'promptId': 'ideal_sunday', 'answer': 'Coffee'},
  'voiceIntro': {'path': 'users/x/voice/intro.m4a', 'durationSec': 15},
  'ratingAvg': 4.8,
  'ratingCount': 10,
  'meetupCount': 32,
  'distanceKm': 2,
  'spotsNearby': 3,
  'freeNowUntil': freeNowUntil,
  'freeFrom': null,
  'freeUntil': null,
};

void main() {
  group('SupabaseDiscoverRepository', () {
    late FakeCallableClient functions;
    late FakeTables tables;
    late SupabaseDiscoverRepository repository;

    setUp(() {
      functions = FakeCallableClient();
      tables = FakeTables();
      repository = SupabaseDiscoverRepository(functions: functions, tables: tables);
    });

    test('sends the device position to the server', () async {
      await repository.updateLocation(const DevicePosition(lat: 19.06, lng: 72.83, accuracyM: 8));
      expect(functions.calls.single.$1, 'updateMyLocation');
      expect(functions.calls.single.$2, {'lat': 19.06, 'lng': 72.83, 'accuracyM': 8.0});
    });

    test('parses companion cards, including dates and nested fields', () async {
      functions.responses['discoverCompanions'] = {
        'companions': [_dto('c1', freeNowUntil: '2026-11-10T12:30:00.000Z')],
      };
      final list = (await repository.discover(PlanType.coffee)).valueOrNull!;
      expect(functions.calls.single.$2, {'planType': 'coffee'});
      final c = list.single;
      expect(c.displayName, 'Neha');
      expect(c.freeNowUntil, DateTime.utc(2026, 11, 10, 12, 30));
      expect(c.voiceIntro, const VoiceIntro(path: 'users/x/voice/intro.m4a', durationSec: 15));
      expect(c.prompt?.promptId, 'ideal_sunday');
      expect(c.ratingAvg, 4.8);
    });

    test('sends the free-now window by its wire name', () async {
      await repository.freeNow(FreeWindow.next2h);
      expect(functions.calls.single.$2, {'window': 'next_2h'});
    });

    test('a missing profile becomes a typed failure', () async {
      functions.error = const ServerException('not-found', code: 'not_found');
      expect((await repository.profile('x')).failureOrNull?.kind, FailureKind.notFound);
    });

    test('saving writes to the seeker\'s own list and is reflected in the saved ids', () async {
      await repository.setSaved(myUid: 'me', companionUid: 'c1', saved: true);
      expect(await repository.watchSavedIds('me').first, {'c1'});
      final (kind, table, row) = tables.writes.single;
      expect((kind, table), ('upsert', 'saved_companions'));
      expect(row, {'uid': 'me', 'companion_uid': 'c1'});
      await repository.setSaved(myUid: 'me', companionUid: 'c1', saved: false);
      expect(await repository.watchSavedIds('me').first, isEmpty);
    });
  });

  group('DiscoverController', () {
    ProviderContainer container0(TestBackend backend) {
      final container = ProviderContainer(
        retry: noAutomaticRetry,
        overrides: baseOverrides(backend: backend),
      );
      addTearDown(container.dispose);
      container.listen(discoverControllerProvider, (_, _) {});
      return container;
    }

    test('starts on coffee; a plan can be picked', () {
      final container = container0(readyBackend());
      final controller = container.read(discoverControllerProvider.notifier);
      expect(container.read(discoverControllerProvider).plan, PlanType.coffee);
      controller.selectPlan(PlanType.walk);
      expect(container.read(discoverControllerProvider), const DiscoverState(plan: PlanType.walk));
    });

    test('save and unsave go to the repository', () async {
      final backend = readyBackend();
      final container = container0(backend);
      final controller = container.read(discoverControllerProvider.notifier);
      expect((await controller.toggleSave('a', saved: true)).isOk, isTrue);
      expect(backend.discover.savedIds.value, {'a'});
      await controller.toggleSave('a', saved: false);
      expect(backend.discover.savedIds.value, isEmpty);
    });

    test('saving while signed out is refused', () async {
      final container = container0(TestBackend());
      final result = await container.read(discoverControllerProvider.notifier).toggleSave('a', saved: true);
      expect(result.failureOrNull?.kind, FailureKind.unauthenticated);
    });
  });

  group('My profile', () {
    test('cleanDisplayName trims, collapses spaces and enforces the length', () {
      expect(cleanDisplayName('  Neha   Rao ', maxLength: 40), 'Neha Rao');
      expect(cleanDisplayName('   ', maxLength: 40), isNull);
      expect(cleanDisplayName('x' * 41, maxLength: 40), isNull);
    });

    test('saving a name updates the account', () async {
      final backend = readyBackend(displayName: null);
      final updated = backend.profile.nameUpdates;
      final container = ProviderContainer(
        retry: noAutomaticRetry,
        overrides: baseOverrides(backend: backend),
      );
      addTearDown(container.dispose);
      container.listen(myProfileControllerProvider, (_, _) {});
      await container.read(myProfileControllerProvider.notifier).saveName('  Aarav ');
      expect(updated, ['$testUid:Aarav']);
      expect(container.read(myProfileControllerProvider).saved, isTrue);

      await container.read(myProfileControllerProvider.notifier).saveName('');
      expect(container.read(myProfileControllerProvider).nameInvalid, isTrue);
    });

    test('sign out clears the session', () async {
      final backend = readyBackend();
      final container = ProviderContainer(
        retry: noAutomaticRetry,
        overrides: baseOverrides(backend: backend),
      );
      addTearDown(container.dispose);
      container.listen(myProfileControllerProvider, (_, _) {});
      await container.read(myProfileControllerProvider.notifier).signOut();
      expect(backend.auth.user.value, isNull);
    });

    test('deleting the account signs out; a failure is shown and keeps the session', () async {
      final backend = readyBackend()..auth.deleteFailure = const AppFailure(FailureKind.network);
      final container = ProviderContainer(
        retry: noAutomaticRetry,
        overrides: baseOverrides(backend: backend),
      );
      addTearDown(container.dispose);
      container.listen(myProfileControllerProvider, (_, _) {});
      final controller = container.read(myProfileControllerProvider.notifier);

      await controller.deleteAccount();
      expect(container.read(myProfileControllerProvider).failure?.kind, FailureKind.network);
      expect(backend.auth.user.value, isNotNull);

      backend.auth.deleteFailure = null;
      await controller.deleteAccount();
      expect(backend.auth.deletions, 1);
      expect(backend.auth.user.value, isNull);
    });
  });
}
