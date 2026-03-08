import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/features/user/domain/entities/upload_user_images_result_entity.dart';
import 'package:pairup/features/user/domain/usecases/upload_user_images_usecase.dart';

import '../test_helpers/mocks.dart';
import '../test_helpers/test_data.dart';

void main() {
  late MockUserMediaRepository repository;
  late UploadUserImagesUsecase usecase;

  setUpAll(registerCommonFallbackValues);

  setUp(() {
    repository = MockUserMediaRepository();
    usecase = UploadUserImagesUsecase(repository: repository);
  });

  test('returns uploaded urls when upload succeeds', () async {
    const params = UploadUserImagesUsecaseParams(
      imageFilePaths: <String>['a.jpg', 'b.jpg'],
    );

    when(
      () => repository.uploadUserImages(params.imageFilePaths),
    ).thenAnswer((_) async => rightResult(sampleUploadResult));

    final result = await usecase(params);

    expect(result, Right(sampleUploadResult));
    verify(() => repository.uploadUserImages(params.imageFilePaths)).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns Failure when upload fails', () async {
    const params = UploadUserImagesUsecaseParams(
      imageFilePaths: <String>['a.jpg', 'b.jpg'],
    );

    when(
      () => repository.uploadUserImages(params.imageFilePaths),
    ).thenAnswer(
      (_) async => leftResult<UploadUserImagesResultEntity>('upload failed'),
    );

    final result = await usecase(params);

    expect(result, const Left(ApiFailure(message: 'upload failed')));
    verify(() => repository.uploadUserImages(params.imageFilePaths)).called(1);
    verifyNoMoreInteractions(repository);
  });
}
