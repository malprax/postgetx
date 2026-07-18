class LocalNotificationModel {
  const LocalNotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.entityType,
    required this.entityId,
    required this.route,
    required this.createdAt,
    required this.isRead,
    this.readAt,
    required this.actorId,
    required this.actorName,
    required this.severity,
  });

  final String id;
  final String type;
  final String title;
  final String message;
  final String entityType;
  final String entityId;
  final String route;
  final DateTime createdAt;
  final bool isRead;
  final DateTime? readAt;
  final String actorId;
  final String actorName;
  final String severity;

  factory LocalNotificationModel.fromMap(Map<String, dynamic> map) =>
      LocalNotificationModel(
        id: map['id']?.toString() ?? '',
        type: map['type']?.toString() ?? 'activity',
        title: map['title']?.toString() ?? '',
        message: map['message']?.toString() ?? '',
        entityType: map['entityType']?.toString() ?? '',
        entityId: map['entityId']?.toString() ?? '',
        route: map['route']?.toString() ?? '',
        createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        isRead: map['isRead'] as bool? ?? false,
        readAt: DateTime.tryParse(map['readAt']?.toString() ?? ''),
        actorId: map['actorId']?.toString() ?? '',
        actorName: map['actorName']?.toString() ?? 'System',
        severity: map['severity']?.toString() ?? 'info',
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'title': title,
        'message': message,
        'entityType': entityType,
        'entityId': entityId,
        'route': route,
        'createdAt': createdAt.toIso8601String(),
        'isRead': isRead,
        'readAt': readAt?.toIso8601String(),
        'actorId': actorId,
        'actorName': actorName,
        'severity': severity,
      };

  LocalNotificationModel copyWith({bool? isRead, DateTime? readAt}) =>
      LocalNotificationModel(
        id: id,
        type: type,
        title: title,
        message: message,
        entityType: entityType,
        entityId: entityId,
        route: route,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
        readAt: readAt ?? this.readAt,
        actorId: actorId,
        actorName: actorName,
        severity: severity,
      );
}
