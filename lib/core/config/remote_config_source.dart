import '../backend/tables.dart';
import '../utils/result.dart';
import '../utils/run_guarded.dart';

/// Reads AppConfig overrides from a remote source.
abstract interface class RemoteConfigSource {
  /// Returns only the keys the remote source actually set.
  Future<Result<Map<String, Object?>>> fetchOverrides(Map<String, Object?> defaults);
}

/// The `app_config` table (one row) that the server reads too, so the app and
/// the server always agree on prices and limits. Edit it in the Supabase
/// Table Editor.
class SupabaseConfigSource implements RemoteConfigSource {
  SupabaseConfigSource(this._tables, {this.timeout = const Duration(seconds: 5)});

  final Tables _tables;
  final Duration timeout;

  @override
  Future<Result<Map<String, Object?>>> fetchOverrides(Map<String, Object?> defaults) => runGuarded(() async {
    // One plain read: much faster at start-up than opening a live subscription.
    final rows = await _tables.select('app_config', where: (column: 'id', value: 1)).timeout(timeout);
    final overrides = rows.isEmpty ? null : rows.first['overrides'];
    if (overrides is! Map) return const <String, Object?>{};
    return {
      for (final entry in overrides.cast<String, Object?>().entries)
        if (defaults.containsKey(entry.key)) entry.key: entry.value,
    };
  });
}
