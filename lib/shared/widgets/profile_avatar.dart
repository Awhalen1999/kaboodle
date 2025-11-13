import 'package:flutter/material.dart';

// Reusable profile avatar widget
// Displays user photo or fallback icon
class ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final double size;
  final double borderRadius;
  final Color? backgroundColor;
  final IconData fallbackIcon;
  final double fallbackIconSize;
  final Color? fallbackIconColor;

  const ProfileAvatar({
    super.key,
    this.photoUrl,
    this.size = 100,
    this.borderRadius = 16,
    this.backgroundColor,
    this.fallbackIcon = Icons.person,
    this.fallbackIconSize = 50,
    this.fallbackIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: backgroundColor ?? Colors.grey[300],
      ),
      clipBehavior: Clip.antiAlias,
      child: photoUrl != null
          ? Image.network(
              photoUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  fallbackIcon,
                  size: fallbackIconSize,
                  color: fallbackIconColor ?? Colors.grey[600],
                );
              },
            )
          : Icon(
              fallbackIcon,
              size: fallbackIconSize,
              color: fallbackIconColor ?? Colors.grey[600],
            ),
    );
  }
}
