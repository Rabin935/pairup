import 'package:either_dart/either.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/core/usecases/app_usecase.dart';
import 'package:pairup/features/user/data/repositories/user_repository.dart';
import 'package:pairup/features/user/domain/entities/user_entities.dart';
import 'package:pairup/features/user/domain/repositories/user_repository.dart';

final getAllUserUsecaseProvider = Provider<GetAllUserUsecase>((ref) {
  final userRepository = ref.read(userRepositoryProvider);
  return GetAllUserUsecase(userRepository: userRepository);
});

class GetAllUserUsecase implements UsecaseWithoutParams<List<UserEntity>> {
  final IUserRepository _userRepository;

  GetAllUserUsecase({required IUserRepository userRepository})
    : _userRepository = userRepository;

  @override
  Future<Either<Failure, List<UserEntity>>> call() {
    return _userRepository.getAllUser();
  }
}
