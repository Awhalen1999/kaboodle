class Trip {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? destination;
  final DateTime startDate;
  final DateTime endDate;
  final String? colorTag;
  final List<String>? weather;
  final String? gender;
  final String? accommodations;
  final String? purpose;
  final List<String>? activities;
  final int stepCompleted;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Trip({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.destination,
    required this.startDate,
    required this.endDate,
    this.colorTag,
    this.weather,
    this.gender,
    this.accommodations,
    this.purpose,
    this.activities,
    required this.stepCompleted,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create Trip from JSON
  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      destination: json['destination'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      colorTag: json['colorTag'] as String?,
      weather: json['weather'] != null
          ? List<String>.from(json['weather'] as List)
          : null,
      gender: json['gender'] as String?,
      accommodations: json['accommodations'] as String?,
      purpose: json['purpose'] as String?,
      activities: json['activities'] != null
          ? List<String>.from(json['activities'] as List)
          : null,
      stepCompleted: json['stepCompleted'] as int,
      isCompleted: json['isCompleted'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert Trip to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'colorTag': colorTag,
      'weather': weather,
      'gender': gender,
      'accommodations': accommodations,
      'purpose': purpose,
      'activities': activities,
      'stepCompleted': stepCompleted,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy of Trip with some fields replaced
  Trip copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    String? colorTag,
    List<String>? weather,
    String? gender,
    String? accommodations,
    String? purpose,
    List<String>? activities,
    int? stepCompleted,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Trip(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      colorTag: colorTag ?? this.colorTag,
      weather: weather ?? this.weather,
      gender: gender ?? this.gender,
      accommodations: accommodations ?? this.accommodations,
      purpose: purpose ?? this.purpose,
      activities: activities ?? this.activities,
      stepCompleted: stepCompleted ?? this.stepCompleted,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
