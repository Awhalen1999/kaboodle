import 'package:go_router/go_router.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:kaboodle_app/features/my_packing_lists/pages/my_packing_lists_view.dart';
import 'package:kaboodle_app/services/auth/auth_gate.dart';
import 'package:kaboodle_app/features/auth/pages/welcome_view.dart';
import 'package:kaboodle_app/features/profile/pages/profile_view.dart';
import 'package:kaboodle_app/features/profile_edit/pages/profile_edit_view.dart';
import 'package:kaboodle_app/features/create_packing_list/pages/create_packing_list_view.dart';
import 'package:kaboodle_app/features/use_packing_list/pages/use_packing_list_view.dart';
import 'package:kaboodle_app/features/subscription/pages/paywall_view.dart';
import 'package:kaboodle_app/features/manage_subscription/pages/manage_subscription_view.dart';

// GoRouter configuration
final router = GoRouter(
  initialLocation: '/',
  observers: [PosthogObserver()],
  routes: [
    GoRoute(
      name: 'auth-gate',
      path: '/',
      builder: (context, state) => const AuthGate(),
    ),
    GoRoute(
      name: 'welcome',
      path: '/welcome',
      builder: (context, state) => const WelcomeView(),
    ),
    GoRoute(
      name: 'my-packing-lists',
      path: '/my-packing-lists',
      builder: (context, state) {
        final initialTab = state.uri.queryParameters['tab'];
        return MyPackingListsView(initialTab: initialTab);
      },
    ),
    GoRoute(
      name: 'profile',
      path: '/profile',
      builder: (context, state) => const ProfileView(),
    ),
    GoRoute(
      name: 'profile-edit',
      path: '/profile-edit',
      builder: (context, state) => const ProfileEditView(),
    ),
    GoRoute(
      name: 'create-packing-list',
      path: '/create-packing-list',
      builder: (context, state) {
        final id = state.uri.queryParameters['id'];
        final stepString = state.uri.queryParameters['step'];
        final step = stepString != null ? int.tryParse(stepString) : null;
        return CreatePackingListView(
          packingListId: id,
          initialStep: step,
        );
      },
    ),
    GoRoute(
      name: 'use-packing-list',
      path: '/use-packing-list/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final name = state.uri.queryParameters['name'] ?? 'Packing List';
        return UsePackingListView(
          packingListId: id,
          packingListName: name,
        );
      },
    ),
    GoRoute(
      name: 'paywall',
      path: '/paywall',
      builder: (context, state) => const PaywallView(),
    ),
    GoRoute(
      name: 'manage-subscription',
      path: '/manage-subscription',
      builder: (context, state) => const ManageSubscriptionView(),
    ),
  ],
);
