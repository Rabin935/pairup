import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/error/failures.dart';
import 'package:pairup/core/usecases/app_usecase.dart';
import 'package:pairup/features/auth/data/repositories/auth_repository.dart';
import 'package:pairup/features/auth/domain/entities/auth_entity.dart';
import 'package:pairup/features/auth/domain/repositories/auth_repository.dart';

class RegisterUsecaseParams extends Equatable {
  final String? userId;
  final String name;
  final String email;
  final String? password;
  final int age;
  final String gender;
  final String phoneNumber;
  // final String bio;
  // final List<String> interests;
  // final List<String> photos;
  // final String location;

  const RegisterUsecaseParams({
    this.userId,
    required this.name,
    required this.email,
    this.password,
    required this.age,
    required this.gender,
    required this.phoneNumber,
    // required this.bio,
    // required this.interests,
    // required this.photos,
    // required this.location,
  });

  @override
  List<Object?> get props => [name, email, age, phoneNumber, gender, password];
}

final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return RegisterUsecase(authRepository: authRepository);
});

class RegisterUsecase
    implements UsecaseWithParams<bool, RegisterUsecaseParams> {
  final IAuthRepository _authRepository;

  RegisterUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) {
    print(
      'RegisterUsecase called with: name=${params.name}, email=${params.email}, password=${params.password}, phoneNumber=${params.phoneNumber}',
    );
    final authEntity = AuthEntity(
      name: params.name,
      email: params.email,
      password: params.password ?? '',
      phoneNumber: params.phoneNumber,
      gender: params.gender,
      age: params.age,
      bio: '',
      interests: [],
      photos: [],
      location: '',
    );
    print('RegisterUsecase authEntity: password=${authEntity.password}');

    return _authRepository.register(authEntity);
  }
}
