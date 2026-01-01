import 'package:hive/hive.dart';
import 'package:pairup/core/constants/hive_table_constant.dart';
import 'package:pairup/features/auth/domain/entities/auth_entity.dart';
import 'package:uuid/uuid.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.userTypeId)
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
  String phoneNumber;

  @HiveField(5)
  int age;

  @HiveField(6)
  String gender;

  @HiveField(7)
  String bio;

  @HiveField(8)
  String interests;

  @HiveField(9)
  String photos;

  @HiveField(10)
  String location;

  AuthHiveModel({
    String? userId,
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.age,
    required this.gender,
    this.bio = '',
    required this.interests,
    required this.photos,
    this.location = '',
  }) : userId = userId ?? const Uuid().v4();

  // To Entity
  AuthEntity toEntity({AuthEntity? user}) {
    return AuthEntity(
      userId: userId,
      name: name,
      email: email,
      password: '',
      age: age,
      gender: gender,
      bio: bio,
      location: location,
      phoneNumber: '',
      interests: [],
      photos: [],
    );
  }

  // From Entity
  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      userId: entity.userId,
      name: entity.name,
      email: entity.email,
      password: '',
      age: entity.age,
      gender: entity.gender,
      bio: entity.bio,
      location: entity.location,
      phoneNumber: '',
      interests: '',
      photos: '',
    );
  }
  // To Entity List
  static List<AuthEntity> toEntityList(List<AuthHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
