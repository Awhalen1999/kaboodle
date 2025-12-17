class User {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? country;
  // Subscription fields - using entitlements as source of truth
  final List<String> entitlements;
  final bool isPro;
  final DateTime? subscriptionExpiresAt;
  final DateTime? subscriptionStartedAt;
  final DateTime? subscriptionCancelledAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.country,
    this.entitlements = const [],
    this.isPro = false,
    this.subscriptionExpiresAt,
    this.subscriptionStartedAt,
    this.subscriptionCancelledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if user has an active pro subscription
  bool get hasActiveSubscription => isPro;

  /// Check if subscription is cancelled but still active
  bool get isCancelledButActive => isPro && subscriptionCancelledAt != null;

  /// Create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      country: json['country'] as String?,
      entitlements: (json['entitlements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isPro: json['isPro'] as bool? ?? false,
      subscriptionExpiresAt: json['subscriptionExpiresAt'] != null
          ? DateTime.parse(json['subscriptionExpiresAt'] as String)
          : null,
      subscriptionStartedAt: json['subscriptionStartedAt'] != null
          ? DateTime.parse(json['subscriptionStartedAt'] as String)
          : null,
      subscriptionCancelledAt: json['subscriptionCancelledAt'] != null
          ? DateTime.parse(json['subscriptionCancelledAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'country': country,
      'entitlements': entitlements,
      'isPro': isPro,
      'subscriptionExpiresAt': subscriptionExpiresAt?.toIso8601String(),
      'subscriptionStartedAt': subscriptionStartedAt?.toIso8601String(),
      'subscriptionCancelledAt': subscriptionCancelledAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy of User with some fields replaced
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? country,
    List<String>? entitlements,
    bool? isPro,
    DateTime? subscriptionExpiresAt,
    DateTime? subscriptionStartedAt,
    DateTime? subscriptionCancelledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      country: country ?? this.country,
      entitlements: entitlements ?? this.entitlements,
      isPro: isPro ?? this.isPro,
      subscriptionExpiresAt:
          subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      subscriptionStartedAt:
          subscriptionStartedAt ?? this.subscriptionStartedAt,
      subscriptionCancelledAt:
          subscriptionCancelledAt ?? this.subscriptionCancelledAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
