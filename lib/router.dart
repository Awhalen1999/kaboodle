import 'package:go_router/go_router.dart';
import 'package:kaboodle_app/features/my_packing_lists/pages/my_packing_lists_view.dart';
import 'package:kaboodle_app/services/auth/auth_gate.dart';
import 'package:kaboodle_app/features/auth/pages/welcome_view.dart';
import 'package:kaboodle_app/features/profile/pages/profile_view.dart';
import 'package:kaboodle_app/features/profile_edit/pages/profile_edit_view.dart';
import 'package:kaboodle_app/features/create_packing_list/pages/create_packing_list_view.dart';
import 'package:kaboodle_app/features/use_packing_list/pages/use_packing_list_view.dart';

// GoRouter configuration
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => AuthGate(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => WelcomeView(),
    ),
    GoRoute(
      path: '/my-packing-lists',
      builder: (context, state) {
        final initialTab = state.uri.queryParameters['tab'];
        return MyPackingListsView(initialTab: initialTab);
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => ProfileView(),
    ),
    GoRoute(
      path: '/profile-edit',
      builder: (context, state) => const ProfileEditView(),
    ),
    GoRoute(
      path: '/create-packing-list',
      builder: (context, state) => const CreatePackingListView(),
    ),
    GoRoute(
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
  ],
);
