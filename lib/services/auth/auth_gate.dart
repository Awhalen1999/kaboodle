import 'package:kaboodle_app/features/auth/pages/welcome_view.dart';
import 'package:kaboodle_app/features/my_packing_lists/pages/my_packing_lists_view.dart';
import 'package:kaboodle_app/providers/subscription_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  /// Listener function reference for cleanup
  void Function(CustomerInfo)? _customerInfoListener;

  @override
  void initState() {
    super.initState();
    _setupRevenueCatListener();
  }

  @override
  void dispose() {
    _removeRevenueCatListener();
    super.dispose();
  }

  /// Set up RevenueCat listener to refresh subscription on entitlement changes
  void _setupRevenueCatListener() {
    _customerInfoListener = (CustomerInfo customerInfo) {
      // Refresh subscription provider when entitlements change
      // This fires instantly on purchase - no webhook wait needed
      ref.read(subscriptionProvider.notifier).refresh();
    };
    Purchases.addCustomerInfoUpdateListener(_customerInfoListener!);
  }

  /// Remove RevenueCat listener on dispose
  void _removeRevenueCatListener() {
    if (_customerInfoListener != null) {
      Purchases.removeCustomerInfoUpdateListener(_customerInfoListener!);
      _customerInfoListener = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const MyPackingListsView();
          } else {
            return const WelcomeView();
          }
        },
      ),
    );
  }
}
