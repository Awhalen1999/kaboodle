import 'package:kaboodle_app/features/auth/pages/welcome_view.dart';
import 'package:kaboodle_app/features/profile/pages/profile_view.dart';
import 'package:go_router/go_router.dart';
import 'package:kaboodle_app/services/auth/auth_gate.dart';

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
      path: '/profile',
      builder: (context, state) => ProfileView(),
    ),
  ],
);
