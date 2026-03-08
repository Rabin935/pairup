// Mapped to GetUserByIdUsecase because EnableNotificationsUsecase is not implemented yet.
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/features/user/domain/entities/user_entities.dart';
import 'package:pairup/features/user/domain/usecases/get_user_by_id_usecase.dart';

import '../test_helpers/mocks.dart';
import '../test_helpers/test_data.dart';

void main() {
  late MockUserRepository repository;
  late GetUserByIdUsecase usecase;

  setUpAll(registerCommonFallbackValues);

  setUp(() {
    repository = MockUserRepository();
    usecase = GetUserByIdUsecase(userRepository: repository);
  });

  test('returns user profile when lookup succeeds', () async {
    const params = GetUserByIdUsecaseParams(userId: 'user-1');

    when(
      () => repository.getUserbyId(params.userId),
    ).thenAnswer((_) async => rightResult(sampleUserEntity));

    final result = await usecase(params);

    expect(result, Right(sampleUserEntity));
    verify(() => repository.getUserbyId(params.userId)).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Failure when lookup fails', () async {
    const params = GetUserByIdUsecaseParams(userId: 'user-1');

    when(
      () => repository.getUserbyId(params.userId),
    ).thenAnswer((_) async => leftResult<UserEntity>('user not found'));

    final result = await usecase(params);

    expect(result, const Left(ApiFailure(message: 'user not found')));
    verify(() => repository.getUserbyId(params.userId)).called(1);
    verifyNoMoreInteractions(repository);
  });
}
