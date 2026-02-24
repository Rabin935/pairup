import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/features/user/domain/entities/user_entities.dart';
import 'package:pairup/features/user/domain/usecases/update_user_usecase.dart';

import '../test_helpers/mocks.dart';

void main() {
  late MockUserRepository repository;
  late UpdateUserUsecase usecase;

  setUpAll(registerCommonFallbackValues);

  setUp(() {
    repository = MockUserRepository();
    usecase = UpdateUserUsecase(userRepository: repository);
  });

  test('returns true when update succeeds', () async {
    const params = UpdateUserUsecaseParams(userId: 'user-1', name: 'Alex');

    when(
      () => repository.updateUser(any<UserEntity>()),
    ).thenAnswer((_) async => rightResult(true));

    final result = await usecase(params);

    expect(result, const Right(true));
    verify(() => repository.updateUser(any<UserEntity>())).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Failure when update fails', () async {
    const params = UpdateUserUsecaseParams(userId: 'user-1', name: 'Alex');

    when(
      () => repository.updateUser(any<UserEntity>()),
    ).thenAnswer((_) async => leftResult<bool>('update failed'));

    final result = await usecase(params);

    expect(result, const Left(ApiFailure(message: 'update failed')));
    verify(() => repository.updateUser(any<UserEntity>())).called(1);
    verifyNoMoreInteractions(repository);
  });
}
