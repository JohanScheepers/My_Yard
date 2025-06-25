import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_yard/src/exceptions/api_exception.dart';

/// Defines the HTTP methods supported by the [ApiService].
enum HttpMethod { get, post, put, delete }

/// A service class for making HTTP requests to a REST API.
///
/// This class encapsulates the logic for sending requests, handling common
/// headers, and processing responses, including error handling.
class ApiService {
  /// The base URL for the API service instance.
  final String _baseUrl;

  /// Creates an [ApiService] instance with a specific base URL.
  ///
  /// [baseUrl] is the root URL for all API endpoints this service will call.
  ApiService({required String baseUrl}) : _baseUrl = baseUrl;

  /// Sends an HTTP request using the specified method, endpoint, headers, and body.
  ///
  /// This is a private helper method that handles the core logic of sending
  /// the request and performing initial error checks.
  ///
  /// Throws [ApiException] for network errors or non-2xx HTTP responses.
  Future<http.Response> _sendRequest(
    HttpMethod method,
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final uri = Uri.parse('$_baseUrl/$endpoint');
    http.Response response;

    try {
      switch (method) {
        case HttpMethod.get:
          response = await http.get(uri, headers: headers);
          break;
        case HttpMethod.post:
          response = await http.post(uri, headers: headers, body: body);
          break;
        case HttpMethod.put:
          response = await http.put(uri, headers: headers, body: body);
          break;
        case HttpMethod.delete:
          response = await http.delete(uri, headers: headers);
          break;
      }
    } on http.ClientException catch (e) {
      // Catches network-related errors (e.g., no internet connection, host lookup failure)
      throw ApiException('Network error: ${e.message}');
    } catch (e) {
      // Catches any other unexpected errors during the request execution
      throw ApiException('An unexpected error occurred during the request: $e');
    }

    // Check for successful HTTP status codes (2xx range)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      // Handle HTTP errors (non-2xx status codes)
      String errorMessage =
          'Request failed with status code ${response.statusCode}.';
      try {
        // Attempt to parse a more specific error message from the response body if it's JSON
        final errorData = json.decode(response.body);
        if (errorData is Map && errorData.containsKey('message')) {
          errorMessage = errorData['message'] as String;
        } else if (response.body.isNotEmpty) {
          errorMessage = response
              .body; // Fallback to raw body if not a map but contains text
        }
      } catch (_) {
        // If response body is not valid JSON or empty, the generic message is used
      }
      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }

  /// Sends a GET request to the specified [endpoint].
  /// Returns a decoded JSON map on success. Throws [ApiException] on failure.
  Future<Map<String, dynamic>> get(String endpoint,
      {Map<String, String>? headers}) async {
    final response =
        await _sendRequest(HttpMethod.get, endpoint, headers: headers);
    return response.body.isEmpty
        ? {}
        : json.decode(response.body) as Map<String, dynamic>;
  }

  /// Sends a POST request to the specified [endpoint] with a [body].
  /// [body] should be a JSON-encodable object (e.g., Map).
  /// Returns a decoded JSON map on success. Throws [ApiException] on failure.
  Future<Map<String, dynamic>> post(String endpoint,
      {Map<String, String>? headers, Object? body}) async {
    final defaultHeaders = {'Content-Type': 'application/json'};
    final combinedHeaders = {...defaultHeaders, ...?headers};
    final encodedBody = body != null ? json.encode(body) : null;
    final response = await _sendRequest(HttpMethod.post, endpoint,
        headers: combinedHeaders, body: encodedBody);
    return response.body.isEmpty
        ? {}
        : json.decode(response.body) as Map<String, dynamic>;
  }

  /// Sends a PUT request to the specified [endpoint] with a [body].
  /// [body] should be a JSON-encodable object (e.g., Map).
  /// Returns a decoded JSON map on success. Throws [ApiException] on failure.
  Future<Map<String, dynamic>> put(String endpoint,
      {Map<String, String>? headers, Object? body}) async {
    final defaultHeaders = {'Content-Type': 'application/json'};
    final combinedHeaders = {...defaultHeaders, ...?headers};
    final encodedBody = body != null ? json.encode(body) : null;
    final response = await _sendRequest(HttpMethod.put, endpoint,
        headers: combinedHeaders, body: encodedBody);
    return response.body.isEmpty
        ? {}
        : json.decode(response.body) as Map<String, dynamic>;
  }

  /// Sends a DELETE request to the specified [endpoint].
  /// Throws [ApiException] on failure.
  Future<void> delete(String endpoint, {Map<String, String>? headers}) async {
    await _sendRequest(HttpMethod.delete, endpoint, headers: headers);
  }
}
