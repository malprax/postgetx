class OrderLogModel {
  final String orderId;
  final String action;
  final String performedBy; // UID user
  final DateTime timestamp;
  final String message;

  OrderLogModel({
    required this.orderId,
    required this.action,
    required this.performedBy,
    required this.timestamp,
    required this.message,
  });

  Map<String, dynamic> toMap() => {
        'orderId': orderId,
        'action': action,
        'performedBy': performedBy,
        'timestamp': timestamp.toIso8601String(),
        'message': message,
      };
}
