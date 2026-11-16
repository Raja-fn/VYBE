import 'app_failure.dart';

/// The outcome of a repository or service call.
///
/// Repositories return [Result] instead of throwing, so the UI only ever
/// deals with an [AppFailure] it knows how to explain.
sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;

  T? get valueOrNull => switch (this) {
    Ok(:final value) => value,
    Err() => null,
  };

  AppFailure? get failureOrNull => switch (this) {
    Ok() => null,
    Err(:final failure) => failure,
  };

  /// The value, or throws the [AppFailure]. For use inside providers, where
  /// a thrown failure becomes an `AsyncError` the UI already knows how to show.
  T get valueOrThrow => switch (this) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };

  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Ok(:final value) => Ok(transform(value)),
    Err(:final failure) => Err(failure),
  };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;

  @override
  bool operator ==(Object other) => other is Ok<T> && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final AppFailure failure;

  @override
  bool operator ==(Object other) => other is Err<T> && other.failure == failure;

  @override
  int get hashCode => failure.hashCode;
}
