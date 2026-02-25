import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pairup/features/user/domain/usecases/create_user_usecase.dart';
import 'package:pairup/features/user/domain/usecases/delete_user_usecase.dart';
import 'package:pairup/features/user/domain/usecases/get_all_user_usecase.dart';
import 'package:pairup/features/user/domain/usecases/get_user_by_id_usecase.dart';
import 'package:pairup/features/user/domain/usecases/update_user_usecase.dart';
import 'package:pairup/features/user/domain/usecases/upload_user_images_usecase.dart';
import 'package:pairup/features/user/presentation/state/use_state.dart';
import 'package:pairup/features/user/presentation/view_model/user_viewmodel.dart';

import '../test_helpers/mocks.dart';
import '../test_helpers/test_data.dart';

enum ProfileUploadStatus { initial, loading, success, error }

class ProfileUploadState {
  final ProfileUploadStatus status;
  final String? error;

  const ProfileUploadState({this.status = ProfileUploadStatus.initial, this.error});

  ProfileUploadState copyWith({ProfileUploadStatus? status, String? error}) {
    return ProfileUploadState(status: status ?? this.status, error: error);
  }
}

class ProfileUploadViewModel {
  final UploadUserImagesUsecase _uploadUsecase;
  ProfileUploadState state = const ProfileUploadState();

  ProfileUploadViewModel(this._uploadUsecase);

  Future<void> uploadImage(List<String> paths) async {
    state = state.copyWith(status: ProfileUploadStatus.loading, error: null);

    final result = await _uploadUsecase(
      UploadUserImagesUsecaseParams(imageFilePaths: paths),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: ProfileUploadStatus.error,
        error: failure.message,
      ),
      (_) => state = state.copyWith(status: ProfileUploadStatus.success),
    );
  }
}

void main() {
  late MockGetAllUserUsecase getAllUsecase;
  late MockCreateUserUsecase createUsecase;
  late MockUpdateUserUsecase updateUsecase;
  late MockDeleteUserUsecase deleteUsecase;
  late MockGetUserByIdUsecase getByIdUsecase;
  late ProviderContainer container;

  setUpAll(registerCommonFallbackValues);

  setUp(() {
    getAllUsecase = MockGetAllUserUsecase();
    createUsecase = MockCreateUserUsecase();
    updateUsecase = MockUpdateUserUsecase();
    deleteUsecase = MockDeleteUserUsecase();
    getByIdUsecase = MockGetUserByIdUsecase();

    container = ProviderContainer(
      overrides: [
        getAllUserUsecaseProvider.overrideWith((ref) => getAllUsecase),
        createUserUsecaseProvider.overrideWith((ref) => createUsecase),
        updateUserUsecaseProvider.overrideWith((ref) => updateUsecase),
        deleteUserUsecaseProvider.overrideWith((ref) => deleteUsecase),
        getUserByIdUsecaseProvider.overrideWith((ref) => getByIdUsecase),
      ],
    );

    addTearDown(container.dispose);
  });

  test('ProfileViewModel load profile handles loading, success, and error states', () async {
    when(() => getByIdUsecase(any<GetUserByIdUsecaseParams>()))
        .thenAnswer((_) async => rightResult(sampleUserEntity));

    final notifier = container.read(userViewmodelProvider.notifier);

    final successFuture = notifier.getUserById('user-1');
    expect(container.read(userViewmodelProvider).status, UserStatus.loading);

    await successFuture;
    expect(container.read(userViewmodelProvider).status, UserStatus.loaded);

    when(() => getByIdUsecase(any<GetUserByIdUsecaseParams>()))
        .thenAnswer((_) async => leftResult('profile load failed'));

    final errorFuture = notifier.getUserById('user-1');
    expect(container.read(userViewmodelProvider).status, UserStatus.loading);

    await errorFuture;
    final errorState = container.read(userViewmodelProvider);
    expect(errorState.status, UserStatus.error);
    expect(errorState.errorMessage, 'profile load failed');
  });

  test('ProfileViewModel update profile handles loading, success, and error states', () async {
    when(() => updateUsecase(any<UpdateUserUsecaseParams>()))
        .thenAnswer((_) async => rightResult(true));
    when(() => getAllUsecase()).thenAnswer((_) async => rightResult([sampleUserEntity]));

    final notifier = container.read(userViewmodelProvider.notifier);
    final states = <UserStatus>[];
    container.listen<UserState>(
      userViewmodelProvider,
      (_, next) => states.add(next.status),
      fireImmediately: true,
    );

    final successFuture = notifier.updateUser(userId: 'user-1', userName: 'Alex');
    expect(container.read(userViewmodelProvider).status, UserStatus.loading);

    await successFuture;
    expect(states.contains(UserStatus.updated), isTrue);

    when(() => updateUsecase(any<UpdateUserUsecaseParams>()))
        .thenAnswer((_) async => leftResult('update failed'));

    final errorFuture = notifier.updateUser(userId: 'user-1', userName: 'Alex');
    expect(container.read(userViewmodelProvider).status, UserStatus.loading);

    await errorFuture;
    expect(container.read(userViewmodelProvider).status, UserStatus.error);
  });

  test('ProfileViewModel upload image handles loading, success, and error states', () async {
    final uploadUsecase = MockUploadUserImagesUsecase();
    final viewModel = ProfileUploadViewModel(uploadUsecase);

    when(() => uploadUsecase(any<UploadUserImagesUsecaseParams>()))
        .thenAnswer((_) async => rightResult(sampleUploadResult));

    final successFuture = viewModel.uploadImage(['a.jpg']);
    expect(viewModel.state.status, ProfileUploadStatus.loading);

    await successFuture;
    expect(viewModel.state.status, ProfileUploadStatus.success);

    when(() => uploadUsecase(any<UploadUserImagesUsecaseParams>()))
        .thenAnswer((_) async => leftResult('upload failed'));

    final errorFuture = viewModel.uploadImage(['a.jpg']);
    expect(viewModel.state.status, ProfileUploadStatus.loading);

    await errorFuture;
    expect(viewModel.state.status, ProfileUploadStatus.error);
    expect(viewModel.state.error, 'upload failed');
  });
}
