import 'package:pairup/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String name;
  final String email;
  final String? password;

  // Optional profile fields
  final int? age;
  final String? gender;
  final String? phoneNumber;
  final String? bio;
  final List<String>? interests;
  final List<String>? photos;
  final String? location;

  // Auth-related
  final String? authProvider;
  final String? role;

  AuthApiModel({
    this.id,
    required this.name,
    required this.email,
    this.password,
    this.age,
    this.gender,
    this.phoneNumber,
    this.bio,
    this.interests,
    this.photos,
    this.location,
    this.authProvider,
    this.role,
  });

  // -------------------- TO JSON --------------------
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "password": password,
      "age": age,
      "gender": gender,
      "phoneNumber": phoneNumber,
      "bio": bio,
      "interests": interests,
      "photos": photos,
      "location": location,
      "authProvider": authProvider,
      "role": role,
    };
  }

  // -------------------- FROM JSON --------------------
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json['_id'] as String?,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      bio: json['bio'] as String?,
      interests: (json['interests'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      photos: (json['photos'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      location: json['location'] as String?,
      authProvider: json['authProvider'] as String?,
      role: json['role'] as String?,
    );
  }

  // -------------------- TO ENTITY --------------------
  AuthEntity toEntity() {
    return AuthEntity(
      userId: id,
      name: name,
      email: email,
      password: password ?? '',
      age: age,
      gender: gender,
      phoneNumber: phoneNumber,
      bio: bio,
      interests: interests,
      photos: photos,
      location: location,
      authProvider: authProvider,
      role: role,
    );
  }

  // -------------------- FROM ENTITY --------------------
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      id: entity.userId,
      name: entity.name,
      email: entity.email,
      password: entity.password,
      age: entity.age,
      gender: entity.gender,
      phoneNumber: entity.phoneNumber,
      bio: entity.bio,
      interests: entity.interests,
      photos: entity.photos,
      location: entity.location,
      authProvider: entity.authProvider,
      role: entity.role,
    );
  }
}
