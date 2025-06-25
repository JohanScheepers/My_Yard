/// Custom exception for API-related errors.
///
/// Includes a [message] and an optional [statusCode] for more detailed error handling.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() {
    return 'ApiException: $message${statusCode != null ? ' (Status Code: $statusCode)' : ''}';
  }
}
