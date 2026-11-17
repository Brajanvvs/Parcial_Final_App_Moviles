import 'package:flutter/material.dart';

class Category {
  const Category({required this.id, required this.name, required this.icon});

  final int id;
  final String name;
  final String icon;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '') as String,
      icon: (json['icon'] ?? '') as String,
    );
  }

  IconData get iconData {
    switch (icon) {
      case 'checkroom':
        return Icons.checkroom_outlined;
      case 'devices':
        return Icons.devices_outlined;
      case 'chair':
        return Icons.chair_outlined;
      case 'sports_soccer':
        return Icons.sports_soccer_outlined;
      case 'spa':
        return Icons.spa_outlined;
      default:
        return Icons.category_outlined;
    }
  }
}
