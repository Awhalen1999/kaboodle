import 'package:flutter/material.dart';
import 'package:kaboodle/features/createPackingList/provider/create_packing_list_provider.dart';
import 'package:kaboodle/features/createPackingList/widgets/step_one_content.dart';
import 'package:provider/provider.dart';

class MainStepOneBody extends StatelessWidget {
  const MainStepOneBody({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CreatePackingListProvider>();
    return StepOneContent(
      title: provider.title,
      description: provider.description,
      listColor: provider.listColor,
      travelDate: provider.travelDate,
      onTitleChanged: provider.updateTitle,
      onDescriptionChanged: provider.updateDescription,
      onColorChanged: provider.updateListColor,
      onDateChanged: provider.updateTravelDate,
    );
  }
}
