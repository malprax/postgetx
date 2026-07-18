import 'package:flutter/material.dart';

class CategoryIconOption {
  const CategoryIconOption({
    required this.name,
    required this.label,
    required this.icon,
  });

  final String name;
  final String label;
  final IconData icon;
}

abstract final class CategoryIconRegistry {
  static const all = <CategoryIconOption>[
    CategoryIconOption(
        name: 'beverages', label: 'Beverages', icon: Icons.local_drink),
    CategoryIconOption(
        name: 'snacks', label: 'Snacks', icon: Icons.cookie_outlined),
    CategoryIconOption(
        name: 'grocery',
        label: 'Grocery',
        icon: Icons.shopping_basket_outlined),
    CategoryIconOption(
        name: 'personalCare', label: 'Personal Care', icon: Icons.spa_outlined),
    CategoryIconOption(
        name: 'household', label: 'Household', icon: Icons.cleaning_services),
    CategoryIconOption(
        name: 'electronics', label: 'Electronics', icon: Icons.devices_other),
    CategoryIconOption(
        name: 'clothing', label: 'Clothing', icon: Icons.checkroom_outlined),
    CategoryIconOption(
        name: 'health',
        label: 'Health',
        icon: Icons.health_and_safety_outlined),
    CategoryIconOption(
        name: 'beauty', label: 'Beauty', icon: Icons.brush_outlined),
    CategoryIconOption(
        name: 'stationery', label: 'Stationery', icon: Icons.edit_note),
    CategoryIconOption(
        name: 'food', label: 'Food', icon: Icons.restaurant_outlined),
    CategoryIconOption(
        name: 'bakery', label: 'Bakery', icon: Icons.bakery_dining_outlined),
    CategoryIconOption(name: 'frozen', label: 'Frozen', icon: Icons.ac_unit),
    CategoryIconOption(
        name: 'petSupplies', label: 'Pet Supplies', icon: Icons.pets_outlined),
    CategoryIconOption(
        name: 'automotive',
        label: 'Automotive',
        icon: Icons.directions_car_outlined),
    CategoryIconOption(name: 'home', label: 'Home', icon: Icons.home_outlined),
    CategoryIconOption(
        name: 'tools', label: 'Tools', icon: Icons.handyman_outlined),
    CategoryIconOption(
        name: 'other', label: 'Other', icon: Icons.inventory_2_outlined),
  ];

  static const defaultOption = CategoryIconOption(
      name: 'other', label: 'Other', icon: Icons.inventory_2_outlined);

  static CategoryIconOption findByName(String? name) => all.firstWhere(
        (option) => option.name == name,
        orElse: () => defaultOption,
      );

  static IconData iconFor(String? name) => findByName(name).icon;
  static String labelFor(String? name) => findByName(name).label;
  static bool isSupported(String? name) =>
      all.any((option) => option.name == name);
}
