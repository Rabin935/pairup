import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/features/chat/domain/entities/chat_entities.dart';
import 'package:pairup/features/chat/domain/usecases/get_chat_overview_usecase.dart';

import '../test_helpers/mocks.dart';
import '../test_helpers/test_data.dart';

void main() {
  late MockChatRepository repository;
  late GetChatOverviewUsecase usecase;

  setUpAll(registerCommonFallbackValues);

  setUp(() {
    repository = MockChatRepository();
    usecase = GetChatOverviewUsecase(chatRepository: repository);
  });

  test('returns chat overview when matches fetch succeeds', () async {
    const params = GetChatOverviewUsecaseParams(currentUserId: 'user-1');

    when(
      () => repository.getChatOverview(currentUserId: params.currentUserId),
    ).thenAnswer((_) async => rightResult(sampleChatOverview));

    final result = await usecase(params);

    expect(result, Right(sampleChatOverview));
    verify(
      () => repository.getChatOverview(currentUserId: params.currentUserId),
    ).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Failure when matches fetch fails', () async {
    const params = GetChatOverviewUsecaseParams(currentUserId: 'user-1');

    when(
      () => repository.getChatOverview(currentUserId: params.currentUserId),
    ).thenAnswer((_) async => leftResult<ChatOverviewEntity>('fetch failed'));

    final result = await usecase(params);

    expect(result, const Left(ApiFailure(message: 'fetch failed')));
    verify(
      () => repository.getChatOverview(currentUserId: params.currentUserId),
    ).called(1);
    verifyNoMoreInteractions(repository);
  });
}
