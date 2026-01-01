import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/core/usecases/app_usecase.dart';
import 'package:pairup/features/user/data/repositories/user_repository.dart';
import 'package:pairup/features/user/domain/entities/user_entities.dart';
import 'package:pairup/features/user/domain/repositories/user_repository.dart';
import 'package:pairup/features/user/domain/usecases/get_all_user_usecase.dart';

class GetUserByIdUsecaseParams extends Equatable {
  final String userId;

  const GetUserByIdUsecaseParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

final GetUserByIdUsecaseProvider = Provider<GetAllUserUsecase>((ref) {
  final userRepository = ref.read(userRepositoryProvider);
  return GetAllUserUsecase(userRepository: userRepository);
});

class GetUserByIdUsecase
    implements UsecaseWithParams<UserEntity, GetUserByIdUsecaseParams> {
  final IUserRepository _userRepository;

  GetUserByIdUsecase({required IUserRepository userRepository})
    : _userRepository = userRepository;

  @override
  Future<Either<Failure, UserEntity>> call(GetUserByIdUsecaseParams params) {
    return _userRepository.getUserbyId(params.userId);
  }
}
