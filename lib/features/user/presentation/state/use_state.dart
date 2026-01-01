import 'package:equatable/equatable.dart';
import 'package:pairup/features/user/domain/entities/user_entities.dart';

enum UserStatus { initial, loading, loaded, created, updated, deleted, error }

class UserState extends Equatable {
  final UserStatus status;
  final List<UserEntity> users;
  final UserEntity? selectedUser;
  final String? errorMessage;

  const UserState({
    this.status = UserStatus.initial,
    this.users = const [],
    this.selectedUser,
    this.errorMessage,
  });

  UserState copyWith({
    UserStatus? status,
    List<UserEntity>? users,
    UserEntity? selectedUser,
    String? errorMessage,
  }) {
    return UserState(
      status: status ?? this.status,
      users: users ?? this.users,
      selectedUser: selectedUser ?? this.selectedUser,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, users, selectedUser, errorMessage];
}
