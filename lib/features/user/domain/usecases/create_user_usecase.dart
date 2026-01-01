import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/core/usecases/app_usecase.dart';
import 'package:pairup/features/user/data/repositories/user_repository.dart';
import 'package:pairup/features/user/domain/entities/user_entities.dart';
import 'package:pairup/features/user/domain/repositories/user_repository.dart';

class CreateUserUsecaseParams extends Equatable {
  final String name;

  const CreateUserUsecaseParams({required this.name});

  @override
  List<Object?> get props => [name];
}

final createUserUsecaseProvider = Provider<CreateUserUsecase>((ref) {
  final userRepository = ref.read(userRepositoryProvider);
  return CreateUserUsecase(userRepository: userRepository);
});

class CreateUserUsecase
    implements UsecaseWithParams<void, CreateUserUsecaseParams> {
  final IUserRepository _userRepository;

  CreateUserUsecase({required IUserRepository userRepository})
    : _userRepository = userRepository;

  @override
  Future<Either<Failure, void>> call(CreateUserUsecaseParams params) {
    UserEntity userEntity = UserEntity(
      name: params.name.toLowerCase(),
      email: '',
      age: 0,
      gender: '',
      bio: '',
      interests: [],
      photos: [],
      location: '',
    );

    return _userRepository.createUser(userEntity);
  }
}
