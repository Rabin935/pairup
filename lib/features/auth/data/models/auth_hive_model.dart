import 'package:hive/hive.dart';
import 'package:pairup/features/auth/domain/entities/auth_entity.dart';
import 'package:uuid/uuid.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: 1)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  String firstname;

  @HiveField(2)
  String lastname;

  @HiveField(3)
  String email;

  @HiveField(4)
  String password;

  @HiveField(5)
  String? number;

  @HiveField(6)
  int? age;

  @HiveField(7)
  String? gender;

  @HiveField(8)
  String? bio;

  @HiveField(9)
  String? interests; // stored as comma-separated

  @HiveField(10)
  String? photos; // stored as comma-separated

  @HiveField(11)
  String? location;

  AuthHiveModel({
    String? userId,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.password,
    this.number,
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
      firstname: firstname,
      lastname: lastname,
      email: email,
      password: password,
      number: number,
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
      firstname: entity.firstname,
      lastname: entity.lastname,
      email: entity.email,
      password: entity.password,
      number: entity.number,
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
