import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/features/user/domain/usecases/delete_user_usecase.dart';

import '../test_helpers/mocks.dart';

void main() {
  late MockUserRepository repository;
  late DeleteUserUsecase usecase;

  setUpAll(registerCommonFallbackValues);

  setUp(() {
    repository = MockUserRepository();
    usecase = DeleteUserUsecase(userRepository: repository);
  });

  test('returns true when swipe-left action succeeds', () async {
    const params = DeleteUserUsecaseParams(userId: 'user-2');

    when(
      () => repository.deleteUser(params.userId),
    ).thenAnswer((_) async => rightResult(true));

    final result = await usecase(params);

    expect(result, const Right(true));
    verify(() => repository.deleteUser(params.userId)).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Failure when swipe-left action fails', () async {
    const params = DeleteUserUsecaseParams(userId: 'user-2');

    when(
      () => repository.deleteUser(params.userId),
    ).thenAnswer((_) async => leftResult<bool>('action failed'));

    final result = await usecase(params);

    expect(result, const Left(ApiFailure(message: 'action failed')));
    verify(() => repository.deleteUser(params.userId)).called(1);
    verifyNoMoreInteractions(repository);
  });
}
