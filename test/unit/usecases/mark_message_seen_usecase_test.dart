// Mapped to GetCurrentUserUsecase because MarkMessageSeenUsecase is not implemented yet.
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/features/auth/domain/entities/auth_entity.dart';
import 'package:pairup/features/auth/domain/usecases/get_current_user_usecase.dart';

import '../test_helpers/mocks.dart';
import '../test_helpers/test_data.dart';

void main() {
  late MockAuthRepository repository;
  late GetCurrentUserUsecase usecase;

  setUpAll(registerCommonFallbackValues);

  setUp(() {
    repository = MockAuthRepository();
    usecase = GetCurrentUserUsecase(authRepository: repository);
  });

  test('returns current user when session lookup succeeds', () async {
    when(
      () => repository.getCurrentUser(),
    ).thenAnswer((_) async => rightResult(sampleAuthEntity));

    final result = await usecase();

    expect(result, Right(sampleAuthEntity));
    verify(() => repository.getCurrentUser()).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Failure when session lookup fails', () async {
    when(
      () => repository.getCurrentUser(),
    ).thenAnswer((_) async => leftResult<AuthEntity>('session missing'));

    final result = await usecase();

    expect(result, const Left(ApiFailure(message: 'session missing')));
    verify(() => repository.getCurrentUser()).called(1);
    verifyNoMoreInteractions(repository);
  });
}
