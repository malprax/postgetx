// menu_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuModel {
  final String id;
  final String name;
  final String categoryId;
  final double basePrice;
  final List<String> sizes;
  final Map<String, double> sizePrices;
  final List<String> extras;
  final Timestamp createdAt;

  MenuModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.basePrice,
    required this.sizes,
    required this.sizePrices,
    required this.extras,
    required this.createdAt,
  });

  factory MenuModel.fromMap(String id, Map<String, dynamic> data) {
    return MenuModel(
      id: id,
      name: data['name'] ?? '',
      categoryId: data['categoryId'] ?? '',
      basePrice: (data['basePrice'] ?? 0).toDouble(),
      sizes: List<String>.from(data['sizes'] ?? []),
      sizePrices: Map<String, double>.from(
        (data['sizePrices'] ?? {})
            .map((k, v) => MapEntry(k, (v as num).toDouble())),
      ),
      extras: List<String>.from(data['extras'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'categoryId': categoryId,
      'basePrice': basePrice,
      'sizes': sizes,
      'sizePrices': sizePrices,
      'extras': extras,
      'createdAt': createdAt,
    };
  }
}
