import 'dart:async';

import 'package:findx/core/backend/tables.dart';

/// In-memory [Tables]: rows per table, live `watch` streams, and a log of
/// writes. Row-level security is not modelled (that is tested on the server);
/// a test seeds only the rows the person could see.
class FakeTables implements Tables {
  final Map<String, List<Map<String, Object?>>> rows = {};
  final List<(String, String, Map<String, Object?>)> writes = [];
  final _changes = StreamController<String>.broadcast();

  /// When set, every write throws it (for failure tests).
  Object? writeError;

  List<Map<String, Object?>> table(String name) => rows.putIfAbsent(name, () => []);

  /// Seeds or replaces rows without logging a write, and tells watchers.
  void seed(String name, List<Map<String, Object?>> seeded) {
    table(name).addAll(seeded.map(Map.of));
    _changes.add(name);
  }

  @override
  Stream<List<Map<String, Object?>>> watch(
    String table, {
    required List<String> primaryKey,
    Where? where,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    List<Map<String, Object?>> current() {
      var list = [
        for (final row in this.table(table))
          if (where == null || row[where.column] == where.value) Map.of(row),
      ];
      if (orderBy != null) {
        list.sort((a, b) {
          final x = a[orderBy] as Comparable<Object>?;
          final y = b[orderBy] as Comparable<Object>?;
          final order = x == null ? (y == null ? 0 : -1) : (y == null ? 1 : x.compareTo(y));
          return descending ? -order : order;
        });
      }
      if (limit != null && list.length > limit) list = list.sublist(0, limit);
      return list;
    }

    late final StreamController<List<Map<String, Object?>>> controller;
    StreamSubscription<String>? changes;
    controller = StreamController(
      onListen: () {
        controller.add(current());
        changes = _changes.stream.where((t) => t == table).listen((_) => controller.add(current()));
      },
      onCancel: () => changes?.cancel(),
    );
    return controller.stream;
  }

  bool _matches(Map<String, Object?> row, List<Where> where) => where.every((w) => row[w.column] == w.value);

  void _write(String kind, String name, Map<String, Object?> data) {
    final error = writeError;
    if (error != null) throw error;
    writes.add((kind, name, Map.of(data)));
  }

  /// Primary keys of the tables the app writes to.
  static const _keys = {
    'preferences': ['uid'],
    'users': ['id'],
    'saved_companions': ['uid', 'companion_uid'],
  };

  @override
  Future<void> upsert(String name, Map<String, Object?> row, {bool ignoreDuplicates = false}) async {
    _write('upsert', name, row);
    final keys = _keys[name] ?? const ['id'];
    final list = table(name);
    final index = list.indexWhere((r) => keys.every((k) => r[k] == row[k]));
    if (index >= 0 && ignoreDuplicates) return;
    if (index >= 0) {
      list[index] = {...list[index], ...row};
    } else {
      list.add(Map.of(row));
    }
    _changes.add(name);
  }

  @override
  Future<void> insert(String name, Map<String, Object?> row) async {
    _write('insert', name, row);
    table(name).add(Map.of(row));
    _changes.add(name);
  }

  @override
  Future<void> update(String name, Map<String, Object?> values, {required List<Where> where}) async {
    _write('update', name, {...values, for (final w in where) 'where:${w.column}': w.value});
    final list = table(name);
    for (var i = 0; i < list.length; i++) {
      if (_matches(list[i], where)) list[i] = {...list[i], ...values};
    }
    _changes.add(name);
  }

  @override
  Future<void> delete(String name, {required List<Where> where}) async {
    _write('delete', name, {for (final w in where) w.column: w.value});
    table(name).removeWhere((row) => _matches(row, where));
    _changes.add(name);
  }
}
