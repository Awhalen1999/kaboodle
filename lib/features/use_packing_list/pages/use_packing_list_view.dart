import 'package:flutter/material.dart';
import 'package:kaboodle_app/features/use_packing_list/widgets/use_packing_list_body.dart';
import 'package:kaboodle_app/shared/widgets/custom_app_bar.dart';

class UsePackingListView extends StatelessWidget {
  final String packingListId;
  final String packingListName;

  const UsePackingListView({
    super.key,
    required this.packingListId,
    required this.packingListName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: packingListName,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: UsePackingListBody(
        packingListId: packingListId,
        packingListName: packingListName,
      ),
    );
  }
}
