import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/core/usecases/app_usecase.dart';
import 'package:pairup/features/notification/data/repositories/notification_repository.dart';
import 'package:pairup/features/notification/domain/entities/notification_entities.dart';
import 'package:pairup/features/notification/domain/repositories/notification_repository.dart';

class RespondNotificationUsecaseParams extends Equatable {
  final NotificationItemEntity notification;
  final NotificationItemAction action;

  const RespondNotificationUsecaseParams({
    required this.notification,
    required this.action,
  });

  @override
  List<Object?> get props => [notification, action];
}

final respondNotificationUsecaseProvider = Provider<RespondNotificationUsecase>(
  (ref) {
    return RespondNotificationUsecase(
      notificationRepository: ref.read(notificationRepositoryProvider),
    );
  },
);

class RespondNotificationUsecase
    implements UsecaseWithParams<Unit, RespondNotificationUsecaseParams> {
  final INotificationRepository _notificationRepository;

  RespondNotificationUsecase({
    required INotificationRepository notificationRepository,
  }) : _notificationRepository = notificationRepository;

  @override
  Future<Either<Failure, Unit>> call(RespondNotificationUsecaseParams params) {
    return _notificationRepository.respondToNotification(
      notification: params.notification,
      action: params.action,
    );
  }
}
