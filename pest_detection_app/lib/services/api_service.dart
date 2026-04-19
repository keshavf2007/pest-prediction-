import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pest_detection_app/models/prediction_model.dart';
import 'package:pest_detection_app/models/api_exception.dart';

/// API Service for communicating with Flask backend
class ApiService {
  /// IMPORTANT: Replace this with your Flask backend URL
  /// For Android emulator: http://10.0.2.2:5000
  /// For iOS simulator: http://localhost:5000
  /// For physical device: http://<your_machine_ip>:5000
  static const String _baseUrl = 'http://10.0.2.2:5000';

  /// Timeout duration for API requests
  static const Duration _timeout = Duration(seconds: 30);

  /// Health check endpoint to verify backend connectivity
  static Future<bool> healthCheck() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/health'),
          )
          .timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      throw ApiException(
        message: 'Failed to connect to backend: $e',
        code: 'HEALTH_CHECK_FAILED',
      );
    }
  }

  /// Send image to Flask API for pest prediction
  /// 
  /// Parameters:
  ///   - imageFile: File object of the image to analyze
  /// 
  /// Returns:
  ///   - PredictionModel with prediction results
  /// 
  /// Throws:
  ///   - ApiException if the request fails
  static Future<PredictionModel> predictPest(File imageFile) async {
    try {
      // Check if file exists
      if (!await imageFile.exists()) {
        throw ApiException(
          message: 'Image file not found',
          code: 'FILE_NOT_FOUND',
        );
      }

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/predict'),
      );

      // Add image file to request
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );

      // Send request with timeout
      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      // Check response status code
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return PredictionModel.fromJson(jsonResponse);
      } else if (response.statusCode == 400) {
        final errorResponse = jsonDecode(response.body);
        throw ApiException(
          message: errorResponse['message'] ?? 'Invalid request',
          code: 'BAD_REQUEST',
        );
      } else if (response.statusCode == 503) {
        throw ApiException(
          message: 'Backend service unavailable. Please ensure the Flask server is running.',
          code: 'SERVICE_UNAVAILABLE',
        );
      } else {
        throw ApiException(
          message: 'Prediction failed with status code: ${response.statusCode}',
          code: 'PREDICTION_FAILED',
        );
      }
    } on SocketException {
      throw ApiException(
        message: 'No internet connection or backend server not reachable',
        code: 'SOCKET_ERROR',
      );
    } on TimeoutException {
      throw ApiException(
        message: 'Request timeout. Backend server may be slow or unreachable.',
        code: 'TIMEOUT',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Unexpected error: $e',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  /// Get all available pest classes and their solutions
  static Future<Map<String, String>> getClassesAndSolutions() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/classes'),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final classes = jsonResponse['classes'] as Map<String, dynamic>;
        return classes.cast<String, String>();
      } else {
        throw ApiException(
          message: 'Failed to fetch classes',
          code: 'FETCH_CLASSES_FAILED',
        );
      }
    } catch (e) {
      throw ApiException(
        message: 'Error fetching classes: $e',
        code: 'FETCH_CLASSES_ERROR',
      );
    }
  }
}
