import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kaboodle_app/shared/utils/country_utils.dart';

class PackingListTile extends StatelessWidget {
  final String tripName;
  final String? description;
  final String? startDate;
  final String? endDate;
  final String? destination;
  final Color accentColor;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const PackingListTile({
    super.key,
    required this.tripName,
    this.description,
    this.startDate,
    this.endDate,
    this.destination,
    required this.accentColor,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Slidable(
      enabled: onDelete != null,
      endActionPane: onDelete != null
          ? ActionPane(
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) => onDelete!(),
                  backgroundColor: const Color(0xFFFE4A49),
                  foregroundColor: Colors.white,
                  icon: Icons.delete_outline,
                  label: 'Delete',
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            )
          : null,
      child: GestureDetector(
        onTap: () {
          debugPrint('🎯 Tapped packing list: $tripName');
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            border: Border.all(
              color: colorScheme.outline,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Color stripe column
              Container(
                width: 4,
                constraints: const BoxConstraints(minHeight: 80),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
              ),
              // Main content column
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Trip name
                      Text(
                        tripName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (description != null && description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      // Chips row
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          // Date chip
                          if (startDate != null || endDate != null)
                            _buildChip(
                              context,
                              icon: Icons.calendar_today,
                              label: _formatDateRange(),
                            ),
                          // Location chip
                          if (destination != null && destination!.isNotEmpty)
                            _buildLocationChip(context, destination!),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context,
      {required IconData icon, required String label}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationChip(BuildContext context, String countryCode) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final country = CountryUtils.getCountry(countryCode);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Flag emoji
          if (country != null)
            Text(
              country.flagEmoji,
              style: const TextStyle(fontSize: 12),
            ),
          const SizedBox(width: 4),
          Text(
            country?.name ?? countryCode,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateRange() {
    if (startDate != null && endDate != null) {
      return '$startDate - $endDate';
    } else if (startDate != null) {
      return startDate!;
    } else if (endDate != null) {
      return endDate!;
    }
    return '';
  }
}
