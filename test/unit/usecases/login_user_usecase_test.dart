import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/features/auth/domain/entities/auth_entity.dart';
import 'package:pairup/features/auth/domain/usecases/login_usecase.dart';

import '../test_helpers/mocks.dart';
import '../test_helpers/test_data.dart';

void main() {
  late MockAuthRepository repository;
  late LoginUsecase usecase;

  setUpAll(registerCommonFallbackValues);

  setUp(() {
    repository = MockAuthRepository();
    usecase = LoginUsecase(authRepository: repository);
  });

  test('returns AuthEntity when repository login succeeds', () async {
    const params = LoginUsecaseParams(
      email: 'alex@pairup.app',
      password: 'password123',
    );

    when(
      () => repository.login(params.email, params.password),
    ).thenAnswer((_) async => rightResult(sampleAuthEntity));

    final result = await usecase(params);

    expect(result, Right(sampleAuthEntity));
    verify(() => repository.login(params.email, params.password)).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Failure when repository login fails', () async {
    const params = LoginUsecaseParams(
      email: 'alex@pairup.app',
      password: 'wrong-password',
    );

    when(
      () => repository.login(params.email, params.password),
    ).thenAnswer((_) async => leftResult<AuthEntity>('invalid credentials'));

    final result = await usecase(params);

    expect(result, const Left(ApiFailure(message: 'invalid credentials')));
    verify(() => repository.login(params.email, params.password)).called(1);
    verifyNoMoreInteractions(repository);
  });
}
