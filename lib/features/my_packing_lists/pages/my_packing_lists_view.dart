import 'package:kaboodle_app/features/my_packing_lists/widgets/my_packing_lists_body.dart';
import 'package:flutter/material.dart';
import 'package:kaboodle_app/shared/widgets/custom_app_bar.dart';
import 'package:kaboodle_app/shared/widgets/menu_drawer.dart';

class MyPackingListsView extends StatelessWidget {
  final String? initialTab;

  const MyPackingListsView({super.key, this.initialTab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Packing Lists',
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
      body: MyPackingListsBody(initialTab: initialTab),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('🎒 Start new packing list clicked');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
