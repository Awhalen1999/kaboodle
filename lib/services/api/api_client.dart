import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'endpoints.dart';

class ApiClient {
  /// Get a fresh Firebase ID token for the current user
  Future<String?> _getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    // Force refresh to ensure token is valid (Firebase SDK caches if not expired)
    return await user.getIdToken(true);
  }

  /// Build headers with Firebase auth token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getIdToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// GET request
  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    final url = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');
    return await http.get(url, headers: headers);
  }

  /// POST request
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final headers = await _getHeaders();
    final url = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');
    return await http.post(
      url,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  /// PATCH request
  Future<http.Response> patch(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final headers = await _getHeaders();
    final url = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');
    return await http.patch(
      url,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  /// DELETE request
  Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    final url = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');
    return await http.delete(url, headers: headers);
  }

  /// GET request without authentication (for health check)
  Future<http.Response> getPublic(String endpoint) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');
    return await http.get(url);
  }
}
