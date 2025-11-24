import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaboodle_app/shared/utils/country_utils.dart';
import 'package:kaboodle_app/shared/utils/icon_utils.dart';
import 'package:kaboodle_app/shared/utils/string_utils.dart';
import 'package:kaboodle_app/shared/constants/category_colors.dart';

class Step4OverviewBody extends StatelessWidget {
  final Map<String, dynamic> formData;
  final Function(int step)? onEditStep;

  const Step4OverviewBody({
    super.key,
    required this.formData,
    this.onEditStep,
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
            onEdit: () => onEditStep?.call(0),
            child: _buildStep1Content(context),
          ),
          const SizedBox(height: 16),

          // Step 2: Trip Details Container
          _buildSectionContainer(
            context: context,
            title: 'Trip Details',
            onEdit: () => onEditStep?.call(1),
            child: _buildStep2Content(context),
          ),
          const SizedBox(height: 16),

          // Step 3: Packing Items Container
          _buildSectionContainer(
            context: context,
            title: 'Packing Items',
            onEdit: () => onEditStep?.call(2),
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
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and edit button
          Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
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
                        color: colorScheme.outline,
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

    // Build lists for labels and values
    final List<String> labels = [];
    final List<String> values = [];
    String? destinationCode; // Store country code for flag lookup

    labels.add('Trip Name');
    values.add(name ?? 'Not set');

    if (startDate != null && endDate != null) {
      labels.add('Dates');
      values.add(
          '${DateFormat('MMM d').format(startDate)} - ${DateFormat('MMM d, yyyy').format(endDate)}');
    }

    if (destination != null && destination.isNotEmpty) {
      labels.add('Destination');
      // Get the full country name from the country code
      final country = CountryUtils.getCountry(destination);
      destinationCode = destination; // Store the country code
      values.add(country?.name ?? destination);
    }

    if (description != null && description.isNotEmpty) {
      labels.add('Description');
      values.add(description);
    }

    return Column(
      children: List.generate(labels.length, (index) {
        final isDestination = labels[index] == 'Destination';

        return Padding(
          padding: EdgeInsets.only(bottom: index < labels.length - 1 ? 12 : 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label
              SizedBox(
                width: 100,
                child: Text(
                  labels[index],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Value
              Expanded(
                child: isDestination && destinationCode != null
                    ? Row(
                        children: [
                          CountryUtils.getCountryFlag(destinationCode),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              values[index],
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Text(
                        values[index],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
              ),
            ],
          ),
        );
      }),
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

    // Show message if no details added
    if ((gender == null || gender.isEmpty) &&
        (weather == null || weather.isEmpty) &&
        (purpose == null || purpose.isEmpty) &&
        (accommodations == null || accommodations.isEmpty) &&
        (activities == null || activities.isEmpty)) {
      return Text(
        'No trip details added',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    // Build lists for labels and values
    final List<String> labels = [];
    final List<String> values = [];

    if (gender != null && gender.isNotEmpty) {
      labels.add('Gender');
      values.add(StringUtils.capitalize(gender));
    }

    if (weather != null && weather.isNotEmpty) {
      labels.add('Weather');
      values.add(StringUtils.joinCapitalized(weather));
    }

    if (purpose != null && purpose.isNotEmpty) {
      labels.add('Purpose');
      values.add(StringUtils.capitalize(purpose));
    }

    if (accommodations != null && accommodations.isNotEmpty) {
      labels.add('Accommodations');
      values.add(StringUtils.capitalize(accommodations));
    }

    if (activities != null && activities.isNotEmpty) {
      labels.add('Activities');
      values.add(StringUtils.joinCapitalized(activities));
    }

    return Column(
      children: List.generate(labels.length, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index < labels.length - 1 ? 12 : 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label
              SizedBox(
                width: 120,
                child: Text(
                  labels[index],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Value
              Expanded(
                child: Text(
                  values[index],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStep3Content(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final selectedItems = formData['selectedItems'] as Map<String, bool>?;
    final itemQuantities = formData['itemQuantities'] as Map<String, int>?;
    final itemNotes = formData['itemNotes'] as Map<String, String>?;
    final customItems =
        formData['customItems'] as Map<String, List<Map<String, dynamic>>>?;
    final suggestions = formData['suggestions'] as List?;

    if (selectedItems == null || selectedItems.isEmpty) {
      return Text(
        'No items selected',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    // Build a list of all selected items with their details
    final List<Map<String, dynamic>> allItems = [];

    // Add template items (from suggestions)
    if (suggestions != null) {
      for (var suggestion in suggestions) {
        final id = suggestion.id;
        final isSelected = selectedItems[id] ?? false;
        if (isSelected) {
          allItems.add({
            'name': suggestion.name,
            'icon': suggestion.icon,
            'category': suggestion.category,
            'quantity': itemQuantities?[id] ?? suggestion.defaultQuantity,
            'note': itemNotes?[id] ?? '',
            'isCustom': false,
          });
        }
      }
    }

    // Add custom items
    if (customItems != null) {
      for (var entry in customItems.entries) {
        final category = entry.key;
        final categoryItems = entry.value;
        for (var item in categoryItems) {
          final id = item['id'] as String;
          final isSelected = selectedItems[id] ?? false;
          if (isSelected) {
            allItems.add({
              'name': item['name'],
              'icon': '',
              'category': category,
              'quantity': itemQuantities?[id] ?? item['quantity'],
              'note': itemNotes?[id] ?? item['note'] ?? '',
              'isCustom': true,
            });
          }
        }
      }
    }

    if (allItems.isEmpty) {
      return Text(
        'No items selected',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: allItems.map((item) {
        final name = item['name'] as String;
        final iconName = item['icon'] as String;
        final category = item['category'] as String?;
        final quantity = item['quantity'] as int;
        final note = item['note'] as String;
        final isCustom = item['isCustom'] as bool;

        return _buildItemTile(
          context: context,
          icon: isCustom
              ? Icons.bookmark_border_rounded
              : IconUtils.getIconData(iconName),
          itemName: name,
          category: category,
          quantity: quantity,
          note: note,
        );
      }).toList(),
    );
  }

  /// Build a simplified item tile (similar to CheckboxTile but without checkbox and edit button)
  Widget _buildItemTile({
    required BuildContext context,
    required IconData icon,
    required String itemName,
    String? category,
    required int quantity,
    required String note,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get category color if available
    final categoryColor = category != null
        ? CategoryColors.getCategoryColorWithContext(category, context)
        : colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // Icon section
            Container(
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(4),
              child: Icon(
                icon,
                size: 22,
                color: categoryColor,
              ),
            ),
            const SizedBox(width: 12),

            // Text section with name, quantity, and optional note
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$itemName   x$quantity',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.normal,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (note.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        note,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
