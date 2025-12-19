import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Utility class for handling HTTP API requests, responses, and retries.
///
/// Provides methods for making HTTP requests with automatic retry logic,
/// error handling, and response parsing.
class ApiUtils {
  ApiUtils._(); // Private constructor to prevent instantiation

  /// Default timeout duration for API requests
  static const Duration defaultTimeout = Duration(seconds: 30);

  /// Default number of retry attempts
  static const int defaultMaxRetries = 3;

  /// Default delay between retries
  static const Duration defaultRetryDelay = Duration(seconds: 2);

  /// Makes a GET request with retry logic.
  ///
  /// [url] - The URL to send the request to
  /// [headers] - Optional headers to include in the request
  /// [timeout] - Request timeout duration
  /// [maxRetries] - Maximum number of retry attempts
  /// [retryDelay] - Delay between retry attempts
  ///
  /// Returns the response body as a string.
  /// Throws [ApiException] if the request fails after all retries.
  static Future<String> get(
    String url, {
    Map<String, String>? headers,
    Duration timeout = defaultTimeout,
    int maxRetries = defaultMaxRetries,
    Duration retryDelay = defaultRetryDelay,
  }) async {
    return _executeWithRetry(
      () => _makeGetRequest(url, headers, timeout),
      maxRetries: maxRetries,
      retryDelay: retryDelay,
    );
  }

  /// Makes a POST request with retry logic.
  ///
  /// [url] - The URL to send the request to
  /// [body] - The request body (will be JSON encoded if it's a Map)
  /// [headers] - Optional headers to include in the request
  /// [timeout] - Request timeout duration
  /// [maxRetries] - Maximum number of retry attempts
  /// [retryDelay] - Delay between retry attempts
  ///
  /// Returns the response body as a string.
  /// Throws [ApiException] if the request fails after all retries.
  static Future<String> post(
    String url, {
    dynamic body,
    Map<String, String>? headers,
    Duration timeout = defaultTimeout,
    int maxRetries = defaultMaxRetries,
    Duration retryDelay = defaultRetryDelay,
  }) async {
    return _executeWithRetry(
      () => _makePostRequest(url, body, headers, timeout),
      maxRetries: maxRetries,
      retryDelay: retryDelay,
    );
  }

  /// Makes a PUT request with retry logic.
  ///
  /// [url] - The URL to send the request to
  /// [body] - The request body (will be JSON encoded if it's a Map)
  /// [headers] - Optional headers to include in the request
  /// [timeout] - Request timeout duration
  /// [maxRetries] - Maximum number of retry attempts
  /// [retryDelay] - Delay between retry attempts
  ///
  /// Returns the response body as a string.
  /// Throws [ApiException] if the request fails after all retries.
  static Future<String> put(
    String url, {
    dynamic body,
    Map<String, String>? headers,
    Duration timeout = defaultTimeout,
    int maxRetries = defaultMaxRetries,
    Duration retryDelay = defaultRetryDelay,
  }) async {
    return _executeWithRetry(
      () => _makePutRequest(url, body, headers, timeout),
      maxRetries: maxRetries,
      retryDelay: retryDelay,
    );
  }

  /// Makes a DELETE request with retry logic.
  ///
  /// [url] - The URL to send the request to
  /// [headers] - Optional headers to include in the request
  /// [timeout] - Request timeout duration
  /// [maxRetries] - Maximum number of retry attempts
  /// [retryDelay] - Delay between retry attempts
  ///
  /// Returns the response body as a string.
  /// Throws [ApiException] if the request fails after all retries.
  static Future<String> delete(
    String url, {
    Map<String, String>? headers,
    Duration timeout = defaultTimeout,
    int maxRetries = defaultMaxRetries,
    Duration retryDelay = defaultRetryDelay,
  }) async {
    return _executeWithRetry(
      () => _makeDeleteRequest(url, headers, timeout),
      maxRetries: maxRetries,
      retryDelay: retryDelay,
    );
  }

  /// Parses a JSON response string into a Map.
  ///
  /// [response] - The JSON string to parse
  ///
  /// Returns a Map representation of the JSON.
  /// Throws [FormatException] if the response is not valid JSON.
  static Map<String, dynamic> parseJsonResponse(String response) {
    try {
      final decoded = json.decode(response);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      throw ApiException(
        'Response is not a JSON object, got ${decoded.runtimeType}',
        0,
      );
    } catch (e) {
      throw ApiException('Failed to parse JSON response: $e', 0);
    }
  }

  /// Parses a JSON response string into a List.
  ///
  /// [response] - The JSON string to parse
  ///
  /// Returns a List representation of the JSON array.
  /// Throws [FormatException] if the response is not valid JSON array.
  static List<dynamic> parseJsonArrayResponse(String response) {
    try {
      final decoded = json.decode(response);
      if (decoded is List) {
        return decoded;
      }
      throw ApiException(
        'Response is not a JSON array, got ${decoded.runtimeType}',
        0,
      );
    } catch (e) {
      throw ApiException('Failed to parse JSON array response: $e', 0);
    }
  }

