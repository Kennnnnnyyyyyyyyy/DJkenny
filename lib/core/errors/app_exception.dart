/// Base exception class for application errors
class AppException implements Exception {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;
  final String code;

  const AppException(
    this.message, {
    this.cause,
    this.stackTrace,
    this.code = 'unknown',
  });

  /// Network-related errors
  factory AppException.network(String message, {Object? cause, StackTrace? stackTrace}) =>
      AppException(
        message,
        cause: cause,
        stackTrace: stackTrace,
        code: 'network_error',
      );

  /// Authentication errors
  factory AppException.auth(String message, {Object? cause, StackTrace? stackTrace}) =>
      AppException(
        message,
        cause: cause,
        stackTrace: stackTrace,
        code: 'auth_error',
      );

  /// Resource not found errors
  factory AppException.notFound(String message) => AppException(
        message,
        code: 'not_found',
      );

  /// Validation errors
  factory AppException.validation(String message) => AppException(
        message,
        code: 'validation_error',
      );

  /// Server errors
  factory AppException.server(String message, {Object? cause, StackTrace? stackTrace}) =>
      AppException(
        message,
        cause: cause,
        stackTrace: stackTrace,
        code: 'server_error',
      );

  /// Audio/Player errors
  factory AppException.audio(String message, {Object? cause, StackTrace? stackTrace}) =>
      AppException(
        message,
        cause: cause,
        stackTrace: stackTrace,
        code: 'audio_error',
      );

  /// Generic factory to wrap any exception
  factory AppException.from(Object error, StackTrace stackTrace) {
    if (error is AppException) return error;
    
    return AppException(
      error.toString(),
      cause: error,
      stackTrace: stackTrace,
      code: 'wrapped_error',
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer('AppException($code): $message');
    if (cause != null) {
      buffer.write('\nCause: $cause');
    }
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppException &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code;

  @override
  int get hashCode => message.hashCode ^ code.hashCode;
}
