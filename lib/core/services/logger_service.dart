import 'package:flutter/foundation.dart';

/// LoggerService - Simple logging service
///
/// Chức năng:
/// - Log messages với các mức độ khác nhau
/// - Chỉ log trong debug mode
/// - Có thể mở rộng để ghi log vào file hoặc analytics
class LoggerService {
  static const String _tag = 'IdleUniverse';

  /// Log debug message
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] DEBUG: $message');
    }
  }

  /// Log info message
  static void info(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] INFO: $message');
    }
  }

  /// Log warning message
  static void warning(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] WARNING: $message');
    }
  }

  /// Log error message
  static void error(String message,
      [Object? error, StackTrace? stackTrace, String? tag]) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] ERROR: $message');
      if (error != null) {
        debugPrint('Error details: $error');
      }
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  /// Log success message
  static void success(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] SUCCESS: $message');
    }
  }
}
