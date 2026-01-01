import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String? userId;
  final String name;
  final String email;
  final int age;
  final String gender;
  final String bio;
  final List<String> interests;
  final List<String> photos;
  final String location;

  const UserEntity({
    this.userId,
    required this.name,
    required this.email,
    required this.age,
    required this.gender,
    required this.bio,
    required this.interests,
    required this.photos,
    required this.location,
  });

  @override
  List<Object?> get props => [
    userId,
    name,
    email,
    age,
    gender,
    bio,
    interests,
    photos,
    location,
  ];
}
