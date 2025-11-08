class PackingItem {
  final String id;
  final String packingListId;
  final String name;
  final String? category;
  final int quantity;
  final String? notes;
  final bool isPacked;
  final bool isCustom;
  final int orderIndex;
  final DateTime createdAt;
  final DateTime updatedAt;

  PackingItem({
    required this.id,
    required this.packingListId,
    required this.name,
    this.category,
    required this.quantity,
    this.notes,
    required this.isPacked,
    required this.isCustom,
    required this.orderIndex,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create PackingItem from JSON
  factory PackingItem.fromJson(Map<String, dynamic> json) {
    return PackingItem(
      id: json['id'] as String,
      packingListId: json['packingListId'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
      quantity: json['quantity'] as int,
      notes: json['notes'] as String?,
      isPacked: json['isPacked'] as bool,
      isCustom: json['isCustom'] as bool,
      orderIndex: json['orderIndex'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert PackingItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'packingListId': packingListId,
      'name': name,
      'category': category,
      'quantity': quantity,
      'notes': notes,
      'isPacked': isPacked,
      'isCustom': isCustom,
      'orderIndex': orderIndex,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy of PackingItem with some fields replaced
  PackingItem copyWith({
    String? id,
    String? packingListId,
    String? name,
    String? category,
    int? quantity,
    String? notes,
    bool? isPacked,
    bool? isCustom,
    int? orderIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PackingItem(
      id: id ?? this.id,
      packingListId: packingListId ?? this.packingListId,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      isPacked: isPacked ?? this.isPacked,
      isCustom: isCustom ?? this.isCustom,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Stats for a packing list
class PackingListStats {
  final int total;
  final int packed;
  final int remaining;

  PackingListStats({
    required this.total,
    required this.packed,
    required this.remaining,
  });

  factory PackingListStats.fromJson(Map<String, dynamic> json) {
    return PackingListStats(
      total: json['total'] as int,
      packed: json['packed'] as int,
      remaining: json['remaining'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'packed': packed,
      'remaining': remaining,
    };
  }
}
