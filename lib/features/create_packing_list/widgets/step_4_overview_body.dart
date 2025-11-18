import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Step4OverviewBody extends StatelessWidget {
  final Map<String, dynamic> formData;

  const Step4OverviewBody({
    super.key,
    required this.formData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Review & Finish',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Review your trip details before creating your packing list',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Step 1: General Info Container
          _buildSectionContainer(
            context: context,
            title: 'General Info',
            onEdit: () => print('🔧 Edit Step 1 clicked'),
            child: _buildStep1Content(context),
          ),
          const SizedBox(height: 16),

          // Step 2: Trip Details Container
          _buildSectionContainer(
            context: context,
            title: 'Trip Details',
            onEdit: () => print('🔧 Edit Step 2 clicked'),
            child: _buildStep2Content(context),
          ),
          const SizedBox(height: 16),

          // Step 3: Packing Items Container
          _buildSectionContainer(
            context: context,
            title: 'Packing Items',
            onEdit: () => print('🔧 Edit Step 3 clicked'),
            child: _buildStep3Content(context),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({
    required BuildContext context,
    required String title,
    required VoidCallback onEdit,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and edit button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit,
                          size: 14,
                          color: colorScheme.onSurface,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Edit',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Divider(
            height: 1,
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildStep1Content(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final name = formData['name'] as String?;
    final startDate = formData['startDate'] as DateTime?;
    final endDate = formData['endDate'] as DateTime?;
    final destination = formData['destination'] as String?;
    final description = formData['description'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          context: context,
          label: 'Trip Name',
          value: name ?? 'Not set',
        ),
        if (startDate != null && endDate != null) ...[
          const SizedBox(height: 12),
          _buildInfoRow(
            context: context,
            label: 'Dates',
            value:
                '${DateFormat('MMM d').format(startDate)} - ${DateFormat('MMM d, yyyy').format(endDate)}',
          ),
        ],
        if (destination != null && destination.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildInfoRow(
            context: context,
            label: 'Destination',
            value: destination,
          ),
        ],
        if (description != null && description.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildInfoRow(
            context: context,
            label: 'Description',
            value: description,
          ),
        ],
      ],
    );
  }

  Widget _buildStep2Content(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final gender = formData['gender'] as String?;
    final weather = formData['weather'] as List?;
    final purpose = formData['purpose'] as String?;
    final accommodations = formData['accommodations'] as String?;
    final activities = formData['activities'] as List?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (gender != null && gender.isNotEmpty)
          _buildInfoRow(
            context: context,
            label: 'Gender',
            value: gender[0].toUpperCase() + gender.substring(1),
          ),
        if (weather != null && weather.isNotEmpty) ...[
          if (gender != null && gender.isNotEmpty) const SizedBox(height: 12),
          _buildInfoRow(
            context: context,
            label: 'Weather',
            value: weather
                .map((w) => w.toString()[0].toUpperCase() + w.toString().substring(1))
                .join(', '),
          ),
        ],
        if (purpose != null && purpose.isNotEmpty) ...[
          if ((gender != null && gender.isNotEmpty) ||
              (weather != null && weather.isNotEmpty))
            const SizedBox(height: 12),
          _buildInfoRow(
            context: context,
            label: 'Purpose',
            value: purpose[0].toUpperCase() + purpose.substring(1),
          ),
        ],
        if (accommodations != null && accommodations.isNotEmpty) ...[
          if ((gender != null && gender.isNotEmpty) ||
              (weather != null && weather.isNotEmpty) ||
              (purpose != null && purpose.isNotEmpty))
            const SizedBox(height: 12),
          _buildInfoRow(
            context: context,
            label: 'Accommodations',
            value: accommodations[0].toUpperCase() + accommodations.substring(1),
          ),
        ],
        if (activities != null && activities.isNotEmpty) ...[
          if ((gender != null && gender.isNotEmpty) ||
              (weather != null && weather.isNotEmpty) ||
              (purpose != null && purpose.isNotEmpty) ||
              (accommodations != null && accommodations.isNotEmpty))
            const SizedBox(height: 12),
          _buildInfoRow(
            context: context,
            label: 'Activities',
            value: activities
                .map((a) => a.toString()[0].toUpperCase() + a.toString().substring(1))
                .join(', '),
          ),
        ],
        // Show message if no details added
        if ((gender == null || gender.isEmpty) &&
            (weather == null || weather.isEmpty) &&
            (purpose == null || purpose.isEmpty) &&
            (accommodations == null || accommodations.isEmpty) &&
            (activities == null || activities.isEmpty))
          Text(
            'No trip details added',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  Widget _buildStep3Content(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final selectedItems = formData['selectedItems'] as Map<String, bool>?;
    final customItems = formData['customItems'] as Map<String, List<Map<String, dynamic>>>?;

    if (selectedItems == null || selectedItems.isEmpty) {
      return Text(
        'No items selected',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    // Count selected items
    final selectedCount = selectedItems.values.where((v) => v == true).length;

    // Count custom items
    int customCount = 0;
    if (customItems != null) {
      for (var items in customItems.values) {
        customCount += items.length;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          context: context,
          label: 'Total Items',
          value: '$selectedCount items selected',
        ),
        if (customCount > 0) ...[
          const SizedBox(height: 12),
          _buildInfoRow(
            context: context,
            label: 'Custom Items',
            value: '$customCount custom items added',
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
