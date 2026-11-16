import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vybe/core/backend/callable_client.dart';
import 'package:vybe/core/utils/app_failure.dart';
import 'package:vybe/core/utils/result.dart';
import 'package:vybe/core/utils/run_guarded.dart';

void main() {
  group('Result', () {
    test('Ok exposes its value and maps', () {
      const Result<int> result = Ok(2);
      expect(result.isOk, isTrue);
      expect(result.valueOrNull, 2);
      expect(result.map((v) => v * 3), const Ok(6));
    });

    test('Err exposes its failure and map keeps it', () {
      const Result<int> result = Err(AppFailure(FailureKind.notFound));
      expect(result.isOk, isFalse);
      expect(result.valueOrNull, isNull);
      expect(result.map((v) => v * 3).failureOrNull?.kind, FailureKind.notFound);
    });
  });

  group('mapError', () {
    test('uses the reason the server sends', () {
      const error = ServerException('failed-precondition', code: 'insufficient_credits', message: 'Not enough credits');
      expect(mapError(error).kind, FailureKind.insufficientCredits);
    });

    test('falls back to the generic status', () {
      expect(mapError(const ServerException('resource-exhausted')).kind, FailureKind.rateLimited);
      expect(mapError(const ServerException('unauthenticated')).kind, FailureKind.unauthenticated);
      expect(mapError(const ServerException('internal')).kind, FailureKind.unknown);
    });

    test('reads the error body of the api function', () {
      final error = serverExceptionFrom(412, {
        'error': {'status': 'failed-precondition', 'code': 'slot_full', 'message': 'That time just filled up.'},
      });
      expect(mapError(error).kind, FailureKind.slotFull);
      expect(mapError(serverExceptionFrom(503, 'gateway down')).kind, FailureKind.network);
      expect(mapError(serverExceptionFrom(401, null)).kind, FailureKind.unauthenticated);
    });

    test('maps row-level security refusals and expired sign-ins on direct reads and writes', () {
      expect(mapError(const PostgrestException(message: 'denied', code: '42501')).kind, FailureKind.permissionDenied);
      expect(
        mapError(const PostgrestException(message: 'JWT expired', code: 'PGRST301')).kind,
        FailureKind.unauthenticated,
      );
    });

    test('maps sign-in and storage errors', () {
      expect(mapError(const AuthException('slow down', statusCode: '429')).kind, FailureKind.rateLimited);
      expect(mapError(const StorageException('no', statusCode: '403')).kind, FailureKind.permissionDenied);
    });

    test('maps socket and timeout errors to network', () {
      expect(mapError(const SocketException('down')).kind, FailureKind.network);
      expect(mapError(TimeoutException('slow')).kind, FailureKind.network);
      expect(mapError(ClientException('Connection closed')).kind, FailureKind.network);
    });

    test('keeps an AppFailure as-is and maps anything else to unknown', () {
      const failure = AppFailure(FailureKind.blocked);
      expect(mapError(failure), failure);
      expect(mapError(StateError('boom')).kind, FailureKind.unknown);
    });
  });

  group('runGuarded', () {
    test('wraps a value in Ok', () async {
      expect(await runGuarded(() async => 'hi'), const Ok('hi'));
    });

    test('turns a thrown error into Err', () async {
      final result = await runGuarded<String>(() async => throw const ServerException('unauthenticated'));
      expect(result.failureOrNull?.kind, FailureKind.unauthenticated);
    });
  });
}
