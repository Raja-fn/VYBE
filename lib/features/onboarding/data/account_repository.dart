import '../../../core/backend/callable_client.dart';
import '../../../core/backend/tables.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/run_guarded.dart';
import '../domain/account.dart';

/// The signed-in person's own account.
abstract interface class AccountRepository {
  /// Emits null only when the server confirms there is no account yet.
  Stream<Account?> watchAccount(String uid);

  /// Records consent and, the first time, creates the account (with the
  /// signup credits). Safe to call more than once.
  /// [dateOfBirth] is the day the person typed (only the date part is sent).
  Future<Result<void>> acceptRules({required int rulesVersion, required DateTime dateOfBirth});
}

class SupabaseAccountRepository implements AccountRepository {
  SupabaseAccountRepository({required Tables tables, required CallableClient functions})
    : _tables = tables,
      _functions = functions;

  final Tables _tables;
  final CallableClient _functions;

  @override
  Stream<Account?> watchAccount(String uid) => _tables
      .watch('users', primaryKey: const ['id'], where: (column: 'id', value: uid))
      .map((rows) => rows.isEmpty ? null : accountFromRow(rows.first));

  @override
  Future<Result<void>> acceptRules({required int rulesVersion, required DateTime dateOfBirth}) => runGuarded(() async {
    await _functions.call('acceptRules', {
      'rulesVersion': rulesVersion,
      'ageConfirmed': true,
      'dateOfBirth': birthDateKey(dateOfBirth),
    });
  });
}

/// yyyy-MM-dd for a date of birth.
String birthDateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Whole years between [dateOfBirth] and [today].
int ageOnDay(DateTime dateOfBirth, DateTime today) {
  var age = today.year - dateOfBirth.year;
  if (today.month < dateOfBirth.month || (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) age -= 1;
  return age;
}

/// Builds an [Account] from a `users` row.
Account accountFromRow(Map<String, Object?> row) => Account.fromJson({
  'uid': row['id'],
  'accountType': row['account_type'],
  'verificationStatus': row['verification_status'],
  'verificationSteps': row['verification_steps'],
  'accountStatus': row['account_status'],
  'verificationReason': row['verification_reason'],
  'displayName': row['display_name'],
  'ageYears': row['age_years'],
  'photoPaths': row['photo_paths'] ?? const <String>[],
});
