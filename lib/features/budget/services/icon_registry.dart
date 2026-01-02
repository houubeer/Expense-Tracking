import 'package:flutter/material.dart';

/// Registry for category icons (OCP compliance)
/// Allows adding new icons without modifying existing code
class IconRegistry {
  factory IconRegistry() => _instance;
  IconRegistry._internal();
  static final IconRegistry _instance = IconRegistry._internal();

  final List<IconData> _icons = [
    // Default icons
    Icons.shopping_cart,
    Icons.restaurant,
    Icons.local_gas_station,
    Icons.home,
    Icons.medical_services,
    Icons.school,
    Icons.sports_esports,
    Icons.flight,
    Icons.shopping_bag,
    Icons.coffee,
    Icons.fitness_center,
    Icons.pets,
    Icons.child_care,
    Icons.phone_android,
    Icons.computer,
    Icons.music_note,
    Icons.movie,
    Icons.book,
    Icons.directions_car,
    Icons.train,
    Icons.local_taxi,
    Icons.local_hospital,
    Icons.local_pharmacy,
    Icons.local_grocery_store,
    Icons.local_mall,
    Icons.local_cafe,
    Icons.local_dining,
    Icons.local_pizza,
    Icons.local_bar,
    Icons.fastfood,
    Icons.cake,
    Icons.local_florist,
    Icons.local_laundry_service,
    Icons.local_library,
    Icons.local_movies,
    Icons.local_parking,
    Icons.local_post_office,
    Icons.local_printshop,
    Icons.local_see,
    Icons.local_shipping,
    Icons.hotel,
    Icons.beach_access,
    Icons.pool,
    Icons.spa,
    Icons.casino,
    Icons.nightlife,
    Icons.sports_soccer,
    Icons.sports_basketball,
  ];

  /// Get all registered icons
  List<IconData> get icons => List.unmodifiable(_icons);

  /// Register a new icon (extends without modification)
  void registerIcon(IconData icon) {
    if (!_icons.contains(icon)) {
      _icons.add(icon);
    }
  }

  /// Register multiple icons
  void registerIcons(List<IconData> icons) {
    for (final icon in icons) {
      registerIcon(icon);
    }
  }

  /// Clear all icons (useful for testing)
  void clear() {
    _icons.clear();
  }

  /// Reset to default icons
  void resetToDefaults() {
    _icons.clear();
    _icons.addAll([
      Icons.shopping_cart,
      Icons.restaurant,
      Icons.local_gas_station,
      Icons.home,
      Icons.medical_services,
      Icons.school,
      Icons.sports_esports,
      Icons.flight,
      Icons.shopping_bag,
      Icons.coffee,
      Icons.fitness_center,
      Icons.pets,
      Icons.child_care,
      Icons.phone_android,
      Icons.computer,
      Icons.music_note,
      Icons.movie,
      Icons.book,
      Icons.directions_car,
      Icons.train,
      Icons.local_taxi,
      Icons.local_hospital,
      Icons.local_pharmacy,
      Icons.local_grocery_store,
      Icons.local_mall,
      Icons.local_cafe,
      Icons.local_dining,
      Icons.local_pizza,
      Icons.local_bar,
      Icons.fastfood,
      Icons.cake,
      Icons.local_florist,
      Icons.local_laundry_service,
      Icons.local_library,
      Icons.local_movies,
      Icons.local_parking,
      Icons.local_post_office,
      Icons.local_printshop,
      Icons.local_see,
      Icons.local_shipping,
      Icons.hotel,
      Icons.beach_access,
      Icons.pool,
      Icons.spa,
      Icons.casino,
      Icons.nightlife,
      Icons.sports_soccer,
      Icons.sports_basketball,
    ]);
  }
}
