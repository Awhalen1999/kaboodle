import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'api_client.dart';

class ApiService {
  final ApiClient _client = ApiClient();

  /// Handle API response and errors
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Success
      if (response.body.isEmpty) {
        return {};
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 401) {
      // Unauthorized - token invalid or expired
      throw ApiException(
        'Authentication failed. Please log in again.',
        statusCode: 401,
      );
    } else if (response.statusCode == 403) {
      // Forbidden - user doesn't own this resource
      throw ApiException(
        'You do not have permission to access this resource.',
        statusCode: 403,
      );
    } else if (response.statusCode == 404) {
      // Not found
      throw ApiException(
        'Resource not found.',
        statusCode: 404,
      );
    } else if (response.statusCode >= 500) {
      // Server error
      throw ApiException(
        'Server error. Please try again later.',
        statusCode: response.statusCode,
      );
    } else {
      // Other client errors
      try {
        final error = jsonDecode(response.body);
        throw ApiException(
          error['error'] ?? 'An error occurred',
          statusCode: response.statusCode,
        );
      } catch (e) {
        throw ApiException(
          'An error occurred',
          statusCode: response.statusCode,
        );
      }
    }
  }

  /// Show error toast
  void _showErrorToast(BuildContext context, String message) {
    if (!context.mounted) return;

    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.minimal,
      title: const Text('Error'),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.bottomCenter,
    );
  }

  /// Safe API call with error handling and toast notifications
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
        // Error in onSuccess callback - log it for debugging
        debugPrint('❌ [ApiService] Error in onSuccess callback: $e');
        debugPrint('❌ [ApiService] Response data: $data');
        debugPrint('❌ [ApiService] Stack trace: $stackTrace');
        if (context != null && context.mounted) {
          _showErrorToast(
              context, 'Error processing response: ${e.toString()}');
        }
        return null;
      }
    } on ApiException catch (e) {
      debugPrint('❌ [ApiService] ApiException: ${e.message} (${e.statusCode})');
      if (context != null && context.mounted) {
        _showErrorToast(context, e.message);
      }
      return null;
    } catch (e, stackTrace) {
      debugPrint('❌ [ApiService] Unexpected error: $e');
      debugPrint('❌ [ApiService] Stack trace: $stackTrace');
      if (context != null && context.mounted) {
        _showErrorToast(context, 'An unexpected error occurred');
      }
      return null;
    }
  }

  /// Get the underlying API client for direct access
  ApiClient get client => _client;
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, {required this.statusCode});

  @override
  String toString() => message;
}
