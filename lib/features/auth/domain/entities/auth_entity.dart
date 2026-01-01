import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? userId;
  final String name;
  final String email;
  final String password;
  final int age;
  final String gender;
  final String phoneNumber;
  final String bio;
  final List<String> interests;
  final List<String> photos;
  final String location;

  const AuthEntity({
    this.userId,
    required this.name,
    required this.email,
    required this.password,
    required this.age,
    required this.gender,
    required this.phoneNumber,
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
    password,
    
    age,
    gender,
    bio,
    interests,
    photos,
    location,
    phoneNumber,
  ];
}
