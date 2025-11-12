import 'package:flutter/material.dart';
import 'package:kaboodle_app/models/user.dart';
import 'package:kaboodle_app/services/api/api_service.dart';
import 'package:kaboodle_app/services/api/endpoints.dart';

class UserService {
  final ApiService _apiService = ApiService();

  /// Get current user profile
  /// Returns User on success, null on error
  Future<User?> getUserProfile({
    BuildContext? context,
  }) async {
    final result = await _apiService.safeApiCall(
      apiCall: () => _apiService.client.get(ApiEndpoints.userProfile),
      onSuccess: (data) {
        return User.fromJson(data['user']);
      },
      context: context,
    );

    return result;
  }

  /// Update current user profile
  /// Returns updated User on success, null on error
  Future<User?> updateUserProfile({
    String? displayName,
    String? photoUrl,
    String? country,
    BuildContext? context,
  }) async {
    final body = <String, dynamic>{};
    if (displayName != null) body['displayName'] = displayName;
    if (photoUrl != null) body['photoUrl'] = photoUrl;
    if (country != null) body['country'] = country;

    final result = await _apiService.safeApiCall(
      apiCall: () => _apiService.client.patch(
        ApiEndpoints.userProfile,
        body: body,
      ),
      onSuccess: (data) {
        return User.fromJson(data['user']);
      },
      context: context,
    );

    return result;
  }
}
