import 'package:postgetx/app/data/models/local_notification_model.dart';

abstract class NotificationRepository {
  Future<List<LocalNotificationModel>> getNotifications({int? limit});
  Future<void> markNotificationRead(String id, {required bool isRead});
  Future<void> markAllNotificationsRead();
}
