import '../../../core/backend/tables.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/run_guarded.dart';
import '../domain/preferences.dart';

abstract interface class PreferencesRepository {
  /// Emits null only when the server confirms there are no preferences yet.
  Stream<Preferences?> watch(String uid);

  Future<Result<void>> save(String uid, Preferences preferences);
}

class SupabasePreferencesRepository implements PreferencesRepository {
  SupabasePreferencesRepository(this._tables);

  final Tables _tables;

  @override
  Stream<Preferences?> watch(String uid) => _tables
      .watch('preferences', primaryKey: const ['uid'], where: (column: 'uid', value: uid))
      .map((rows) => rows.isEmpty ? null : preferencesFromRow(rows.first));

  @override
  Future<Result<void>> save(String uid, Preferences preferences) => runGuarded(() async {
    await _tables.upsert('preferences', {'uid': uid, ...preferencesToRow(preferences)});
  });
}

/// The `preferences` row columns (snake_case) for these preferences.
Map<String, Object?> preferencesToRow(Preferences p) {
  final json = p.toJson();
  return {
    'gender': json['gender'],
    'show_me': json['showMe'],
    'age_min': json['ageMin'],
    'age_max': json['ageMax'],
    'show_gender': json['showGender'],
    'who_can_request': json['whoCanRequest'],
  };
}

Preferences preferencesFromRow(Map<String, Object?> row) => Preferences.fromJson({
  'gender': row['gender'],
  'showMe': row['show_me'],
  'ageMin': row['age_min'],
  'ageMax': row['age_max'],
  'showGender': row['show_gender'],
  'whoCanRequest': row['who_can_request'],
});
