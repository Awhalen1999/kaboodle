import 'package:kaboodle_app/features/profile/widgets/profile_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaboodle_app/providers/user_provider.dart';
import 'package:kaboodle_app/shared/widgets/custom_app_bar.dart';
import 'package:kaboodle_app/shared/widgets/menu_drawer.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch provider - AsyncNotifier automatically loads data when first accessed
    print('👀 [ProfileView] Watching user provider');
    ref.watch(userProvider);

    return CupertinoScaffold(
      body: Scaffold(
        appBar: CustomAppBar(
          title: 'Profile',
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
        ),
        drawer: const MenuDrawer(),
        body: const ProfileBody(),
      ),
    );
  }
}
