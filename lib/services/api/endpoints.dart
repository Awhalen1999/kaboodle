class ApiEndpoints {
  // Base URL - TODO: Update when backend is deployed
  // static const String baseUrl = 'https://kaboodle-api.vercel.app';

  // For local development, use:
  static const String baseUrl = 'http://localhost:9000';

  // Health
  static const String health = '/api/health';

  // Packing Lists
  static const String packingLists = '/api/packing-lists';
  static String packingList(String id) => '/api/packing-lists/$id';
  static String generateSuggestions(String packingListId) => '/api/packing-lists/$packingListId/generate-suggestions';
  static String packingListItems(String id) => '/api/packing-lists/$id/items';
  static String packingListItemsBulk(String id) => '/api/packing-lists/$id/items/bulk';
  static String packingListReuse(String id) => '/api/packing-lists/$id/reuse';
  static String packingListClear(String id) => '/api/packing-lists/$id/clear';

  // Items
  static String item(String id) => '/api/items/$id';

  // User Profile
  static const String userProfile = '/api/user-profile';

  // Utility
  static const String categories = '/api/categories';
  static const String tags = '/api/tags';
}
