// lib/models/menu_item_model.dart

import 'menu_variant.dart';

class MenuItemModel {
  final String id;
  final String name;
  final String categoryId;
  final String? categoryName; // only for display
  final List<MenuVariant> variants;
  final String? description;
  final String imageBase64;
  final String imageMimeType;
  final String imageName;
  final String sku;
  final int stock;
  final int lowStockThreshold;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.categoryId,
    this.categoryName,
    required this.variants,
    this.description,
    this.imageBase64 = '',
    this.imageMimeType = '',
    this.imageName = '',
    this.sku = '',
    this.stock = 0,
    this.lowStockThreshold = 5,
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
      imageBase64: data['imageBase64']?.toString() ?? '',
      imageMimeType: data['imageMimeType']?.toString() ?? '',
      imageName: data['imageName']?.toString() ?? '',
      sku: data['sku']?.toString() ?? id.toUpperCase(),
      stock: (data['stock'] as num?)?.toInt() ?? 0,
      lowStockThreshold: (data['lowStockThreshold'] as num?)?.toInt() ?? 5,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'categoryId': categoryId,
      'categoryName': categoryName, // stored for display
      'variants': variants.map((v) => v.toMap()).toList(),
      'description': description,
      'imageBase64': imageBase64,
      'imageMimeType': imageMimeType,
      'imageName': imageName,
      'sku': sku,
      'stock': stock,
      'lowStockThreshold': lowStockThreshold,
    };
  }

  MenuItemModel copyWith({
    String? id,
    String? name,
    String? categoryId,
    String? categoryName,
    List<MenuVariant>? variants,
    String? description,
    String? imageBase64,
    String? imageMimeType,
    String? imageName,
    String? sku,
    int? stock,
    int? lowStockThreshold,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      variants: variants ?? this.variants,
      description: description ?? this.description,
      imageBase64: imageBase64 ?? this.imageBase64,
      imageMimeType: imageMimeType ?? this.imageMimeType,
      imageName: imageName ?? this.imageName,
      sku: sku ?? this.sku,
      stock: stock ?? this.stock,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
    );
  }

  bool get hasImage => imageBase64.trim().isNotEmpty;
}
