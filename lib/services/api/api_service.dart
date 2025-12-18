import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kaboodle_app/shared/utils/app_toast.dart';
import 'api_client.dart';

/// High-level API service with error handling and toast notifications
class ApiService {
  final ApiClient _client = ApiClient();

  ApiClient get client => _client;

  /// Execute an API call with automatic error handling
  Future<T?> safeApiCall<T>({
    required Future<http.Response> Function() apiCall,
    required T Function(Map<String, dynamic>) onSuccess,
    BuildContext? context,
  }) async {
    try {
      final response = await apiCall();
      final data = _handleResponse(response);

      try {
        return onSuccess(data);
      } catch (e, stackTrace) {
        debugPrint('❌ [ApiService] Error parsing response: $e');
        debugPrint('❌ [ApiService] Response data: $data');
        debugPrint('❌ [ApiService] Stack trace: $stackTrace');
        _showErrorToast(context, 'Error processing response');
        return null;
      }
    } on ApiException catch (e) {
      debugPrint('❌ [ApiService] ${e.statusCode}: ${e.message}');
      _showErrorToast(context, e.message);
      return null;
    } catch (e, stackTrace) {
      debugPrint('❌ [ApiService] Unexpected error: $e');
      debugPrint('❌ [ApiService] Stack trace: $stackTrace');
      _showErrorToast(context, 'An unexpected error occurred');
      return null;
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      return response.body.isEmpty ? {} : jsonDecode(response.body);
    }

    final message = switch (statusCode) {
      401 => 'Authentication failed. Please log in again.',
      403 => 'You do not have permission to access this resource.',
      404 => 'Resource not found.',
      >= 500 => 'Server error. Please try again later.',
      _ => _parseErrorMessage(response.body),
    };

    throw ApiException(message, statusCode: statusCode);
  }

  String _parseErrorMessage(String body) {
    try {
      final error = jsonDecode(body);
      return error['error'] ?? 'An error occurred';
    } catch (_) {
      return 'An error occurred';
    }
  }

  void _showErrorToast(BuildContext? context, String message) {
    if (context == null || !context.mounted) return;
    AppToast.error(context, message);
  }
}

/// Exception thrown when an API request fails
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, {required this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
