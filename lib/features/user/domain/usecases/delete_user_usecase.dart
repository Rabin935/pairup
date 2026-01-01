import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/core/usecases/app_usecase.dart';
import 'package:pairup/features/user/data/repositories/user_repository.dart';
import 'package:pairup/features/user/domain/repositories/user_repository.dart';

class DeleteUserUsecaseParams extends Equatable {
  final String userId;

  const DeleteUserUsecaseParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

final deleteUserUsecaseProvider = Provider<DeleteUserUsecase>((ref) {
  final userRepository = ref.read(userRepositoryProvider);
  return DeleteUserUsecase(userRepository: userRepository);
});

class DeleteUserUsecase
    implements UsecaseWithParams<bool, DeleteUserUsecaseParams> {
  final IUserRepository _userRepository;

  DeleteUserUsecase({required IUserRepository userRepository})
    : _userRepository = userRepository;

  @override
  Future<Either<Failure, bool>> call(DeleteUserUsecaseParams params) {
    return _userRepository.deleteUser(params.userId);
  }
}
