
import 'package:hive/hive.dart';
import 'package:pairup/features/user/domain/entities/user_entities.dart';
import 'package:uuid/uuid.dart';

part 'batch_hive_model.g.dart';

class UserHiveModel extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  int age;

  @HiveField(4)
  String gender;

  UserHiveModel({
    String? userId,
    required this.name,
    required this.email,
    required this.age,
    required this.gender,
  }) : userId = userId ?? const Uuid().v4();

  UserEntity toEntity() {
    return UserEntity(
      userId: userId,
      name: name,
      email: email,
      age: age,
      gender: gender,
      bio: '',
      interests: [],
      photos: [],
      location: '',
    );
  }

  // convert Entity to hive Model
  factory UserHiveModel.fromEntity(UserEntity entity) {
    return UserHiveModel(
      userId: entity.userId,
      name: entity.name,
      email: entity.email,
      age: entity.age,
      gender: entity.gender,
    );
  }

  // Convert List of Models to list of User Entity
  static List<UserEntity> toEntityList(List<UserHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
