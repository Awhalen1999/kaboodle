import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'endpoints.dart';

/// All requests to the API must be authenticated
class ApiClient {
  Future<String?> _getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return await user.getIdToken(true);
  }

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

  Uri _buildUrl(String endpoint) =>
      Uri.parse('${ApiEndpoints.baseUrl}$endpoint');

  // Authenticated requests

  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    return await http.get(_buildUrl(endpoint), headers: headers);
  }

  Future<http.Response> post(String endpoint,
      {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    return await http.post(
      _buildUrl(endpoint),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> patch(String endpoint,
      {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    return await http.patch(
      _buildUrl(endpoint),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    return await http.delete(_buildUrl(endpoint), headers: headers);
  }

  // Public requests (no auth)

  Future<http.Response> getPublic(String endpoint) async {
    return await http.get(_buildUrl(endpoint));
  }
}
