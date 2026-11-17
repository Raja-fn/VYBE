import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vybe/core/backend/tables.dart';
import 'package:vybe/core/config/app_config.dart';
import 'package:vybe/core/config/app_config_repository.dart';
import 'package:vybe/core/config/remote_config_source.dart';
import 'package:vybe/core/utils/app_failure.dart';
import 'package:vybe/core/utils/result.dart';

import '../../helpers/fake_tables.dart';

class _StringBundle extends CachingAssetBundle {
  _StringBundle(this.content);

  final String content;

  @override
  Future<ByteData> load(String key) async => ByteData.sublistView(Uint8List.fromList(utf8.encode(content)));
}

class _FakeRemote implements RemoteConfigSource {
  _FakeRemote(this.result);

  final Result<Map<String, Object?>> result;

  @override
  Future<Result<Map<String, Object?>>> fetchOverrides(Map<String, Object?> defaults) async => result;
}

void main() {
  final defaultsJson = File('config/app_config_defaults.json').readAsStringSync();

  Future<AppConfig> loadOk({RemoteConfigSource? remote}) async {
    final result = await AppConfigRepository(bundle: _StringBundle(defaultsJson), remote: remote).load();
    expect(result, isA<Ok<AppConfig>>());
    return result.valueOrNull!;
  }

  group('AppConfigRepository', () {
    test('loads the bundled defaults with the agreed business numbers', () async {
      final config = await loadOk();
      expect(config.discoveryRadiusKm, 5);
      expect(config.signupBonusCredits, 20);
      expect(config.creditCostStartChat, 1);
      expect(config.creditCostBookSpot, 5);
      expect(config.creditCostInstantRequest, 5);
      expect(config.plans.map((p) => (p.tier, p.monthlyCredits)), [
        (PlanTier.free, 0),
        (PlanTier.plus, 100),
        (PlanTier.premium, 200),
      ]);
      expect(config.topUpPacks.map((p) => p.credits), [10, 30, 75]);
      expect(config.launchCity.name, 'Mumbai');
      expect(config.sosHoldSeconds, 3);
      expect(config.voiceIntroMaxSec, 15);
      expect(config.moderationStrikesForReport, 3);
    });

    test('applies remote overrides, including nested values', () async {
      final config = await loadOk(
        remote: _FakeRemote(
          const Ok({
            'creditCostBookSpot': 7,
            'topUpPacks': [
              {'productId': 'vybe_credits_10', 'credits': 12},
            ],
          }),
        ),
      );
      expect(config.creditCostBookSpot, 7);
      expect(config.topUpPacks.single.credits, 12);
      expect(config.discoveryRadiusKm, 5);
    });

    test('falls back to defaults when Remote Config fails', () async {
      final config = await loadOk(remote: _FakeRemote(const Err(AppFailure(FailureKind.network))));
      expect(config.creditCostBookSpot, 5);
    });

    test('falls back to defaults when a remote value has the wrong type', () async {
      final config = await loadOk(remote: _FakeRemote(const Ok({'creditCostBookSpot': 'lots'})));
      expect(config.creditCostBookSpot, 5);
    });

    test('returns an error when the bundled defaults are malformed', () async {
      final result = await AppConfigRepository(bundle: _StringBundle('{not json')).load();
      expect(result.failureOrNull?.kind, FailureKind.unknown);
    });

    test('returns an error when the bundled defaults are missing keys', () async {
      final result = await AppConfigRepository(bundle: _StringBundle('{"discoveryRadiusKm": 5}')).load();
      expect(result, isA<Err<AppConfig>>());
    });
  });

  group('SupabaseConfigSource', () {
    test('reads only known keys from the app_config row', () async {
      final tables = FakeTables()
        ..seed('app_config', [
          {
            'id': 1,
            'overrides': {'creditCostBookSpot': 6, 'somethingNew': true},
          },
        ]);
      final result = await SupabaseConfigSource(tables).fetchOverrides({'creditCostBookSpot': 5});
      expect(result.valueOrNull, {'creditCostBookSpot': 6});
    });

    test('no row means no overrides; a stalled connection is a failure, not a hang', () async {
      expect((await SupabaseConfigSource(FakeTables()).fetchOverrides(const {})).valueOrNull, isEmpty);
      final stalled = SupabaseConfigSource(_StalledTables(), timeout: const Duration(milliseconds: 10));
      expect((await stalled.fetchOverrides(const {})).failureOrNull?.kind, FailureKind.network);
    });
  });
}

class _StalledTables extends FakeTables {
  @override
  Future<List<Map<String, Object?>>> select(String table, {Where? where}) =>
      Completer<List<Map<String, Object?>>>().future;
}
