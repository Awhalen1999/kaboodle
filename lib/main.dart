import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'package:kaboodle_app/router.dart';
import 'package:kaboodle_app/theme/light_mode.dart';
import 'package:kaboodle_app/theme/dark_mode.dart';
import 'package:kaboodle_app/services/theme/theme_service.dart';
import 'package:kaboodle_app/providers/theme_provider.dart';
import 'package:kaboodle_app/services/subscription/revenue_cat/initalize.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();
  await ThemeService.init();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize RevenueCat
  await initializeRevenueCat();

  // Identify RevenueCat user if already logged in
  final firebaseUser = FirebaseAuth.instance.currentUser;
  if (firebaseUser != null) {
    try {
      await Purchases.logIn(firebaseUser.uid);
    } catch (e) {
      debugPrint('⚠️ [main] Failed to identify RevenueCat user: $e');
      // Don't throw - this shouldn't block app startup
    }
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use select to only rebuild when themeMode changes, not on every theme state change
    final themeMode =
        ref.watch(themeProvider.select((state) => state.themeMode));

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      darkTheme: darkMode,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
