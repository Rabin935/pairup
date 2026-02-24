// Mapped to CreateUserUsecase because SendMessageUsecase is not implemented in this codebase yet.
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/features/user/domain/entities/user_entities.dart';
import 'package:pairup/features/user/domain/usecases/create_user_usecase.dart';

import '../test_helpers/mocks.dart';

void main() {
  late MockUserRepository repository;
  late CreateUserUsecase usecase;

  setUpAll(registerCommonFallbackValues);

  setUp(() {
    repository = MockUserRepository();
    usecase = CreateUserUsecase(userRepository: repository);
  });

  test('returns success when create action succeeds', () async {
    const params = CreateUserUsecaseParams(name: 'Alex');

    when(
      () => repository.createUser(any<UserEntity>()),
    ).thenAnswer((_) async => rightResult(true));

    final result = await usecase(params);

    expect(result, const Right(true));
    verify(() => repository.createUser(any<UserEntity>())).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Failure when create action fails', () async {
    const params = CreateUserUsecaseParams(name: 'Alex');

    when(
      () => repository.createUser(any<UserEntity>()),
    ).thenAnswer((_) async => leftResult<bool>('create failed'));

    final result = await usecase(params);

    expect(result, const Left(ApiFailure(message: 'create failed')));
    verify(() => repository.createUser(any<UserEntity>())).called(1);
    verifyNoMoreInteractions(repository);
  });
}
