import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/features/auth/domain/usecases/logout_usecase.dart';

import '../test_helpers/mocks.dart';

void main() {
  late MockAuthRepository repository;
  late LogoutUsecase usecase;

  setUpAll(registerCommonFallbackValues);

  setUp(() {
    repository = MockAuthRepository();
    usecase = LogoutUsecase(authRepository: repository);
  });

  test('returns true when repository logout succeeds', () async {
    when(() => repository.logout()).thenAnswer((_) async => rightResult(true));

    final result = await usecase();

    expect(result, const Right(true));
    verify(() => repository.logout()).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Failure when repository logout fails', () async {
    when(
      () => repository.logout(),
    ).thenAnswer((_) async => leftResult<bool>('logout failed'));

    final result = await usecase();

    expect(result, const Left(ApiFailure(message: 'logout failed')));
    verify(() => repository.logout()).called(1);
    verifyNoMoreInteractions(repository);
  });
}
