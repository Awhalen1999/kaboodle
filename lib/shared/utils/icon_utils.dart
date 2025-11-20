import 'package:flutter/material.dart';

/// Utility class for mapping icon name strings to Material IconData
class IconUtils {
  IconUtils._(); // Private constructor to prevent instantiation

  /// Maps common icon names to Material Icons
  /// Returns Icons.category if icon name is not found
  static IconData getIconData(String iconName) {
    final iconMap = {
      'luggage': Icons.luggage,
      'checkroom': Icons.checkroom,
      'local_laundry_service': Icons.local_laundry_service,
      'wc': Icons.wc,
      'clean_hands': Icons.clean_hands,
      'face': Icons.face,
      'health_and_safety': Icons.health_and_safety,
      'headphones': Icons.headphones,
      'phone_iphone': Icons.phone_iphone,
      'laptop': Icons.laptop,
      'camera_alt': Icons.camera_alt,
      'book': Icons.book,
      'sports': Icons.sports,
      'pool': Icons.pool,
      'hiking': Icons.hiking,
      'beach_access': Icons.beach_access,
      'ac_unit': Icons.ac_unit,
      'wb_sunny': Icons.wb_sunny,
      'umbrella': Icons.umbrella,
      'backpack': Icons.backpack,
      'shopping_bag': Icons.shopping_bag,
      'restaurant': Icons.restaurant,
      'local_drink': Icons.local_drink,
      'medication': Icons.medication,
      'vaccines': Icons.vaccines,
      'local_hospital': Icons.local_hospital,
      'power': Icons.power,
      'cable': Icons.cable,
      'vpn_key': Icons.vpn_key,
      'credit_card': Icons.credit_card,
      'attach_money': Icons.attach_money,
      'important_devices': Icons.important_devices,
      'flight': Icons.flight,
      'directions_car': Icons.directions_car,
      'description': Icons.description,
      'badge': Icons.badge,
      'map': Icons.map,
      'navigation': Icons.navigation,
      'toys': Icons.toys,
      'child_care': Icons.child_care,
      'baby_changing_station': Icons.baby_changing_station,
      'pets': Icons.pets,
      'watch': Icons.watch,
      'diamond': Icons.diamond,
      'glasses': Icons.remove_red_eye,
      'umbrella_outline': Icons.beach_access,
    };

    return iconMap[iconName] ?? Icons.category;
  }
}
