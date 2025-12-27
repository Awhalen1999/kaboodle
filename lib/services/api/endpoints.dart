class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - TODO: Update to production URL when deployed
  // static const String baseUrl = 'http://localhost:9000';
  static const String baseUrl = 'https://kaboodle-api.vercel.app';

  // Health
  static const String health = '/api/health';

  // Packing Lists
  static const String packingLists = '/api/packing-lists';
  static String packingList(String id) => '/api/packing-lists/$id';
  static String generateSuggestions(String id) =>
      '/api/packing-lists/$id/generate-suggestions';
  static String packingListReuse(String id) => '/api/packing-lists/$id/reuse';
  static String packingListClear(String id) => '/api/packing-lists/$id/clear';

  // Packing List Items
  static String packingListItems(String listId) =>
      '/api/packing-lists/$listId/items';
  static String packingListItemsBulk(String listId) =>
      '/api/packing-lists/$listId/items/bulk';
  static String packingListItemsBulkUpdate(String listId) =>
      '/api/packing-lists/$listId/items/bulk-update';

  // Items
  static String item(String id) => '/api/items/$id';

  // User
  static const String userProfile = '/api/user-profile';
  static const String deleteAccount = '/api/user-profile';

  // Subscription
  static const String canCreateList = '/api/packing-lists/can-create';
  static const String subscriptionStatus = '/api/subscription/status';

  // Utility
  static const String categories = '/api/categories';
  static const String tags = '/api/tags';
}
