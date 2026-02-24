import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/features/user/domain/entities/public_user_profile_entity.dart';
import 'package:pairup/features/user/domain/usecases/get_public_user_profile_usecase.dart';

import '../test_helpers/mocks.dart';
import '../test_helpers/test_data.dart';

void main() {
  late MockPublicUserProfileRepository repository;
  late GetPublicUserProfileUsecase usecase;

  setUpAll(registerCommonFallbackValues);

  setUp(() {
    repository = MockPublicUserProfileRepository();
    usecase = GetPublicUserProfileUsecase(repository: repository);
  });

  test('returns profile when fetch succeeds', () async {
    const params = GetPublicUserProfileUsecaseParams(userId: 'user-1');

    when(
      () => repository.getPublicUserProfile(
        params.userId,
        trackView: params.trackView,
      ),
    ).thenAnswer((_) async => rightResult(samplePublicProfile));

    final result = await usecase(params);

    expect(result, Right(samplePublicProfile));
    verify(
      () => repository.getPublicUserProfile(
        params.userId,
        trackView: params.trackView,
      ),
    ).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Failure when profile fetch fails', () async {
    const params = GetPublicUserProfileUsecaseParams(userId: 'user-1');

    when(
      () => repository.getPublicUserProfile(
        params.userId,
        trackView: params.trackView,
      ),
    ).thenAnswer((_) async => leftResult<PublicUserProfileEntity>('not found'));

    final result = await usecase(params);

    expect(result, const Left(ApiFailure(message: 'not found')));
    verify(
      () => repository.getPublicUserProfile(
        params.userId,
        trackView: params.trackView,
      ),
    ).called(1);
    verifyNoMoreInteractions(repository);
  });
}
