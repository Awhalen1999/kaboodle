import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../api/endpoints.dart';
import '../../models/packing_list.dart';
import '../../models/packing_item.dart';

/// Result from upsert operation
class UpsertResult {
  final PackingList? packingList;
  final bool subscriptionRequired;
  final String? message;

  UpsertResult({
    this.packingList,
    this.subscriptionRequired = false,
    this.message,
  });

  bool get success => packingList != null;
}

/// Service for packing list and item operations
class TripService {
  final ApiService _apiService = ApiService();

  // Packing Lists

  /// Upsert a packing list (create if no ID, update if ID provided)
  /// Returns UpsertResult with subscriptionRequired flag if user hits limit
  Future<UpsertResult> upsertPackingList({
    String? id,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    String? description,
    String? destination,
    String? colorTag,
    String? gender,
    List<String>? weather,
    String? purpose,
    String? accommodations,
    List<String>? activities,
    int? stepCompleted,
    bool? isCompleted,
    BuildContext? context,
  }) async {
    final body = {
      if (id != null) 'id': id,
      'name': name,
      'startDate': startDate.toIso8601String().split('T')[0],
      'endDate': endDate.toIso8601String().split('T')[0],
      if (description != null) 'description': description,
      if (destination != null) 'destination': destination,
      if (colorTag != null) 'colorTag': colorTag,
      if (gender != null) 'gender': gender,
      if (weather != null && weather.isNotEmpty) 'weather': weather,
      if (purpose != null) 'purpose': purpose,
      if (accommodations != null) 'accommodations': accommodations,
      if (activities != null && activities.isNotEmpty) 'activities': activities,
      if (stepCompleted != null) 'stepCompleted': stepCompleted,
      if (isCompleted != null) 'isCompleted': isCompleted,
    };

    try {
      final response =
          await _apiService.client.post(ApiEndpoints.packingLists, body: body);

      // Check for subscription required (403)
      if (response.statusCode == 403) {
        final data = jsonDecode(response.body);
        if (data['error'] == 'subscription_required') {
          return UpsertResult(
            subscriptionRequired: true,
            message: data['message'] as String?,
          );
        }
      }

      // Handle success
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return UpsertResult(
          packingList: PackingList.fromJson(data['packingList']),
        );
      }

      // Handle other errors
      debugPrint('❌ [TripService] Upsert failed: ${response.statusCode}');
      return UpsertResult();
    } catch (e) {
      debugPrint('❌ [TripService] Upsert error: $e');
      return UpsertResult();
    }
  }

  /// Get all packing lists for the current user
  Future<Map<String, dynamic>?> getPackingLists({BuildContext? context}) async {
    return await _apiService.safeApiCall(
      apiCall: () => _apiService.client.get(ApiEndpoints.packingLists),
      onSuccess: (data) {
        final packingLists = (data['packingLists'] as List)
            .map((json) => PackingList.fromJson(json))
            .toList();
        return {'packingLists': packingLists, 'count': packingLists.length};
      },
      context: context,
    );
  }

  /// Get a single packing list by ID
  Future<PackingList?> getPackingList({
    required String packingListId,
    BuildContext? context,
  }) async {
    return await _apiService.safeApiCall(
      apiCall: () =>
          _apiService.client.get(ApiEndpoints.packingList(packingListId)),
      onSuccess: (data) => PackingList.fromJson(data['packingList']),
      context: context,
    );
  }

  /// Delete a packing list
  Future<bool> deletePackingList({
    required String packingListId,
    BuildContext? context,
  }) async {
    final result = await _apiService.safeApiCall(
      apiCall: () =>
          _apiService.client.delete(ApiEndpoints.packingList(packingListId)),
      onSuccess: (data) => data['success'] as bool,
      context: context,
    );
    return result ?? false;
  }

  /// Generate packing suggestions based on packing list parameters
  Future<List<dynamic>?> generateSuggestions({
    required String packingListId,
    BuildContext? context,
  }) async {
    return await _apiService.safeApiCall(
      apiCall: () => _apiService.client
          .post(ApiEndpoints.generateSuggestions(packingListId)),
      onSuccess: (data) => data['suggestions'] as List,
      context: context,
    );
  }

  /// Reuse packing list (reset all items to unpacked)
  Future<Map<String, dynamic>?> reusePackingList({
    required String packingListId,
    BuildContext? context,
  }) async {
    return await _apiService.safeApiCall(
      apiCall: () =>
          _apiService.client.post(ApiEndpoints.packingListReuse(packingListId)),
      onSuccess: (data) => {
        'success': data['success'] as bool,
        'itemsReset': data['itemsReset'] as int,
      },
      context: context,
    );
  }

  // Packing List Items

  /// Get all items in a packing list
  Future<Map<String, dynamic>?> getPackingListItems({
    required String packingListId,
    BuildContext? context,
  }) async {
    return await _apiService.safeApiCall(
      apiCall: () =>
          _apiService.client.get(ApiEndpoints.packingListItems(packingListId)),
      onSuccess: (data) {
        final items = (data['items'] as List)
            .map((json) => PackingItem.fromJson(json))
            .toList();
        return {
          'items': items,
          'stats': PackingListStats.fromJson(data['stats']),
        };
      },
      context: context,
    );
  }

  /// Add a custom item to packing list
  Future<PackingItem?> addCustomItem({
    required String packingListId,
    required String name,
    String? category,
    int quantity = 1,
    String? notes,
    BuildContext? context,
  }) async {
    return await _apiService.safeApiCall(
      apiCall: () => _apiService.client.post(
        ApiEndpoints.packingListItems(packingListId),
        body: {
          'name': name,
          if (category != null) 'category': category,
          'quantity': quantity,
          if (notes != null) 'notes': notes,
        },
      ),
      onSuccess: (data) => PackingItem.fromJson(data['item']),
      context: context,
    );
  }

  /// Bulk add items from templates
  Future<Map<String, dynamic>?> bulkAddItems({
    required String packingListId,
    required List<String> itemTemplateIds,
    BuildContext? context,
  }) async {
    return await _apiService.safeApiCall(
      apiCall: () => _apiService.client.post(
        ApiEndpoints.packingListItemsBulk(packingListId),
        body: {'itemTemplateIds': itemTemplateIds},
      ),
      onSuccess: (data) {
        final items = (data['added'] as List)
            .map((json) => PackingItem.fromJson(json))
            .toList();
        return {'added': items, 'count': data['count'] as int};
      },
      context: context,
    );
  }

  // Items

  /// Update an item
  Future<PackingItem?> updateItem({
    required String itemId,
    String? name,
    String? category,
    int? quantity,
    String? notes,
    bool? isPacked,
    BuildContext? context,
  }) async {
    return await _apiService.safeApiCall(
      apiCall: () => _apiService.client.patch(
        ApiEndpoints.item(itemId),
        body: {
          if (name != null) 'name': name,
          if (category != null) 'category': category,
          if (quantity != null) 'quantity': quantity,
          if (notes != null) 'notes': notes,
          if (isPacked != null) 'isPacked': isPacked,
        },
      ),
      onSuccess: (data) => PackingItem.fromJson(data['item']),
      context: context,
    );
  }

  /// Bulk update items (e.g., toggle isPacked for multiple items)
  Future<Map<String, dynamic>?> bulkUpdateItems({
    required String packingListId,
    required List<Map<String, dynamic>> updates,
    BuildContext? context,
  }) async {
    return await _apiService.safeApiCall(
      apiCall: () => _apiService.client.patch(
        ApiEndpoints.packingListItemsBulkUpdate(packingListId),
        body: {'updates': updates},
      ),
      onSuccess: (data) {
        // Handle expected format
        if (data.containsKey('updated') && data.containsKey('count')) {
          final items = (data['updated'] as List)
              .map((json) => PackingItem.fromJson(json))
              .toList();
          return {'updated': items, 'count': data['count'] as int};
        }

        // Handle alternative format
        if (data.containsKey('items')) {
          final items = (data['items'] as List)
              .map((json) => PackingItem.fromJson(json))
              .toList();
          return {'updated': items, 'count': items.length};
        }

        // Fallback
        return {'updated': <PackingItem>[], 'count': updates.length};
      },
      context: context,
    );
  }

  // Utility

  /// Get available categories
  Future<List<String>?> getCategories({BuildContext? context}) async {
    return await _apiService.safeApiCall(
      apiCall: () => _apiService.client.get(ApiEndpoints.categories),
      onSuccess: (data) => List<String>.from(data['categories'] as List),
      context: context,
    );
  }

  /// Get available tags
  Future<Map<String, List<String>>?> getTags({BuildContext? context}) async {
    return await _apiService.safeApiCall(
      apiCall: () => _apiService.client.get(ApiEndpoints.tags),
      onSuccess: (data) => {
        'weather': List<String>.from(data['weather'] as List),
        'activities': List<String>.from(data['activities'] as List),
        'purposes': List<String>.from(data['purposes'] as List),
        'accommodations': List<String>.from(data['accommodations'] as List),
        'genders': List<String>.from(data['genders'] as List),
      },
      context: context,
    );
  }

  /// Health check (no auth required)
  Future<bool> healthCheck() async {
    try {
      final response = await _apiService.client.getPublic(ApiEndpoints.health);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
