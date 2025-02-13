import 'package:flutter/material.dart';

/// Represents a Point of Interest (POI) in the application.
class POIModel {
  final String title; // The name of the POI
  final IconData icon; // The icon representing the POI
  final String route; // The navigation route associated with the POI

  /// Constructor for creating a POIModel instance.
  POIModel({required this.title, required this.icon, required this.route});

  /// Create a POIModel instance from JSON data (uses Factory method).
  factory POIModel.fromJson(Map<String, dynamic> json) {
    return POIModel(
      title: json['title'],
      icon: _getIcon(json['icon']),
      route: json['route'],
    );
  }

  /// Converts an icon string from JSON to an actual IconData object.
  static IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'wc_outlined':
        return Icons.wc_outlined;
      case 'elevator_outlined':
        return Icons.elevator_outlined;
      case 'stairs_outlined':
        return Icons.stairs_outlined;
      case 'directions_run_outlined':
        return Icons.directions_run_outlined;
      case 'local_hospital_outlined':
        return Icons.local_hospital_outlined;
      case 'archive_outlined':
        return Icons.archive_outlined;
      case 'food_bank_outlined':
        return Icons.food_bank_outlined;
      case 'more_outlined':
        return Icons.more_outlined;
      default:
        return Icons.help_outline; // Default fallback icon
    }
  }
}
