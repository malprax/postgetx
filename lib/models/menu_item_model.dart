// lib/models/menu_item_model.dart

import 'menu_variant.dart';

class MenuItemModel {
  final String id;
  final String name;
  final String categoryId;
  final String? categoryName; // only for display
  final List<MenuVariant> variants;
  final String? description;
  final String? imageUrl;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.categoryId,
    this.categoryName,
    required this.variants,
    this.description,
    this.imageUrl,
  });

  factory MenuItemModel.fromMap(String id, Map<String, dynamic> data) {
    return MenuItemModel(
      id: id,
      name: data['name'] ?? '',
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'], // optional
      variants: (data['variants'] as List<dynamic>?)
              ?.map((v) => MenuVariant.fromMap(v))
              .toList() ??
          [],
      description: data['description'],
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'categoryId': categoryId,
      'categoryName': categoryName, // stored for display
      'variants': variants.map((v) => v.toMap()).toList(),
      'description': description,
      'imageUrl': imageUrl,
    };
  }

  MenuItemModel copyWith({
    String? id,
    String? name,
    String? categoryId,
    String? categoryName,
    List<MenuVariant>? variants,
    String? description,
    String? imageUrl,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      variants: variants ?? this.variants,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
