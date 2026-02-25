import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kaboodle_app/services/api/api_client.dart';
import 'package:kaboodle_app/services/api/endpoints.dart';

/// Response from can-create endpoint
class CanCreateListResult {
  final bool canCreate;
  final int listCount;
  final int maxFreeLists;
  final bool hasSubscription;
  final String? reason;
  final String? message;

  CanCreateListResult({
    required this.canCreate,
    required this.listCount,
    required this.maxFreeLists,
    required this.hasSubscription,
    this.reason,
    this.message,
  });

  factory CanCreateListResult.fromJson(Map<String, dynamic> json) {
    return CanCreateListResult(
      canCreate: json['canCreate'] as bool,
      listCount: json['listCount'] as int,
      maxFreeLists: json['maxFreeLists'] as int,
      hasSubscription: json['hasSubscription'] as bool,
      reason: json['reason'] as String?,
      message: json['message'] as String?,
    );
  }
}

/// Response from subscription status endpoint
/// Uses entitlements as single source of truth from RevenueCat
/// Only owns subscription state — list counts are derived from packingListsProvider
class SubscriptionStatus {
  final List<String> entitlements;
  final bool isPro;
  final DateTime? expiresAt;
  final DateTime? startedAt;
  final DateTime? cancelledAt;

  SubscriptionStatus({
    required this.entitlements,
    required this.isPro,
    this.expiresAt,
    this.startedAt,
    this.cancelledAt,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    final subscription = json['subscription'] as Map<String, dynamic>;

    return SubscriptionStatus(
      entitlements: (subscription['entitlements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isPro: subscription['isPro'] as bool? ?? false,
      expiresAt: subscription['expiresAt'] != null
          ? DateTime.parse(subscription['expiresAt'] as String)
          : null,
      startedAt: subscription['startedAt'] != null
          ? DateTime.parse(subscription['startedAt'] as String)
          : null,
      cancelledAt: subscription['cancelledAt'] != null
          ? DateTime.parse(subscription['cancelledAt'] as String)
          : null,
    );
  }

  /// Check if subscription is cancelled but still active
  bool get isCancelledButActive => isPro && cancelledAt != null;
}

/// Service for subscription-related operations
class SubscriptionService {
  final ApiClient _client = ApiClient();

  /// Check if user can create a new list
  /// Returns result with canCreate flag and relevant info
  Future<CanCreateListResult?> canCreateList() async {
    try {
      final response = await _client.get(ApiEndpoints.canCreateList);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return CanCreateListResult.fromJson(data);
      }

      return null;
    } catch (e) {
      debugPrint('❌ [SubscriptionService] Error checking can create: $e');
      return null;
    }
  }

  /// Get full subscription status for UI display
  Future<SubscriptionStatus?> getSubscriptionStatus() async {
    try {
      final response = await _client.get(ApiEndpoints.subscriptionStatus);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return SubscriptionStatus.fromJson(data);
      }

      return null;
    } catch (e) {
      debugPrint('❌ [SubscriptionService] Error getting status: $e');
      return null;
    }
  }

  /// Check if user has active subscription (via RevenueCat SDK)
  Future<bool> hasActiveSubscription() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.containsKey('Kaboodle Pro');
    } catch (e) {
      debugPrint('❌ [SubscriptionService] Error checking entitlement: $e');
      return false;
    }
  }

  /// Navigate to paywall screen
  void showPaywall(BuildContext context) {
    Posthog().capture(eventName: 'paywall_viewed');
    context.push('/paywall');
  }

  /// Restore previous purchases
  Future<bool> restorePurchases() async {
    try {
      await Purchases.restorePurchases();
      return true;
    } catch (e) {
      debugPrint('❌ [SubscriptionService] Error restoring purchases: $e');
      return false;
    }
  }

  /// Get available packages for purchase
  Future<List<Package>> getPackages() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current?.availablePackages ?? [];
    } catch (e) {
      debugPrint('❌ [SubscriptionService] Error getting packages: $e');
      return [];
    }
  }

  /// Purchase a package
  Future<bool> purchasePackage(Package package) async {
    try {
      await Purchases.purchasePackage(package);

      // Track successful subscription
      Posthog().capture(
        eventName: 'subscription_started',
        properties: {'package': package.identifier},
      );

      return true;
    } catch (e) {
      debugPrint('❌ [SubscriptionService] Purchase failed: $e');
      return false;
    }
  }

  /// Open subscription management page in native store
  /// RevenueCat doesn't provide direct cancellation - users must cancel via App Store/Play Store
  Future<bool> openSubscriptionManagement() async {
    try {
      // Try to get management URL from RevenueCat CustomerInfo
      final customerInfo = await Purchases.getCustomerInfo();
      final managementURL = customerInfo.managementURL;

      Uri url;
      if (managementURL != null && managementURL.isNotEmpty) {
        url = Uri.parse(managementURL);
      } else {
        // Fallback to platform-specific URLs
        if (Platform.isIOS) {
          // iOS App Store subscription management
          url = Uri.parse('https://apps.apple.com/account/subscriptions');
        } else if (Platform.isAndroid) {
          // Android Google Play subscription management
          // This opens the general subscriptions page - users can find their app there
          url =
              Uri.parse('https://play.google.com/store/account/subscriptions');
        } else {
          return false;
        }
      }

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);

        // Track subscription management opened
        Posthog().capture(eventName: 'subscription_management_opened');

        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('❌ [SubscriptionService] Error opening management: $e');
      return false;
    }
  }
}
