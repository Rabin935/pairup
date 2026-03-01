import 'package:pairup/features/notification/data/models/notification_api_models.dart';
import 'package:pairup/features/notification/domain/entities/notification_entities.dart';

abstract interface class INotificationRemoteDataSource {
  Future<List<NotificationItemApiModel>> getNotifications();

  Future<void> respondToNotification({
    required NotificationItemType type,
    required String notificationId,
    required String fromUserId,
    required NotificationItemAction action,
  });
}
