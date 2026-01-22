import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? userId;
  final String firstname;
  final String lastname;
  final String email;
  final String password;

  // Optional profile fields (filled later)
  final int? age;
  final String? gender;
  final String? number;
  final String? bio;
  final List<String>? interests;
  final List<String>? photos;
  final String? location;

  // Auth-related
  final String? authProvider;
  final String? role;

  const AuthEntity({
    this.userId,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.password,
    this.age,
    this.gender,
    this.number,
    this.bio,
    this.interests,
    this.photos,
    this.location,
    this.authProvider,
    this.role,
  });

  @override
  List<Object?> get props => [
        userId,
        firstname,
        lastname,
        email,
        password,
        age,
        gender,
        number,
        bio,
        interests,
        photos,
        location,
        authProvider,
        role,
      ];
}
