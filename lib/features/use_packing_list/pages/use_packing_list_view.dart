import 'package:flutter/material.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:kaboodle_app/features/use_packing_list/widgets/use_packing_list_body.dart';
import 'package:kaboodle_app/shared/widgets/custom_app_bar.dart';
import 'package:kaboodle_app/models/packing_item.dart';

class UsePackingListView extends StatefulWidget {
  final String packingListId;
  final String packingListName;

  const UsePackingListView({
    super.key,
    required this.packingListId,
    required this.packingListName,
  });

  @override
  State<UsePackingListView> createState() => _UsePackingListViewState();
}

class _UsePackingListViewState extends State<UsePackingListView> {
  PackingListStats? _stats;

  void _onStatsUpdated(PackingListStats stats) {
    setState(() {
      _stats = stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.packingListName,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Progress bar
          if (_stats != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: StepProgressIndicator(
                  totalSteps: _stats!.total > 0 ? _stats!.total : 1,
                  currentStep: _stats!.packed,
                  size: 8,
                  padding: 0,
                  selectedGradientColor: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.secondary,
                      Theme.of(context).colorScheme.tertiary,
                    ],
                  ),
                  // todo: use theme color here instead of hardcoded color
                  unselectedColor: Colors.grey[300]!,
                ),
              ),
            ),
          // Content
          Expanded(
            child: UsePackingListBody(
              packingListId: widget.packingListId,
              packingListName: widget.packingListName,
              onStatsUpdated: _onStatsUpdated,
            ),
          ),
        ],
      ),
    );
  }
}
