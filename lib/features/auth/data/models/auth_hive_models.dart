import 'package:hive/hive.dart';
import 'package:pairup/core/constants/hive_table_constant.dart';
import 'package:pairup/features/auth/domain/entities/auth_entity.dart';
import 'package:pairup/features/user/domain/entities/user_entities.dart';

import 'package:uuid/uuid.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.userTypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  late String userId;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  int age;

  @HiveField(4)
  String gender;

  @HiveField(5)
  String bio;

  @HiveField(6)
  List<String> interests;

  @HiveField(7)
  List<String> photos;

  @HiveField(8)
  String location;

  AuthHiveModel({
    String? userId,
    required this.name,
    required this.email,
    required this.age,
    required this.gender,
    this.bio = '',
    List<String>? interests,
    List<String>? photos,
    this.location = '',
  }) : userId = userId ?? const Uuid().v4(),
       interests = interests ?? [],
       photos = photos ?? [];

  // To Entity
  AuthEntity toEntity({UserEntity? user}) {
    return AuthEntity(
      userId: userId,
      name: name,
      email: email,
      age: age,
      gender: gender,
      bio: bio,
      interests: interests,
      photos: photos,
      location: location, 
      phoneNumber: '',
    );
  }

  // From Entity
  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      userId: entity.userId,
      name: entity.name,
      email: entity.email,
      age: entity.age,
      gender: entity.gender,
      bio: entity.bio,
      interests: entity.interests,
      photos: entity.photos,
      location: entity.location,
    );
  }

  // To Entity List
  static List<AuthEntity> toEntityList(List<AuthHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}