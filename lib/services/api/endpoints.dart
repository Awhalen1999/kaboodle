class ApiEndpoints {
  // Base URL - TODO: Update when backend is deployed
  // static const String baseUrl = 'https://kaboodle-api.vercel.app';

  // For local development, use:
  static const String baseUrl = 'http://localhost:9000';

  // Health
  static const String health = '/api/health';

  // Trips
  static const String trips = '/api/trips';
  static String trip(String id) => '/api/trips/$id';
  static String generateSuggestions(String tripId) => '/api/trips/$tripId/generate-suggestions';
  static String tripPackingLists(String tripId) => '/api/trips/$tripId/packing-lists';

  // Packing Lists
  static String packingList(String id) => '/api/packing-lists/$id';
  static String packingListItems(String id) => '/api/packing-lists/$id/items';
  static String packingListItemsBulk(String id) => '/api/packing-lists/$id/items/bulk';
  static String packingListReuse(String id) => '/api/packing-lists/$id/reuse';
  static String packingListClear(String id) => '/api/packing-lists/$id/clear';

  // Items
  static String item(String id) => '/api/items/$id';

  // Utility
  static const String categories = '/api/categories';
  static const String tags = '/api/tags';
}