  /// Checks if a status code indicates success (2xx).
  ///
  /// [statusCode] - The HTTP status code to check
  ///
  /// Returns true if the status code is in the 2xx range.
  static bool isSuccessStatusCode(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  /// Checks if a status code indicates a client error (4xx).
  ///
  /// [statusCode] - The HTTP status code to check
  ///
  /// Returns true if the status code is in the 4xx range.
  static bool isClientError(int statusCode) {
    return statusCode >= 400 && statusCode < 500;
  }

  /// Checks if a status code indicates a server error (5xx).
  ///
  /// [statusCode] - The HTTP status code to check
  ///
  /// Returns true if the status code is in the 5xx range.
  static bool isServerError(int statusCode) {
    return statusCode >= 500 && statusCode < 600;
  }

  /// Checks if a status code indicates the request should be retried.
  ///
  /// [statusCode] - The HTTP status code to check
  ///
  /// Returns true if the request should be retried (server errors or timeout-related errors).
  static bool shouldRetry(int statusCode) {
    return isServerError(statusCode) || statusCode == 408 || statusCode == 429;
  }

  /// Encodes a Map to JSON string.
  ///
  /// [data] - The data to encode
  ///
  /// Returns the JSON string representation.
  static String encodeJson(Map<String, dynamic> data) {
    return json.encode(data);
  }

  /// Decodes a JSON string to a dynamic object.
  ///
  /// [jsonString] - The JSON string to decode
  ///
  /// Returns the decoded object.
  /// Throws [FormatException] if the string is not valid JSON.
  static dynamic decodeJson(String jsonString) {
    return json.decode(jsonString);
  }

  /// Builds query parameters string from a Map.
  ///
  /// [params] - The query parameters as a Map
  ///
  /// Returns the query string (e.g., "key1=value1&key2=value2").
  static String buildQueryParams(Map<String, dynamic> params) {
    if (params.isEmpty) return '';

    final queryParts = params.entries.map((entry) {
      final key = Uri.encodeComponent(entry.key);
      final value = Uri.encodeComponent(entry.value.toString());
      return '$key=$value';
    }).toList();

    return queryParts.join('&');
  }

  /// Appends query parameters to a URL.
  ///
  /// [url] - The base URL
  /// [params] - The query parameters to append
  ///
  /// Returns the URL with appended query parameters.
  static String appendQueryParams(String url, Map<String, dynamic> params) {
    if (params.isEmpty) return url;

    final queryString = buildQueryParams(params);
    final separator = url.contains('?') ? '&' : '?';
    return '$url$separator$queryString';
  }

  // Private helper methods

  static Future<String> _makeGetRequest(
    String url,
    Map<String, String>? headers,
    Duration timeout,
  ) async {
    final uri = Uri.parse(url);
    final response = await http.get(uri, headers: headers).timeout(timeout);
    return _handleResponse(response);
  }

  static Future<String> _makePostRequest(
    String url,
    dynamic body,
    Map<String, String>? headers,
    Duration timeout,
  ) async {
    final uri = Uri.parse(url);
    final requestHeaders = _buildHeaders(headers);
    final requestBody = _encodeBody(body);

    final response = await http
        .post(uri, headers: requestHeaders, body: requestBody)
        .timeout(timeout);
    return _handleResponse(response);
  }

  static Future<String> _makePutRequest(
    String url,
    dynamic body,
    Map<String, String>? headers,
    Duration timeout,
  ) async {
    final uri = Uri.parse(url);
    final requestHeaders = _buildHeaders(headers);
    final requestBody = _encodeBody(body);

    final response = await http
        .put(uri, headers: requestHeaders, body: requestBody)
        .timeout(timeout);
    return _handleResponse(response);
  }

  static Future<String> _makeDeleteRequest(
    String url,
    Map<String, String>? headers,
    Duration timeout,
  ) async {
    final uri = Uri.parse(url);
    final response = await http.delete(uri, headers: headers).timeout(timeout);
    return _handleResponse(response);
  }

  static Map<String, String> _buildHeaders(Map<String, String>? headers) {
    final defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (headers != null) {
      return {...defaultHeaders, ...headers};
    }
    return defaultHeaders;
  }

  static String _encodeBody(dynamic body) {
    if (body == null) return '';
    if (body is String) return body;
    if (body is Map) return json.encode(body);
    return body.toString();
  }

  static String _handleResponse(http.Response response) {
    if (isSuccessStatusCode(response.statusCode)) {
      return response.body;
    }

    throw ApiException(
      'HTTP ${response.statusCode}: ${response.reasonPhrase}',
      response.statusCode,
      response.body,
    );
  }

  static Future<String> _executeWithRetry(
    Future<String> Function() request, {
    required int maxRetries,
    required Duration retryDelay,
  }) async {
    int attempts = 0;
    ApiException? lastException;

    while (attempts <= maxRetries) {
      try {
        return await request();
      } on SocketException catch (e) {
        lastException = ApiException('Network error: ${e.message}', 0);
      } on TimeoutException catch (e) {
        lastException = ApiException('Request timeout: ${e.message}', 408);
      } on ApiException catch (e) {
        lastException = e;
        if (!shouldRetry(e.statusCode)) {
          rethrow;
        }
      } catch (e) {
        lastException = ApiException('Unexpected error: $e', 0);
      }

      attempts++;
      if (attempts <= maxRetries) {
        // Use exponential backoff: delay * 2^(attempts-1)
        final backoffMultiplier = attempts == 1 ? 1 : (1 << (attempts - 1));
        await Future.delayed(retryDelay * backoffMultiplier);
      }
    }

    throw lastException ??
        ApiException('Request failed after $maxRetries retries', 0);
  }
}

/// Custom exception class for API-related errors.
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final String? responseBody;

  ApiException(this.message, this.statusCode, [this.responseBody]);

  @override
  String toString() {
    if (responseBody != null) {
      return 'ApiException: $message (Status: $statusCode)\nResponse: $responseBody';
    }
    return 'ApiException: $message (Status: $statusCode)';
  }
}
