import 'package:hive/hive.dart';
import 'package:pairup/features/auth/domain/entities/auth_entity.dart';
import 'package:uuid/uuid.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: 1)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  String password;

  @HiveField(4)
  String? phoneNumber;

  @HiveField(5)
  int? age;

  @HiveField(6)
  String? gender;

  @HiveField(7)
  String? bio;

  @HiveField(8)
  String? interests; // stored as comma-separated

  @HiveField(9)
  String? photos; // stored as comma-separated

  @HiveField(10)
  String? location;

  AuthHiveModel({
    String? userId,
    required this.name,
    required this.email,
    required this.password,
    this.phoneNumber,
    this.age,
    this.gender,
    this.bio,
    this.interests,
    this.photos,
    this.location,
  }) : userId = userId ?? const Uuid().v4();

  // TO ENTITY

  AuthEntity toEntity() {
    return AuthEntity(
      userId: userId,
      name: name,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
      age: age,
      gender: gender,
      bio: bio,
      location: location,
      interests: interests?.split(',').where((e) => e.isNotEmpty).toList(),
      photos: photos?.split(',').where((e) => e.isNotEmpty).toList(),
    );
  }

  // FROM ENTITY
  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      userId: entity.userId,
      name: entity.name,
      email: entity.email,
      password: entity.password,
      phoneNumber: entity.phoneNumber,
      age: entity.age,
      gender: entity.gender,
      bio: entity.bio,
      location: entity.location,
      interests: entity.interests?.join(','),
      photos: entity.photos?.join(','),
    );
  }

  // LIST CONVERTER
  static List<AuthEntity> toEntityList(List<AuthHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }

  toJson() {}
}
