import 'package:supabase_flutter/supabase_flutter.dart';

/// One equality filter (`column = value`).
typedef Where = ({String column, Object value});

/// The database tables the app reads and writes directly. Row-level security
/// on the server decides what each person may see and change. Behind an
/// interface so repositories can be tested without a backend.
abstract interface class Tables {
  /// The matching rows now, then again whenever they change.
  Stream<List<Map<String, Object?>>> watch(
    String table, {
    required List<String> primaryKey,
    Where? where,
    String? orderBy,
    bool descending = false,
    int? limit,
  });

  /// Inserts the row, or updates it when its primary key already exists.
  /// With [ignoreDuplicates], an existing row is left as it is.
  Future<void> upsert(String table, Map<String, Object?> row, {bool ignoreDuplicates = false});

  Future<void> insert(String table, Map<String, Object?> row);

  Future<void> update(String table, Map<String, Object?> values, {required List<Where> where});

  Future<void> delete(String table, {required List<Where> where});
}

/// [Tables] on Supabase: PostgREST for writes, Realtime for live reads.
class SupabaseTables implements Tables {
  SupabaseTables(this._client);

  final SupabaseClient _client;

  @override
  Stream<List<Map<String, Object?>>> watch(
    String table, {
    required List<String> primaryKey,
    Where? where,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    final base = _client.from(table).stream(primaryKey: primaryKey);
    final SupabaseStreamBuilder filtered = where == null ? base : base.eq(where.column, where.value);
    var query = filtered;
    if (orderBy != null) query = query.order(orderBy, ascending: !descending);
    if (limit != null) query = query.limit(limit);
    return query.map((rows) => [for (final row in rows) row.cast<String, Object?>()]);
  }

  @override
  Future<void> upsert(String table, Map<String, Object?> row, {bool ignoreDuplicates = false}) =>
      _client.from(table).upsert(row, ignoreDuplicates: ignoreDuplicates);

  @override
  Future<void> insert(String table, Map<String, Object?> row) => _client.from(table).insert(row);

  @override
  Future<void> update(String table, Map<String, Object?> values, {required List<Where> where}) {
    var query = _client.from(table).update(values);
    for (final filter in where) {
      query = query.eq(filter.column, filter.value);
    }
    return query;
  }

  @override
  Future<void> delete(String table, {required List<Where> where}) {
    var query = _client.from(table).delete();
    for (final filter in where) {
      query = query.eq(filter.column, filter.value);
    }
    return query;
  }
}

/// Reads a timestamp column (ISO 8601 text from the server) as local time.
DateTime? parseTime(Object? value) => switch (value) {
  final String text => DateTime.tryParse(text)?.toLocal(),
  final DateTime time => time.toLocal(),
  _ => null,
};
