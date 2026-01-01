import 'package:hive/hive.dart';
import 'package:pairup/core/constants/hive_table_constant.dart';
import 'package:pairup/features/user/domain/entities/user_entities.dart';
import 'package:uuid/uuid.dart';


part 'user_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.userTypeId)
class UserHiveModel extends HiveObject {
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

  UserHiveModel({
    String? userId,
    required this.name,
    required this.email,
    required this.age,
    required this.gender,
    this.bio = '',
    List<String>? interests,
    List<String>? photos,
    this.location = '',
  })  : userId = userId ?? const Uuid().v4(),
        interests = interests ?? [],
        photos = photos ?? [];

  // Convert Hive model to entity
  UserEntity toEntity() {
    return UserEntity(
      userId: userId,
      name: name,
      email: email,
      age: age,
      gender: gender,
      bio: bio,
      interests: interests,
      photos: photos,
      location: location,
    );
  }

  // Convert entity to Hive model
  factory UserHiveModel.fromEntity(UserEntity entity) {
    return UserHiveModel(
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
}
