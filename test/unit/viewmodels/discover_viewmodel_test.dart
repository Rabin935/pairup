import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pairup/features/user/domain/usecases/create_user_usecase.dart';
import 'package:pairup/features/user/domain/usecases/delete_user_usecase.dart';
import 'package:pairup/features/user/domain/usecases/get_all_user_usecase.dart';
import 'package:pairup/features/user/domain/usecases/get_user_by_id_usecase.dart';
import 'package:pairup/features/user/domain/usecases/update_user_usecase.dart';
import 'package:pairup/features/user/presentation/state/use_state.dart';
import 'package:pairup/features/user/presentation/view_model/user_viewmodel.dart';

import '../test_helpers/mocks.dart';
import '../test_helpers/test_data.dart';

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

  test('DiscoverViewModel load users handles loading, success, and error states', () async {
    when(() => getAllUsecase()).thenAnswer((_) async => rightResult([sampleUserEntity]));

    final notifier = container.read(userViewmodelProvider.notifier);

    final successFuture = notifier.getAllUsers();
    expect(container.read(userViewmodelProvider).status, UserStatus.loading);

    await successFuture;
    expect(container.read(userViewmodelProvider).status, UserStatus.loaded);

    when(() => getAllUsecase()).thenAnswer((_) async => leftResult('unable to fetch users'));

    final errorFuture = notifier.getAllUsers();
    expect(container.read(userViewmodelProvider).status, UserStatus.loading);

    await errorFuture;
    expect(container.read(userViewmodelProvider).status, UserStatus.error);
  });

  test('DiscoverViewModel swipe right handles loading, success, and error states', () async {
    when(() => createUsecase(any<CreateUserUsecaseParams>()))
        .thenAnswer((_) async => rightResult(null));
    when(() => getAllUsecase()).thenAnswer((_) async => rightResult([sampleUserEntity]));

    final notifier = container.read(userViewmodelProvider.notifier);
    final states = <UserStatus>[];
    container.listen<UserState>(
      userViewmodelProvider,
      (_, next) => states.add(next.status),
      fireImmediately: true,
    );

    final successFuture = notifier.createUser('Alex');
    expect(container.read(userViewmodelProvider).status, UserStatus.loading);

    await successFuture;
    expect(states.contains(UserStatus.created), isTrue);

    when(() => createUsecase(any<CreateUserUsecaseParams>()))
        .thenAnswer((_) async => leftResult('swipe-right failed'));

    final errorFuture = notifier.createUser('Alex');
    expect(container.read(userViewmodelProvider).status, UserStatus.loading);

    await errorFuture;
    expect(container.read(userViewmodelProvider).status, UserStatus.error);
  });

  test('DiscoverViewModel swipe left handles loading, success, and error states', () async {
    when(() => deleteUsecase(any<DeleteUserUsecaseParams>()))
        .thenAnswer((_) async => rightResult(true));
    when(() => getAllUsecase()).thenAnswer((_) async => rightResult([sampleUserEntity]));

    final notifier = container.read(userViewmodelProvider.notifier);
    final states = <UserStatus>[];
    container.listen<UserState>(
      userViewmodelProvider,
      (_, next) => states.add(next.status),
      fireImmediately: true,
    );

    final successFuture = notifier.deleteUser('user-2');
    expect(container.read(userViewmodelProvider).status, UserStatus.loading);

    await successFuture;
    expect(states.contains(UserStatus.deleted), isTrue);

    when(() => deleteUsecase(any<DeleteUserUsecaseParams>()))
        .thenAnswer((_) async => leftResult('swipe-left failed'));

    final errorFuture = notifier.deleteUser('user-2');
    expect(container.read(userViewmodelProvider).status, UserStatus.loading);

    await errorFuture;
    expect(container.read(userViewmodelProvider).status, UserStatus.error);
  });
}
