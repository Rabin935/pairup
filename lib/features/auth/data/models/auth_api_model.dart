import 'package:pairup/features/auth/domain/entities/auth_entity.dart';
import 'package:uuid/uuid.dart';

class AuthApiModel {
  final String? id;
  final String firstname;
  final String lastname;
  final String email;
  final String? password;
  final String? confirmPassword;

  // Optional profile fields
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

  AuthApiModel({
    this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    this.password,
    this.confirmPassword,
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

  // -------------------- TO JSON --------------------
  Map<String, dynamic> toJson() {
    return {
      "firstname": firstname,
      "lastname": lastname,
      "email": email,
      "password": password,
      "confirmPassword": password,
      "number": number,
      "authProvider": "local",
      "uid": const Uuid().v4(), // to auto generate id
      "age": age,
      "gender": gender,
      "bio": bio,
      "interests": interests,
      "photos": photos,
      "location": location,
      "role": role,
    };
  }

  // -------------------- FROM JSON --------------------
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json['_id'] as String?,
      firstname: json['firstname'] ?? json['firstname'] as String,
      lastname: json['firstname'] ?? json['firstname'] as String,
      email: json['email'] as String,
      number: json['number'] as String?, // Updated to match key 'number'
      password: json['password'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
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
      firstname: firstname,
      lastname: lastname,
      email: email,
      password: password ?? '',
      age: age,
      gender: gender,
      number: number,
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
      firstname: entity.firstname,
      lastname: entity.lastname,
      email: entity.email,
      password: entity.password,
      confirmPassword: entity.password, // Set confirmPassword from entity
      age: entity.age,
      gender: entity.gender,
      number: entity.number,
      bio: entity.bio,
      interests: entity.interests,
      photos: entity.photos,
      location: entity.location,
      authProvider: entity.authProvider,
      role: entity.role,
    );
  }
}
