import 'app_exception.dart';

/// Result type for handling success/failure states without exceptions
sealed class Result<T> {
  const Result();

  /// Fold the result into a single value
  R fold<R>(R Function(AppException) onError, R Function(T) onSuccess);

  /// Check if the result is successful
  bool get isSuccess => this is _Success<T>;

  /// Check if the result is an error
  bool get isError => this is _Error<T>;

  /// Get the success value or null
  T? get valueOrNull => isSuccess ? (this as _Success<T>).value : null;

  /// Get the error or null
  AppException? get errorOrNull => isError ? (this as _Error<T>).error : null;

  /// Create a successful result
  static Result<T> success<T>(T value) => _Success(value);

  /// Create an error result
  static Result<T> failure<T>(AppException error) => _Error(error);

  /// Transform the success value
  Result<R> map<R>(R Function(T) transform) {
    return fold(
      (error) => Result.failure(error),
      (value) => Result.success(transform(value)),
    );
  }

  /// Transform the error
  Result<T> mapError(AppException Function(AppException) transform) {
    return fold(
      (error) => Result.failure(transform(error)),
      (value) => Result.success(value),
    );
  }

  /// Chain async operations
  Future<Result<R>> flatMap<R>(Future<Result<R>> Function(T) transform) async {
    return fold(
      (error) => Result.failure<R>(error),
      (value) => transform(value),
    );
  }
}

class _Success<T> extends Result<T> {
  final T value;
  const _Success(this.value);

  @override
  R fold<R>(R Function(AppException) onError, R Function(T) onSuccess) {
    return onSuccess(value);
  }

  @override
  String toString() => 'Success($value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _Success<T> && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class _Error<T> extends Result<T> {
  final AppException error;
  const _Error(this.error);

  @override
  R fold<R>(R Function(AppException) onError, R Function(T) onSuccess) {
    return onError(error);
  }

  @override
  String toString() => 'Error($error)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _Error<T> && runtimeType == other.runtimeType && error == other.error;

  @override
  int get hashCode => error.hashCode;
}

/// Extension for async results
extension AsyncResultExtension<T> on Future<Result<T>> {
  /// Convert Future<Result<T>> to Future<T> that throws on error
  Future<T> unwrap() async {
    final result = await this;
    return result.fold(
      (error) => throw error,
      (value) => value,
    );
  }
}
