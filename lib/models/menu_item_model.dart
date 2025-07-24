import 'package:postgetx/models/menu_variant.dart';

class MenuItemModel {
  final String id;
  final String name;
  final String category; // contoh: "Paket Tumpeng" atau "Extra Lauk"
  final List<MenuVariant> variants;
  final bool isExtra;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.variants,
    this.isExtra = false,
  });

  factory MenuItemModel.fromMap(String id, Map<String, dynamic> map) {
    return MenuItemModel(
      id: id,
      name: map['name'],
      category: map['category'],
      isExtra: map['isExtra'] ?? false,
      variants: (map['variants'] as List<dynamic>)
          .map((v) => MenuVariant.fromMap(v))
          .toList(),
    );
  }

  get prices => null;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'isExtra': isExtra,
      'variants': variants.map((v) => v.toMap()).toList(),
    };
  }
}
