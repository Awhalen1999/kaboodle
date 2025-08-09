import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kaboodle/services/data/packing_list_cache.dart';
import 'package:kaboodle/services/data/firestore.dart';
import 'package:kaboodle/core/constants/app_icons.dart';
import 'package:kaboodle/core/constants/app_constants.dart';
import 'package:kaboodle/core/utils/date_formatter.dart';
import 'package:kaboodle/shared/widgets/custom_item_chip.dart';
import 'package:go_router/go_router.dart';

class ListViewerBody extends StatelessWidget {
  final String listId;
  const ListViewerBody({super.key, required this.listId});

  @override
  Widget build(BuildContext context) {
    return Consumer<PackingListCache>(
      builder: (context, cache, child) {
        if (cache.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (cache.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 64, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 16),
                Text('Error loading packing list',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  cache.error!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final listData = cache.getListById(listId);
        if (listData == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text('Packing list not found',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'The packing list you\'re looking for doesn\'t exist or has been deleted.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Extract data from the list
        final title = listData['title'] ?? 'Untitled';
        final description = listData['description'] ?? '';
        final date = DateFormatter.formatDate(listData['travelDate']);
        final purpose = listData['tripPurpose'] ?? 'NA';
        final weather = listData['weatherCondition'] ?? 'NA';
        final tripLength =
            DateFormatter.formatTripLength(listData['tripLength'] ?? 0.0);
        final accommodation = listData['accommodation'] ?? 'NA';
        final itemsActivities =
            List<String>.from(listData['selectedSections'] ?? []);
        final itemsList = listData['items'] as List? ?? [];

        // Extract items from the list data
        final items = <TripItemOverviewData>[];
        for (final itemData in itemsList) {
          final item = itemData as Map<String, dynamic>;
          final iconName = item['iconName'] as String? ?? 'checkroom_rounded';
          items.add(TripItemOverviewData(
            label: item['label'] as String? ?? 'Unknown Item',
            quantity: item['customQuantity'] as int? ??
                item['calculatedQuantity'] as int? ??
                item['baseQuantity'] as int? ??
                1,
            note: item['note'] as String?,
            icon: getIconByName(iconName),
          ));
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Concise summary card
              Card(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 1,
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _InfoPair(label: 'Date', value: date),
                          _InfoPair(label: 'Purpose', value: purpose),
                          _InfoPair(label: 'Weather', value: weather),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _InfoPair(label: 'Duration', value: tripLength),
                          _InfoPair(label: 'Stay', value: accommodation),
                          const SizedBox(width: 60), // for alignment
                        ],
                      ),
                      // Activities chips
                      if (itemsActivities.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: itemsActivities.map((activityId) {
                            final details = activityDetails[activityId];
                            if (details == null) return const SizedBox.shrink();
                            return CustomItemChip(
                              label: details['label'],
                              color: details['color'],
                            );
                          }).toList(),
                        ),
                      ],
                      // Packing Items preview card
                      if (items.isNotEmpty || itemsList.isEmpty) ...[
                        const SizedBox(height: 10),
                        _buildItemsPreview(context, items),
                      ],
                    ],
                  ),
                ),
              ),

              _buildPackingPrompt(context, itemsList.length, listData),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPackingPrompt(
      BuildContext context, int itemCount, Map<String, dynamic> listData) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.checklist_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ready to Pack?',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                      Text(
                        '$itemCount items to pack',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Start the interactive packing process to check off items as you pack them into your bag.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(
                  Icons.play_arrow_rounded,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                label: Text(
                  'Start Packing',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                ),
                onPressed: () {
                  _checkForExistingProgress(context, listData, listId);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsPreview(
      BuildContext context, List<TripItemOverviewData> items) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory_2_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Packing Items',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${items.length} items',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            Text(
              'No items in this list',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          if (items.isNotEmpty)
            Column(
              children: items.take(5).map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).colorScheme.surfaceBright,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item.icon,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.label,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'x${item.quantity}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          if (items.length > 5) ...[
            const SizedBox(height: 8),
            Text(
              '... and ${items.length - 5} more items',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  void _checkForExistingProgress(
      BuildContext context, Map<String, dynamic> listData, String listId) {
    final itemsList = listData['items'] as List? ?? [];
    final checkedItems =
        itemsList.where((item) => item['isChecked'] == true).length;

    if (checkedItems > 0) {
      _showProgressDialog(
          context, checkedItems, itemsList.length, listData, listId);
    } else {
      context.push('/packing-process/$listId');
    }
  }

  void _showProgressDialog(BuildContext context, int checkedItems,
      int totalItems, Map<String, dynamic> listData, String listId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProgressDetectionBottomSheet(
        checkedItems: checkedItems,
        totalItems: totalItems,
        listId: listId,
        listData: listData,
      ),
    );
  }
}

class _ProgressDetectionBottomSheet extends StatelessWidget {
  final int checkedItems;
  final int totalItems;
  final String listId;
  final Map<String, dynamic> listData;

  const _ProgressDetectionBottomSheet({
    required this.checkedItems,
    required this.totalItems,
    required this.listId,
    required this.listData,
  });

  void _continueProgress(BuildContext context) {
    Navigator.pop(context);
    context.push('/packing-process/$listId');
  }

  void _startFresh(BuildContext context) async {
    // Reset all items to unchecked
    final itemsList = listData['items'] as List? ?? [];
    final updatedItems = itemsList.map((item) {
      final itemMap = Map<String, dynamic>.from(item);
      itemMap['isChecked'] = false;
      return itemMap;
    }).toList();

    final updatedListData = {
      ...listData,
      'items': updatedItems,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    // Update in cache
    final cache = context.read<PackingListCache>();
    cache.updateList(listId, updatedListData);

    // Update in Firestore
    try {
      final firestoreService = FirestoreService();
      await firestoreService.updatePackingList(listId, updatedListData);
    } catch (e) {
      debugPrint('Error resetting progress: $e');
    }

    if (context.mounted) {
      Navigator.pop(context);
      context.push('/packing-process/$listId');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Continue Packing?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close_rounded,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                style: IconButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Message
          Text(
            'You have $checkedItems of $totalItems items already checked off from a previous session.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Would you like to continue where you left off?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 32),
          // Continue Progress Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _continueProgress(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Continue Progress',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Start Fresh Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: Icon(
                Icons.refresh_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: Text(
                'Start Fresh',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              onPressed: () => _startFresh(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPair extends StatelessWidget {
  final String label;
  final String value;
  const _InfoPair({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

// Helper class for item preview
class TripItemOverviewData {
  final String label;
  final int quantity;
  final String? note;
  final IconData icon;

  TripItemOverviewData({
    required this.label,
    required this.quantity,
    this.note,
    required this.icon,
  });
}
