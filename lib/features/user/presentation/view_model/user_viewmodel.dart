import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/features/user/domain/usecases/create_user_usecase.dart';
import 'package:pairup/features/user/domain/usecases/delete_user_usecase.dart';
import 'package:pairup/features/user/domain/usecases/get_all_user_usecase.dart';
import 'package:pairup/features/user/domain/usecases/get_user_by_id_usecase.dart';
import 'package:pairup/features/user/domain/usecases/update_user_usecase.dart';
import 'package:pairup/features/user/presentation/state/use_state.dart';

final userViewmodelProvider = NotifierProvider<UserViewmodel, UserState>(
  UserViewmodel.new,
);

class UserViewmodel extends Notifier<UserState> {
  late final GetAllUserUsecase _getAllUserUsecase;
  late final CreateUserUsecase _createUserUsecase;
  late final UpdateUserUsecase _updateUserUsecase;
  late final DeleteUserUsecase _deleteUserUsecase;
  late final GetUserByIdUsecase _getUserByIdUsecase;

  @override
  UserState build() {
    _getAllUserUsecase = ref.read(getAllUserUsecaseProvider);
    _createUserUsecase = ref.read(createUserUsecaseProvider);
    _deleteUserUsecase = ref.read(deleteUserUsecaseProvider);
    _getUserByIdUsecase = ref.read(getUserByIdUsecaseProvider);

    return const UserState();
  }

  Future<void> getAllUsers() async {
    state = state.copyWith(status: UserStatus.loading);

    await Future.delayed(Duration(seconds: 2));

    final result = await _getAllUserUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: UserStatus.error,
        errorMessage: failure.message,
      ),
      (users) =>
          state = state.copyWith(status: UserStatus.loaded, users: users),
    );
  }

  Future<void> createUser(String userName) async {
    state = state.copyWith(status: UserStatus.loading);

    final result = await _createUserUsecase(
      CreateUserUsecaseParams(name: userName),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: UserStatus.error,
        errorMessage: failure.message,
      ),
      (success) {
        state = state.copyWith(status: UserStatus.created);
        getAllUsers();
      },
    );
  }

  Future<void> getUserById(String userId) async {
    state = state.copyWith(status: UserStatus.loading);

    final result = await _getUserByIdUsecase(
      GetUserByIdUsecaseParams(userId: userId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: UserStatus.error,
        errorMessage: failure.message,
      ),
      (user) => state = state.copyWith(status: UserStatus.loaded),
    );
  }

  Future<void> updateUser({
    required String userId,
    required String userName,
    String? status,
  }) async {
    state = state.copyWith(status: UserStatus.loading);

    final result = await _updateUserUsecase(
      UpdateUserUsecaseParams(userId: userId, name: userName),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: UserStatus.error,
        errorMessage: failure.message,
      ),
      (success) {
        state = state.copyWith(status: UserStatus.updated);
        getAllUsers();
      },
    );
  }

  Future<void> deleteUser(String userId) async {
    state = state.copyWith(status: UserStatus.loading);

    final result = await _deleteUserUsecase(
      DeleteUserUsecaseParams(userId: userId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: UserStatus.error,
        errorMessage: failure.message,
      ),
      (success) {
        state = state.copyWith(status: UserStatus.deleted);
        getAllUsers();
      },
    );
  }
}
