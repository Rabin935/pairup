import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/features/user/domain/entities/user_entities.dart';
import 'package:pairup/features/user/domain/usecases/get_all_user_usecase.dart';

import '../test_helpers/mocks.dart';
import '../test_helpers/test_data.dart';

void main() {
  late MockUserRepository repository;
  late GetAllUserUsecase usecase;

  setUpAll(registerCommonFallbackValues);

  setUp(() {
    repository = MockUserRepository();
    usecase = GetAllUserUsecase(userRepository: repository);
  });

  test('returns users when repository fetch succeeds', () async {
    when(
      () => repository.getAllUser(),
    ).thenAnswer((_) async => rightResult(<UserEntity>[sampleUserEntity]));

    final result = await usecase();

    expect(result.isRight(), isTrue);
    result.fold(
      (_) => fail('Expected Right but got Left'),
      (users) => expect(users, <UserEntity>[sampleUserEntity]),
    );
    verify(() => repository.getAllUser()).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Failure when repository fetch fails', () async {
    when(
      () => repository.getAllUser(),
    ).thenAnswer((_) async => leftResult<List<UserEntity>>('unable to load'));

    final result = await usecase();

    expect(result, const Left(ApiFailure(message: 'unable to load')));
    verify(() => repository.getAllUser()).called(1);
    verifyNoMoreInteractions(repository);
  });
}
