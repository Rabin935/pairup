import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/core/services/storage/user_session_service.dart';
import 'package:pairup/features/notification/domain/entities/notification_entities.dart';
import 'package:pairup/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:pairup/features/notification/domain/usecases/respond_notification_usecase.dart';
import 'package:pairup/features/notification/presentation/state/notification_state.dart';
import 'package:pairup/features/notification/presentation/view_model/notification_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_helpers/mocks.dart';
import '../test_helpers/test_data.dart';

void main() {
  late MockGetNotificationsUsecase getNotificationsUsecase;
  late MockRespondNotificationUsecase respondNotificationUsecase;
  late MockUserSessionService userSessionService;
  late SharedPreferences prefs;
  late ProviderContainer container;

  setUpAll(registerCommonFallbackValues);

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();

    getNotificationsUsecase = MockGetNotificationsUsecase();
    respondNotificationUsecase = MockRespondNotificationUsecase();
    userSessionService = MockUserSessionService();

    when(() => userSessionService.getCurrentUserId()).thenReturn('user-1');

    container = ProviderContainer(
      overrides: [
        getNotificationsUsecaseProvider.overrideWith((ref) => getNotificationsUsecase),
        respondNotificationUsecaseProvider.overrideWith(
          (ref) => respondNotificationUsecase,
        ),
        userSessionServiceProvider.overrideWith((ref) => userSessionService),
        sharedPreferencesProvider.overrideWith((ref) => prefs),
      ],
    );

    addTearDown(container.dispose);
  });

  test('MatchViewModel load matches handles loading, success, and error states', () async {
    when(() => getNotificationsUsecase())
        .thenAnswer((_) async => rightResult([sampleNotification]));

    final notifier = container.read(notificationViewModelProvider.notifier);

    final successFuture = notifier.loadNotifications();
    expect(container.read(notificationViewModelProvider).status, NotificationStatus.loading);

    await successFuture;
    expect(container.read(notificationViewModelProvider).status, NotificationStatus.loaded);

    when(() => getNotificationsUsecase())
        .thenAnswer((_) async => leftResult('load failed'));

    final errorFuture = notifier.loadNotifications();
    expect(container.read(notificationViewModelProvider).status, NotificationStatus.loading);

    await errorFuture;
    final errorState = container.read(notificationViewModelProvider);
    expect(errorState.status, NotificationStatus.error);
    expect(errorState.errorMessage, 'load failed');
  });

  test('MatchViewModel accept match handles loading, success, and error states', () async {
    final notification = sampleNotification.copyWith(type: NotificationItemType.like);

    when(() => getNotificationsUsecase())
        .thenAnswer((_) async => rightResult([notification]));

    final notifier = container.read(notificationViewModelProvider.notifier);
    await notifier.loadNotifications(showLoading: false);

    final completer = Completer<Either<Failure, Unit>>();
    when(() => respondNotificationUsecase(any<RespondNotificationUsecaseParams>()))
        .thenAnswer((_) => completer.future);

    final successFuture = notifier.respondToNotification(
      notification,
      NotificationItemAction.accept,
    );

    expect(
      container.read(notificationViewModelProvider).processingKeys,
      contains(notification.key),
    );

    completer.complete(const Right(unit));
    await successFuture;

    final successState = container.read(notificationViewModelProvider);
    expect(
      successState.notifications.firstWhere((n) => n.key == notification.key).status,
      'accepted',
    );

    when(() => respondNotificationUsecase(any<RespondNotificationUsecaseParams>()))
        .thenAnswer((_) async => leftResult('accept failed'));

    final errorFuture = notifier.respondToNotification(
      notification,
      NotificationItemAction.accept,
    );

    expect(
      container.read(notificationViewModelProvider).processingKeys,
      contains(notification.key),
    );

    await errorFuture;
    expect(container.read(notificationViewModelProvider).errorMessage, 'accept failed');
  });

  test('MatchViewModel reject match handles loading, success, and error states', () async {
    final notification = sampleNotification.copyWith(type: NotificationItemType.invite);

    when(() => getNotificationsUsecase())
        .thenAnswer((_) async => rightResult([notification]));

    final notifier = container.read(notificationViewModelProvider.notifier);
    await notifier.loadNotifications(showLoading: false);

    final completer = Completer<Either<Failure, Unit>>();
    when(() => respondNotificationUsecase(any<RespondNotificationUsecaseParams>()))
        .thenAnswer((_) => completer.future);

    final successFuture = notifier.respondToNotification(
      notification,
      NotificationItemAction.decline,
    );

    expect(
      container.read(notificationViewModelProvider).processingKeys,
      contains(notification.key),
    );

    completer.complete(const Right(unit));
    await successFuture;

    final successState = container.read(notificationViewModelProvider);
    expect(
      successState.notifications.firstWhere((n) => n.key == notification.key).status,
      'rejected',
    );

    when(() => respondNotificationUsecase(any<RespondNotificationUsecaseParams>()))
        .thenAnswer((_) async => leftResult('reject failed'));

    final errorFuture = notifier.respondToNotification(
      notification,
      NotificationItemAction.decline,
    );

    expect(
      container.read(notificationViewModelProvider).processingKeys,
      contains(notification.key),
    );

    await errorFuture;
    expect(container.read(notificationViewModelProvider).errorMessage, 'reject failed');
  });
}
