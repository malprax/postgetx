class MenuItemModel {
  final String id;
  final String name;
  final String categoryId;
  final Map<String, double> prices;
  final bool isAvailable;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.prices,
    this.isAvailable = true,
  });

  factory MenuItemModel.fromMap(Map<String, dynamic> map, String id) {
    return MenuItemModel(
      id: id,
      name: map['name'] ?? '',
      categoryId: map['categoryId'] ?? '',
      prices: Map<String, double>.from(map['prices'] ?? {}),
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'categoryId': categoryId,
      'prices': prices,
      'isAvailable': isAvailable,
    };
  }
}
