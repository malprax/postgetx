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

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'isExtra': isExtra,
      'variants': variants.map((v) => v.toMap()).toList(),
    };
  }
}

class MenuVariant {
  final String size; // S, M, L, XL
  final int price;

  MenuVariant({
    required this.size,
    required this.price,
  });

  factory MenuVariant.fromMap(Map<String, dynamic> map) {
    return MenuVariant(
      size: map['size'],
      price: map['price'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'size': size,
      'price': price,
    };
  }
}
