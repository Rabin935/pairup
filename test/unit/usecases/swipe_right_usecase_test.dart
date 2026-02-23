import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/features/user/domain/entities/user_image_like_result_entity.dart';
import 'package:pairup/features/user/domain/usecases/toggle_user_image_like_usecase.dart';

import '../test_helpers/mocks.dart';
import '../test_helpers/test_data.dart';

void main() {
  late MockUserMediaRepository repository;
  late ToggleUserImageLikeUsecase usecase;

  setUpAll(registerCommonFallbackValues);

  setUp(() {
    repository = MockUserMediaRepository();
    usecase = ToggleUserImageLikeUsecase(repository: repository);
  });

  test('returns like result when swipe-right action succeeds', () async {
    const params = ToggleUserImageLikeUsecaseParams(
      userId: 'user-1',
      imageId: 'img-1',
    );

    when(
      () => repository.toggleUserImageLike(
        userId: params.userId,
        imageId: params.imageId,
      ),
    ).thenAnswer((_) async => rightResult(sampleImageLikeResult));

    final result = await usecase(params);

    expect(result, Right(sampleImageLikeResult));
    verify(
      () => repository.toggleUserImageLike(
        userId: params.userId,
        imageId: params.imageId,
      ),
    ).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Failure when swipe-right action fails', () async {
    const params = ToggleUserImageLikeUsecaseParams(
      userId: 'user-1',
      imageId: 'img-1',
    );

    when(
      () => repository.toggleUserImageLike(
        userId: params.userId,
        imageId: params.imageId,
      ),
    ).thenAnswer(
      (_) async => leftResult<UserImageLikeResultEntity>('action failed'),
    );

    final result = await usecase(params);

    expect(result, const Left(ApiFailure(message: 'action failed')));
    verify(
      () => repository.toggleUserImageLike(
        userId: params.userId,
        imageId: params.imageId,
      ),
    ).called(1);
    verifyNoMoreInteractions(repository);
  });
}
