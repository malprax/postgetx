class CategoryModel {
  final String id;
  final String name;
  final String iconName;

  CategoryModel({
    required this.id,
    required this.name,
    this.iconName = 'other',
  });

  factory CategoryModel.fromMap(String id, Map<String, dynamic> map) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      iconName: _safeIconName(map['iconName']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'iconName': iconName,
    };
  }

  CategoryModel copyWith({String? id, String? name, String? iconName}) =>
      CategoryModel(
        id: id ?? this.id,
        name: name ?? this.name,
        iconName: iconName ?? this.iconName,
      );

  static String _safeIconName(Object? value) {
    final name = value?.toString().trim() ?? '';
    return name.isEmpty ? 'other' : name;
  }
}
