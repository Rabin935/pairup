import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/core/usecases/app_usecase.dart';
import 'package:pairup/features/notification/data/repositories/notification_repository.dart';
import 'package:pairup/features/notification/domain/entities/notification_entities.dart';
import 'package:pairup/features/notification/domain/repositories/notification_repository.dart';

final getNotificationsUsecaseProvider = Provider<GetNotificationsUsecase>((
  ref,
) {
  return GetNotificationsUsecase(
    notificationRepository: ref.read(notificationRepositoryProvider),
  );
});

class GetNotificationsUsecase
    implements UsecaseWithoutParams<List<NotificationItemEntity>> {
  final INotificationRepository _notificationRepository;

  GetNotificationsUsecase({
    required INotificationRepository notificationRepository,
  }) : _notificationRepository = notificationRepository;

  @override
  Future<Either<Failure, List<NotificationItemEntity>>> call() {
    return _notificationRepository.getNotifications();
  }
}
