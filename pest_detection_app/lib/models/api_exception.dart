/// Exception class for API-related errors
class ApiException implements Exception {
  final String message;
  final String? code;

  ApiException({required this.message, this.code});

  @override
  String toString() => 'ApiException: $message${code != null ? ' ($code)' : ''}';
}
