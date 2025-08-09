import 'package:flutter/material.dart';
import 'package:kaboodle/features/editPackingList/widgets/edit_packing_list_body.dart';
import 'package:kaboodle/shared/widgets/custom_app_bar.dart';

class EditPackingListView extends StatelessWidget {
  final String listId;
  const EditPackingListView({super.key, required this.listId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Edit packing list',
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: SingleChildScrollView(
          child: EditPackingListBody(listId: listId),
        ),
      ),
    );
  }
}
