// Mapped to GetNotificationsUsecase because GetMessagesUsecase is not implemented yet.
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/features/notification/domain/entities/notification_entities.dart';
import 'package:pairup/features/notification/domain/usecases/get_notifications_usecase.dart';

import '../test_helpers/mocks.dart';
import '../test_helpers/test_data.dart';

void main() {
  late MockNotificationRepository repository;
  late GetNotificationsUsecase usecase;

  setUpAll(registerCommonFallbackValues);

  setUp(() {
    repository = MockNotificationRepository();
    usecase = GetNotificationsUsecase(notificationRepository: repository);
  });

  test('returns notifications when fetch succeeds', () async {
    when(
      () => repository.getNotifications(),
    ).thenAnswer((_) async => rightResult(<NotificationItemEntity>[sampleNotification]));

    final result = await usecase();

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('Expected Right but got Left'),
      (items) => expect(items, <NotificationItemEntity>[sampleNotification]),
    );
    verify(() => repository.getNotifications()).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Failure when notifications fetch fails', () async {
    when(
      () => repository.getNotifications(),
    ).thenAnswer((_) async => leftResult<List<NotificationItemEntity>>('fetch failed'));

    final result = await usecase();

    expect(result, const Left(ApiFailure(message: 'fetch failed')));
    verify(() => repository.getNotifications()).called(1);
    verifyNoMoreInteractions(repository);
  });
}
