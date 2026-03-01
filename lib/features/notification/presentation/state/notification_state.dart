import 'package:equatable/equatable.dart';
import 'package:pairup/features/notification/domain/entities/notification_entities.dart';

enum NotificationStatus { initial, loading, loaded, error }

class NotificationState extends Equatable {
  final NotificationStatus status;
  final List<NotificationItemEntity> notifications;
  final String? errorMessage;
  final List<String> processingKeys;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.notifications = const [],
    this.errorMessage,
    this.processingKeys = const [],
  });

  int get unreadCount =>
      notifications.where((item) => item.isRead == false).length;

  NotificationState copyWith({
    NotificationStatus? status,
    List<NotificationItemEntity>? notifications,
    String? errorMessage,
    List<String>? processingKeys,
    bool clearErrorMessage = false,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      processingKeys: processingKeys ?? this.processingKeys,
    );
  }

  @override
  List<Object?> get props => [
    status,
    notifications,
    errorMessage,
    processingKeys,
  ];
}
