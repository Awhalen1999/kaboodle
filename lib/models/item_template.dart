class ItemTemplate {
  final String id;
  final String name;
  final String category;
  final String icon;
  final List<String>? weatherTags;
  final List<String>? genderTags;
  final List<String>? accommodationTags;
  final List<String>? purposeTags;
  final List<String>? activityTags;
  final int defaultQuantity;
  final bool allowQuantityMultiplier;
  final int quantity;
  final int priority;
  final DateTime createdAt;
  final DateTime updatedAt;

  ItemTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    this.weatherTags,
    this.genderTags,
    this.accommodationTags,
    this.purposeTags,
    this.activityTags,
    required this.defaultQuantity,
    required this.allowQuantityMultiplier,
    required this.quantity,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create ItemTemplate from JSON
  factory ItemTemplate.fromJson(Map<String, dynamic> json) {
    return ItemTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      icon: json['icon'] as String,
      weatherTags: json['weatherTags'] != null
          ? List<String>.from(json['weatherTags'] as List)
          : null,
      genderTags: json['genderTags'] != null
          ? List<String>.from(json['genderTags'] as List)
          : null,
      accommodationTags: json['accommodationTags'] != null
          ? List<String>.from(json['accommodationTags'] as List)
          : null,
      purposeTags: json['purposeTags'] != null
          ? List<String>.from(json['purposeTags'] as List)
          : null,
      activityTags: json['activityTags'] != null
          ? List<String>.from(json['activityTags'] as List)
          : null,
      defaultQuantity: json['defaultQuantity'] as int,
      allowQuantityMultiplier: json['allowQuantityMultiplier'] as bool,
      quantity: json['quantity'] as int,
      priority: json['priority'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert ItemTemplate to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'icon': icon,
      'weatherTags': weatherTags,
      'genderTags': genderTags,
      'accommodationTags': accommodationTags,
      'purposeTags': purposeTags,
      'activityTags': activityTags,
      'defaultQuantity': defaultQuantity,
      'allowQuantityMultiplier': allowQuantityMultiplier,
      'quantity': quantity,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
