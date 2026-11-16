import '../../../core/backend/callable_client.dart';
import '../../../core/backend/tables.dart';
import '../../../core/location/location_service.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/run_guarded.dart';
import '../domain/companion_summary.dart';

/// Discovery is served by the server (radius, matching and blocks are
/// enforced there); saving a companion is a plain write to the seeker's own list.
abstract interface class DiscoverRepository {
  Future<Result<void>> updateLocation(DevicePosition position);

  Future<Result<List<CompanionSummary>>> discover(PlanType? plan);

  Future<Result<List<CompanionSummary>>> freeNow(FreeWindow window);

  Future<Result<CompanionSummary>> profile(String uid);

  Future<Result<List<CompanionSummary>>> saved();

  Stream<Set<String>> watchSavedIds(String myUid);

  Future<Result<void>> setSaved({required String myUid, required String companionUid, required bool saved});
}

class SupabaseDiscoverRepository implements DiscoverRepository {
  SupabaseDiscoverRepository({required CallableClient functions, required Tables tables})
    : _functions = functions,
      _tables = tables;

  final CallableClient _functions;
  final Tables _tables;

  static List<CompanionSummary> _list(Map<String, Object?> data) => ((data['companions'] as List?) ?? const [])
      .map((item) => CompanionSummary.fromJson((item as Map).cast<String, Object?>()))
      .toList();

  @override
  Future<Result<void>> updateLocation(DevicePosition position) => runGuarded(() async {
    await _functions.call('updateMyLocation', {
      'lat': position.lat,
      'lng': position.lng,
      'accuracyM': position.accuracyM,
    });
  });

  @override
  Future<Result<List<CompanionSummary>>> discover(PlanType? plan) =>
      runGuarded(() async => _list(await _functions.call('discoverCompanions', {'planType': plan?.name})));

  @override
  Future<Result<List<CompanionSummary>>> freeNow(FreeWindow window) =>
      runGuarded(() async => _list(await _functions.call('freeNowCompanions', {'window': window.wire})));

  @override
  Future<Result<CompanionSummary>> profile(String uid) =>
      runGuarded(() async => CompanionSummary.fromJson(await _functions.call('getCompanionProfile', {'uid': uid})));

  @override
  Future<Result<List<CompanionSummary>>> saved() =>
      runGuarded(() async => _list(await _functions.call('savedCompanions')));

  @override
  Stream<Set<String>> watchSavedIds(String myUid) => _tables
      .watch('saved_companions', primaryKey: const ['uid', 'companion_uid'], where: (column: 'uid', value: myUid))
      .map((rows) => {for (final row in rows) row['companion_uid']! as String});

  @override
  Future<Result<void>> setSaved({required String myUid, required String companionUid, required bool saved}) =>
      runGuarded(() async {
        if (saved) {
          // Saving twice keeps the first save (people may only add or remove saves).
          await _tables.upsert('saved_companions', {
            'uid': myUid,
            'companion_uid': companionUid,
          }, ignoreDuplicates: true);
        } else {
          await _tables.delete(
            'saved_companions',
            where: [(column: 'uid', value: myUid), (column: 'companion_uid', value: companionUid)],
          );
        }
      });
}
