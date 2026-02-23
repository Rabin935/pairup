import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/features/auth/domain/entities/auth_entity.dart';
import 'package:pairup/features/auth/domain/usecases/register_usecase.dart';

import '../test_helpers/mocks.dart';

void main() {
  late MockAuthRepository repository;
  late RegisterUsecase usecase;

  setUpAll(registerCommonFallbackValues);

  setUp(() {
    repository = MockAuthRepository();
    usecase = RegisterUsecase(authRepository: repository);
  });

  test('returns true when repository register succeeds', () async {
    const params = RegisterUsecaseParams(
      firstname: 'Alex',
      lastname: 'Ray',
      email: 'alex@pairup.app',
      password: 'password123',
      age: 25,
      gender: 'male',
      phoneNumber: '+15550000000',
    );

    when(
      () => repository.register(any<AuthEntity>()),
    ).thenAnswer((_) async => rightResult(true));

    final result = await usecase(params);

    expect(result, const Right(true));
    verify(() => repository.register(any<AuthEntity>())).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Failure when repository register fails', () async {
    const params = RegisterUsecaseParams(
      firstname: 'Alex',
      lastname: 'Ray',
      email: 'alex@pairup.app',
      password: 'password123',
      age: 25,
      gender: 'male',
      phoneNumber: '+15550000000',
    );

    when(
      () => repository.register(any<AuthEntity>()),
    ).thenAnswer((_) async => leftResult<bool>('email already exists'));

    final result = await usecase(params);

    expect(result, const Left(ApiFailure(message: 'email already exists')));
    verify(() => repository.register(any<AuthEntity>())).called(1);
    verifyNoMoreInteractions(repository);
  });
}
