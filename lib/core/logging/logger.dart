import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

/// Centralized logger for the application
class Logger {
  static const String _defaultTag = 'MELO_AI';

  /// Log debug messages (only in debug mode)
  static void d(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      dev.log(
        message,
        name: tag ?? _defaultTag,
        level: 500, // Debug level
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Log info messages
  static void i(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    dev.log(
      message,
      name: tag ?? _defaultTag,
      level: 800, // Info level
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log warning messages
  static void w(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    dev.log(
      message,
      name: tag ?? _defaultTag,
      level: 900, // Warning level
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log error messages
  static void e(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    dev.log(
      message,
      name: tag ?? _defaultTag,
      level: 1000, // Error level
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log function entry/exit for debugging
  static void trace(String functionName, {String? tag, String? params}) {
    if (kDebugMode) {
      final message = params != null ? '$functionName($params)' : '$functionName()';
      d('🔹 $message', tag: tag);
    }
  }

  /// Log navigation events
  static void nav(String from, String to, {String? tag}) {
    i('🧭 Navigation: $from → $to', tag: tag ?? 'NAVIGATION');
  }

  /// Log audio events
  static void audio(String event, {String? tag, Map<String, dynamic>? metadata}) {
    final meta = metadata != null ? ' | ${metadata.toString()}' : '';
    i('🎵 Audio: $event$meta', tag: tag ?? 'AUDIO');
  }

  /// Log state changes
  static void state(String state, {String? tag, Map<String, dynamic>? data}) {
    final dataStr = data != null ? ' | ${data.toString()}' : '';
    d('🔄 State: $state$dataStr', tag: tag ?? 'STATE');
  }

  /// Log network events
  static void network(String event, {String? tag, Map<String, dynamic>? details}) {
    final detailsStr = details != null ? ' | ${details.toString()}' : '';
    i('🌐 Network: $event$detailsStr', tag: tag ?? 'NETWORK');
  }
}
