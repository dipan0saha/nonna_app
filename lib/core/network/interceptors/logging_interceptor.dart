import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Logging interceptor for request/response logging with sensitive data redaction
///
/// **Functional Requirements**: Section 3.2.5 - Network Layer
/// Reference: docs/Core_development_component_identification.md
///
/// Features:
/// - Request/response logging for debugging
/// - Sensitive data redaction (tokens, passwords, etc.)
/// - Performance metrics tracking
/// - Debug mode only operation
///
/// Dependencies: None
class LoggingInterceptor {
  static const List<String> _sensitiveFields = [
    'password',
    'token',
    'access_token',
    'refresh_token',
    'authorization',
    'apikey',
    'secret',
    'api_key',
    'auth',
    'bearer',
  ];

  /// Log an HTTP request
  ///
  /// [method] HTTP method (GET, POST, etc.)
  /// [url] Request URL
  /// [headers] Request headers
  /// [body] Request body
  void logRequest(
    String method,
    String url, {
    Map<String, String>? headers,
    dynamic body,
  }) {
    if (!kDebugMode) return;

    final startTime = DateTime.now();
    debugPrint('┌─────────────────────────────────────────────────────────');
    debugPrint('│ 📤 REQUEST: $method $url');
    debugPrint('│ Time: ${startTime.toIso8601String()}');
    
    if (headers != null && headers.isNotEmpty) {
      debugPrint('│ Headers:');
      final redactedHeaders = _redactSensitiveData(headers);
      redactedHeaders.forEach((key, value) {
        debugPrint('│   $key: $value');
      });
    }

    if (body != null) {
      debugPrint('│ Body:');
      final bodyString = _formatBody(body);
      final redactedBody = _redactSensitiveDataInString(bodyString);
      debugPrint('│   $redactedBody');
    }
    
    debugPrint('└─────────────────────────────────────────────────────────');
  }

  /// Log an HTTP response
  ///
  /// [method] HTTP method
  /// [url] Request URL
  /// [statusCode] Response status code
  /// [responseBody] Response body
  /// [duration] Request duration
  void logResponse(
    String method,
    String url,
    int statusCode, {
    dynamic responseBody,
    Duration? duration,
  }) {
    if (!kDebugMode) return;

    final endTime = DateTime.now();
    final statusEmoji = _getStatusEmoji(statusCode);
    
    debugPrint('┌─────────────────────────────────────────────────────────');
    debugPrint('│ 📥 RESPONSE: $statusEmoji $statusCode - $method $url');
    debugPrint('│ Time: ${endTime.toIso8601String()}');
    
    if (duration != null) {
      debugPrint('│ Duration: ${duration.inMilliseconds}ms');
      _logPerformanceMetrics(duration);
    }

    if (responseBody != null) {
      debugPrint('│ Body:');
      final bodyString = _formatBody(responseBody);
      final redactedBody = _redactSensitiveDataInString(bodyString);
      
      // Truncate very long responses
      final truncatedBody = _truncateString(redactedBody, 1000);
      debugPrint('│   $truncatedBody');
    }
    
    debugPrint('└─────────────────────────────────────────────────────────');
  }

  /// Log an error
  ///
  /// [method] HTTP method
  /// [url] Request URL
  /// [error] Error object
  /// [stackTrace] Stack trace
  void logError(
    String method,
    String url,
    Object error, {
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;

    debugPrint('┌─────────────────────────────────────────────────────────');
    debugPrint('│ ❌ ERROR: $method $url');
    debugPrint('│ Error: ${error.toString()}');
    
    if (stackTrace != null) {
      debugPrint('│ Stack Trace:');
      final stackLines = stackTrace.toString().split('\n').take(5);
      for (final line in stackLines) {
        debugPrint('│   $line');
      }
    }
    
    debugPrint('└─────────────────────────────────────────────────────────');
  }

  /// Log performance metrics
  void _logPerformanceMetrics(Duration duration) {
    final milliseconds = duration.inMilliseconds;
    
    if (milliseconds > 3000) {
      debugPrint('│ ⚠️  Performance: SLOW (${milliseconds}ms)');
    } else if (milliseconds > 1000) {
      debugPrint('│ ⚡ Performance: MODERATE (${milliseconds}ms)');
    } else {
      debugPrint('│ ⚡ Performance: FAST (${milliseconds}ms)');
    }
  }

  /// Redact sensitive data from a map
  Map<String, dynamic> _redactSensitiveData(Map<dynamic, dynamic> data) {
    final redacted = <String, dynamic>{};
    
    data.forEach((key, value) {
      final keyString = key.toString().toLowerCase();
      
      if (_sensitiveFields.any((field) => keyString.contains(field))) {
        redacted[key.toString()] = '[REDACTED]';
      } else if (value is Map) {
        redacted[key.toString()] = _redactSensitiveData(value);
      } else if (value is List) {
        redacted[key.toString()] = value.map((item) {
          if (item is Map) {
            return _redactSensitiveData(item);
          }
          return item;
        }).toList();
      } else {
        redacted[key.toString()] = value;
      }
    });
    
    return redacted;
  }

  /// Redact sensitive data from a string
  String _redactSensitiveDataInString(String data) {
    var redacted = data;
    
    for (final field in _sensitiveFields) {
      // Redact JSON field values
      final pattern = RegExp(
        '"$field"\\s*:\\s*"[^"]*"',
        caseSensitive: false,
      );
      redacted = redacted.replaceAll(pattern, '"$field":"[REDACTED]"');
      
      // Redact header values
      final headerPattern = RegExp(
        '$field:\\s*[^\\s]+',
        caseSensitive: false,
      );
      redacted = redacted.replaceAll(headerPattern, '$field: [REDACTED]');
    }
    
    return redacted;
  }

  /// Format body for logging
  String _formatBody(dynamic body) {
    if (body == null) {
      return 'null';
    }
    
    if (body is String) {
      try {
        final decoded = jsonDecode(body);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      } catch (e) {
        return body;
      }
    }
    
    if (body is Map || body is List) {
      try {
        return const JsonEncoder.withIndent('  ').convert(body);
      } catch (e) {
        return body.toString();
      }
    }
    
    return body.toString();
  }

  /// Get emoji for status code
  String _getStatusEmoji(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) {
      return '✅';
    } else if (statusCode >= 300 && statusCode < 400) {
      return '↪️';
    } else if (statusCode >= 400 && statusCode < 500) {
      return '⚠️';
    } else if (statusCode >= 500) {
      return '❌';
    }
    return '❓';
  }

  /// Truncate string to max length
  String _truncateString(String str, int maxLength) {
    if (str.length <= maxLength) {
      return str;
    }
    return '${str.substring(0, maxLength)}... [truncated ${str.length - maxLength} chars]';
  }

  /// Create a summary log for bulk operations
  ///
  /// [operationName] Name of the bulk operation
  /// [count] Number of items processed
  /// [duration] Operation duration
  void logBulkOperation(
    String operationName,
    int count, {
    Duration? duration,
  }) {
    if (!kDebugMode) return;

    debugPrint('┌─────────────────────────────────────────────────────────');
    debugPrint('│ 📦 BULK OPERATION: $operationName');
    debugPrint('│ Items: $count');
    
    if (duration != null) {
      debugPrint('│ Duration: ${duration.inMilliseconds}ms');
      debugPrint('│ Average: ${(duration.inMilliseconds / count).toStringAsFixed(2)}ms per item');
    }
    
    debugPrint('└─────────────────────────────────────────────────────────');
  }
}
