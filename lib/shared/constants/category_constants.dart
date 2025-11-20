/// Constants for packing list categories
class CategoryConstants {
  CategoryConstants._(); // Private constructor to prevent instantiation

  /// Standard category order by importance
  /// Categories not in this list will be sorted alphabetically after these
  static const List<String> order = [
    'Clothing',
    'Toiletries',
    'Electronics',
    'Medication',
    'Documents',
    'Accessories',
    'Entertainment',
    'Food & Snacks',
    'Outdoor Gear',
    'Baby & Kids',
    'Pet Supplies',
    'Miscellaneous',
  ];

  /// Sorts categories by the defined order, then alphabetically
  /// Case-insensitive comparison
  static List<String> sortCategories(List<String> categories) {
    return categories.toList()
      ..sort((a, b) {
        final indexA = order.indexWhere(
          (cat) => cat.toLowerCase() == a.toLowerCase(),
        );
        final indexB = order.indexWhere(
          (cat) => cat.toLowerCase() == b.toLowerCase(),
        );

        // If both categories are in the order list, sort by index
        if (indexA != -1 && indexB != -1) {
          return indexA.compareTo(indexB);
        }
        // If only A is in the list, A comes first
        if (indexA != -1) return -1;
        // If only B is in the list, B comes first
        if (indexB != -1) return 1;
        // If neither is in the list, sort alphabetically
        return a.compareTo(b);
      });
  }
}
