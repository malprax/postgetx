// menu_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuModel {
  final String id;
  final String name;
  final String category;
  final double basePrice;
  final List<String> sizes;
  final Map<String, double> sizePrices;
  final List<String> extras;
  final Timestamp createdAt;

  MenuModel({
    required this.id,
    required this.name,
    required this.category,
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
      category: data['category'] ?? '',
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
      'category': category,
      'basePrice': basePrice,
      'sizes': sizes,
      'sizePrices': sizePrices,
      'extras': extras,
      'createdAt': createdAt,
    };
  }
}
