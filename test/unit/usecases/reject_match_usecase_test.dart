import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/features/notification/domain/entities/notification_entities.dart';
import 'package:pairup/features/notification/domain/usecases/respond_notification_usecase.dart';

import '../test_helpers/mocks.dart';
import '../test_helpers/test_data.dart';

void main() {
  late MockNotificationRepository repository;
  late RespondNotificationUsecase usecase;

  setUpAll(registerCommonFallbackValues);

  setUp(() {
    repository = MockNotificationRepository();
    usecase = RespondNotificationUsecase(notificationRepository: repository);
  });

  test('returns unit when reject action succeeds', () async {
    final params = RespondNotificationUsecaseParams(
      notification: sampleNotification,
      action: NotificationItemAction.decline,
    );

    when(
      () => repository.respondToNotification(
        notification: params.notification,
        action: params.action,
      ),
    ).thenAnswer((_) async => rightResult(unit));

    final result = await usecase(params);

    expect(result, const Right(unit));
    verify(
      () => repository.respondToNotification(
        notification: params.notification,
        action: params.action,
      ),
    ).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Failure when reject action fails', () async {
    final params = RespondNotificationUsecaseParams(
      notification: sampleNotification,
      action: NotificationItemAction.decline,
    );

    when(
      () => repository.respondToNotification(
        notification: params.notification,
        action: params.action,
      ),
    ).thenAnswer((_) async => leftResult<Unit>('reject failed'));

    final result = await usecase(params);

    expect(result, const Left(ApiFailure(message: 'reject failed')));
    verify(
      () => repository.respondToNotification(
        notification: params.notification,
        action: params.action,
      ),
    ).called(1);
    verifyNoMoreInteractions(repository);
  });
}
