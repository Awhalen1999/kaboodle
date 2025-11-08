class PackingList {
  final String id;
  final String tripId;
  final String userId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  PackingList({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create PackingList from JSON
  factory PackingList.fromJson(Map<String, dynamic> json) {
    return PackingList(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert PackingList to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'userId': userId,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy of PackingList with some fields replaced
  PackingList copyWith({
    String? id,
    String? tripId,
    String? userId,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PackingList(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
