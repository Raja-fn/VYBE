import 'package:supabase_flutter/supabase_flutter.dart';

/// A server action failed. [status] is the generic kind (for example
/// `failed-precondition`); [code] is VYBE's own reason (for example
/// `insufficient_credits`) when the server gave one.
class ServerException implements Exception {
  const ServerException(this.status, {this.code, this.message});

  final String status;
  final String? code;
  final String? message;

  @override
  String toString() => 'ServerException($status, code: $code, message: $message)';
}

/// Calls a server action by name. Behind an interface so repositories can be
/// tested without a backend.
abstract interface class CallableClient {
  /// Throws on failure ([ServerException] for answers from the server);
  /// callers wrap calls in `runGuarded`.
  Future<Map<String, Object?>> call(String name, [Map<String, Object?> data = const {}]);
}

/// Calls the `api` Edge Function (`POST /functions/v1/api/<name>`). The
/// signed-in person's access token is sent automatically.
class SupabaseCallableClient implements CallableClient {
  SupabaseCallableClient(this._functions);

  final FunctionsClient _functions;

  @override
  Future<Map<String, Object?>> call(String name, [Map<String, Object?> data = const {}]) async {
    try {
      final response = await _functions.invoke('api/$name', body: data);
      final value = response.data;
      if (value is Map) return value.cast<String, Object?>();
      return const {};
    } on FunctionException catch (error) {
      throw serverExceptionFrom(error.status, error.details);
    }
  }
}

/// Reads the server's error body `{ "error": { status, code, message } }`.
ServerException serverExceptionFrom(int httpStatus, Object? body) {
  final error = body is Map ? body['error'] : null;
  if (error is Map) {
    return ServerException(
      (error['status'] as String?) ?? _statusForHttp(httpStatus),
      code: error['code'] as String?,
      message: error['message'] as String?,
    );
  }
  return ServerException(_statusForHttp(httpStatus), message: body?.toString());
}

String _statusForHttp(int status) => switch (status) {
  400 => 'invalid-argument',
  401 => 'unauthenticated',
  403 => 'permission-denied',
  404 => 'not-found',
  412 => 'failed-precondition',
  429 => 'resource-exhausted',
  502 || 503 || 504 => 'unavailable',
  _ => 'internal',
};
