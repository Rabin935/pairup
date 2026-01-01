import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/core/usecases/app_usecase.dart';
import 'package:pairup/features/user/data/repositories/user_repository.dart';
import 'package:pairup/features/user/domain/entities/user_entities.dart';
import 'package:pairup/features/user/domain/repositories/user_repository.dart';

class UpdateUserUsecaseParams extends Equatable {
  final String userId;
  final String? name;
  final String? email;
  final int? age;
  final String? gender;
  final String? bio;
  final List<String>? interests;
  final List<String>? photos;
  final String? location;

  const UpdateUserUsecaseParams({
    required this.userId,
    this.name,
    this.email,
    this.age,
    this.gender,
    this.bio,
    this.interests,
    this.photos,
    this.location,
  });

  @override
  List<Object?> get props => [
    userId,
    interests,
    photos,
    name,
    email,
    age,
    gender,
    bio,
    location,
  ];
}

final updateUserUsecaseProvider = Provider<UpdateUserUsecase>((ref) {
  final userRepository = ref.read(userRepositoryProvider);
  return UpdateUserUsecase(userRepository: userRepository);
});

class UpdateUserUsecase
    implements UsecaseWithParams<bool, UpdateUserUsecaseParams> {
  final IUserRepository _userRepository;

  UpdateUserUsecase({required IUserRepository userRepository})
    : _userRepository = userRepository;

  @override
  Future<Either<Failure, bool>> call(UpdateUserUsecaseParams params) {
    UserEntity userEntity = UserEntity(
      name: '',
      email: '',
      age: 0,
      gender: '',
      bio: '',
      interests: [],
      photos: [],
      location: '',
    );

    return _userRepository.updateUser(userEntity);
  }
}
