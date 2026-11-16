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
    final rows = await _tables
        .watch('app_config', primaryKey: const ['id'], where: (column: 'id', value: 1))
        .first
        .timeout(timeout);
    final overrides = rows.isEmpty ? null : rows.first['overrides'];
    if (overrides is! Map) return const <String, Object?>{};
    return {
      for (final entry in overrides.cast<String, Object?>().entries)
        if (defaults.containsKey(entry.key)) entry.key: entry.value,
    };
  });
}
