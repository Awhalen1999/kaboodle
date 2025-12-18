import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String text;
  final String? mode;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;
  final bool showChevron;
  final bool isGrouped;

  const SettingsTile({
    super.key,
    this.icon,
    this.iconColor,
    required this.text,
    this.mode,
    this.trailing,
    this.onTap,
    this.showDivider = true,
    this.showChevron = true,
    this.isGrouped = false,
  });

  @override
  Widget build(BuildContext context) {
    final tileContent = InkWell(
      onTap: onTap != null
          ? () {
              onTap!();
            }
          : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: [
            // Icon
            if (icon != null) ...[
              Icon(
                icon,
                color: iconColor ?? Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
            ],
            // Text
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ),
            // Mode text (displayed in primary color)
            if (mode != null) ...[
              const SizedBox(width: 8),
              Text(
                mode!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
            // Trailing widget (chevron, toggle, value, etc.)
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ] else if (onTap != null && showChevron) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.outlineVariant,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );

    if (isGrouped) {
      return Column(
        children: [
          tileContent,
          if (showDivider)
            Divider(
              height: 1,
              thickness: 1,
              color: Theme.of(context).colorScheme.outline,
            ),
        ],
      );
    }

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: tileContent,
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.outline,
          ),
      ],
    );
  }
}

/// A container that groups multiple SettingsTile widgets together
class SettingsTileGroup extends StatelessWidget {
  final List<SettingsTile> tiles;

  const SettingsTileGroup({
    super.key,
    required this.tiles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: tiles,
      ),
    );
  }
}
