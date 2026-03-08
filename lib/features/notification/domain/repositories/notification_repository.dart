import 'package:dartz/dartz.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/features/notification/domain/entities/notification_entities.dart';

abstract interface class INotificationRepository {
  Future<Either<Failure, List<NotificationItemEntity>>> getNotifications();

  Future<Either<Failure, Unit>> respondToNotification({
    required NotificationItemEntity notification,
    required NotificationItemAction action,
  });
}
