import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../api/endpoints.dart';
import '../../models/trip.dart';
import '../../models/packing_list.dart';
import '../../models/packing_item.dart';

class TripService {
  final ApiService _apiService = ApiService();

  /// Upsert a trip (create if no ID, update if ID provided)
  /// Returns Trip and PackingList on success, null on error
  Future<Map<String, dynamic>?> upsertTrip({
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
    BuildContext? context,
  }) async {
    final requestBody = {
      if (id != null) 'id': id,
      'name': name,
      'startDate': startDate.toIso8601String().split('T')[0], // YYYY-MM-DD
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
    };

    print('🚀 [TripService.upsertTrip] Request body: $requestBody');

    try {
      final result = await _apiService.safeApiCall(
        apiCall: () => _apiService.client.post(
          ApiEndpoints.trips,
          body: requestBody,
        ),
        onSuccess: (data) {
          print('✅ [TripService.upsertTrip] Success response: $data');
          return {
            'trip': Trip.fromJson(data['trip']),
            if (data['packingList'] != null)
              'packingList': PackingList.fromJson(data['packingList']),
          };
        },
        context: context,
      );
      print('🎯 [TripService.upsertTrip] Final result: ${result != null}');
      return result;
    } catch (e, stackTrace) {
      print('❌ [TripService.upsertTrip] Exception caught: $e');
      print('❌ [TripService.upsertTrip] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Create a new trip
  /// Returns Trip and PackingList on success, null on error
  @Deprecated('Use upsertTrip() instead')
  Future<Map<String, dynamic>?> createTrip({
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    String? description,
    String? destination,
    String? colorTag,
    BuildContext? context,
  }) async {
    return await _apiService.safeApiCall(
      apiCall: () => _apiService.client.post(
        ApiEndpoints.trips,
        body: {
          'name': name,
          'startDate': startDate.toIso8601String().split('T')[0], // YYYY-MM-DD
          'endDate': endDate.toIso8601String().split('T')[0],
          if (description != null) 'description': description,
          if (destination != null) 'destination': destination,
          if (colorTag != null) 'colorTag': colorTag,
        },
      ),
      onSuccess: (data) {
        return {
          'trip': Trip.fromJson(data['trip']),
          'packingList': PackingList.fromJson(data['packingList']),
        };
      },
      context: context,
    );
  }

  /// Get all trips for the current user
  Future<Map<String, dynamic>?> getTrips({
    String status = 'all', // 'all', 'upcoming', 'past'
    int limit = 50,
    int offset = 0,
    BuildContext? context,
  }) async {
    final queryParams = '?status=$status&limit=$limit&offset=$offset';

    return await _apiService.safeApiCall(
      apiCall: () => _apiService.client.get('${ApiEndpoints.trips}$queryParams'),
      onSuccess: (data) {
        final tripsList = (data['trips'] as List)
            .map((json) => Trip.fromJson(json))
            .toList();

        return {
          'trips': tripsList,
          'total': data['total'] as int,
        };
      },
      context: context,
    );
  }

  /// Get a single trip by ID
  Future<Map<String, dynamic>?> getTrip({
    required String tripId,
    BuildContext? context,
  }) async {
    return await _apiService.safeApiCall(
      apiCall: () => _apiService.client.get(ApiEndpoints.trip(tripId)),
      onSuccess: (data) {
        return {
          'trip': Trip.fromJson(data['trip']),
          'packingList': PackingList.fromJson(data['packingList']),
        };
      },
      context: context,
    );
  }

  /// Update a trip (multi-step process)
  Future<Trip?> updateTrip({
    required String tripId,
    required Map<String, dynamic> data,
    BuildContext? context,
  }) async {
    return await _apiService.safeApiCall(
      apiCall: () => _apiService.client.patch(
        ApiEndpoints.trip(tripId),
        body: data,
      ),
      onSuccess: (responseData) => Trip.fromJson(responseData['trip']),
      context: context,
    );
  }

  /// Delete a trip
  Future<bool> deleteTrip({
    required String tripId,
    BuildContext? context,
  }) async {
    final result = await _apiService.safeApiCall(
      apiCall: () => _apiService.client.delete(ApiEndpoints.trip(tripId)),
      onSuccess: (data) => data['success'] as bool,
      context: context,
    );

    return result ?? false;
  }

  /// Generate packing suggestions based on trip parameters
  Future<List<dynamic>?> generateSuggestions({
    required String tripId,
    BuildContext? context,
  }) async {
    return await _apiService.safeApiCall(
      apiCall: () => _apiService.client.post(
        ApiEndpoints.generateSuggestions(tripId),
      ),
      onSuccess: (data) => data['suggestions'] as List,
      context: context,
    );
  }

  /// Get packing lists for a trip
  Future<List<PackingList>?> getPackingLists({
    required String tripId,
    BuildContext? context,
  }) async {
    return await _apiService.safeApiCall(
      apiCall: () =>
          _apiService.client.get(ApiEndpoints.tripPackingLists(tripId)),
      onSuccess: (data) {
        return (data['packingLists'] as List)
            .map((json) => PackingList.fromJson(json))
            .toList();
      },
      context: context,
    );
  }

  /// Update packing list name
  Future<PackingList?> updatePackingList({
    required String packingListId,
    required String name,
    BuildContext? context,
  }) async {
    return await _apiService.safeApiCall(
      apiCall: () => _apiService.client.patch(
        ApiEndpoints.packingList(packingListId),
        body: {'name': name},
      ),
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

  /// Clear packing list (delete all items)
  Future<Map<String, dynamic>?> clearPackingList({
    required String packingListId,
    BuildContext? context,
  }) async {
    return await _apiService.safeApiCall(
      apiCall: () =>
          _apiService.client.post(ApiEndpoints.packingListClear(packingListId)),
      onSuccess: (data) => {
        'success': data['success'] as bool,
        'itemsDeleted': data['itemsDeleted'] as int,
      },
      context: context,
    );
  }

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

        return {
          'added': items,
          'count': data['count'] as int,
        };
      },
      context: context,
    );
  }

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

  /// Delete an item
  Future<bool> deleteItem({
    required String itemId,
    BuildContext? context,
  }) async {
    final result = await _apiService.safeApiCall(
      apiCall: () => _apiService.client.delete(ApiEndpoints.item(itemId)),
      onSuccess: (data) => data['success'] as bool,
      context: context,
    );

    return result ?? false;
  }

  /// Get available categories
  Future<List<String>?> getCategories({
    BuildContext? context,
  }) async {
    return await _apiService.safeApiCall(
      apiCall: () => _apiService.client.get(ApiEndpoints.categories),
      onSuccess: (data) => List<String>.from(data['categories'] as List),
      context: context,
    );
  }

  /// Get available tags
  Future<Map<String, List<String>>?> getTags({
    BuildContext? context,
  }) async {
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
    } catch (e) {
      return false;
    }
  }
}
