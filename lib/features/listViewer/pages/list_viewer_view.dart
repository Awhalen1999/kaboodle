import 'package:flutter/material.dart';
import 'package:kaboodle/features/listViewer/widgets/list_viewer_body.dart';
import 'package:kaboodle/shared/widgets/custom_app_bar.dart';

class ListViewerView extends StatelessWidget {
  final String listId;
  const ListViewerView({super.key, required this.listId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'View List',
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: SingleChildScrollView(
          child: ListViewerBody(listId: listId),
        ),
      ),
    );
  }
}
