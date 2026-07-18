class ExpenseModel {
  const ExpenseModel(
      {required this.id,
      required this.title,
      required this.amount,
      required this.category,
      required this.createdAt});
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime createdAt;
  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'amount': amount,
        'category': category,
        'createdAt': createdAt.toIso8601String()
      };
  factory ExpenseModel.fromMap(Map<String, dynamic> map) => ExpenseModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      category: map['category']?.toString() ?? 'General',
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now());
}
