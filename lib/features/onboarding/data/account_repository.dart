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
  Future<Result<void>> acceptRules({required int rulesVersion});
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
  Future<Result<void>> acceptRules({required int rulesVersion}) => runGuarded(() async {
    await _functions.call('acceptRules', {'rulesVersion': rulesVersion, 'ageConfirmed': true});
  });
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
