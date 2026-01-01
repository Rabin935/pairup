import 'package:hive/hive.dart';
import 'package:pairup/core/constants/hive_table_constant.dart';
import 'package:pairup/features/user/data/models/user_hive_model.dart';
import 'package:pairup/features/user/domain/entities/user_entities.dart';


class UserRepository {
  late Box<UserHiveModel> _userBox;

  Future<void> init() async {
    _userBox = await Hive.openBox<UserHiveModel>(HiveTableConstant.userTable);
  }

  Future<void> saveUser(UserEntity user) async {
    final model = UserHiveModel.fromEntity(user);
    await _userBox.put(model.userId, model);
  }

  Future<UserEntity?> getUser(String id) async {
    final model = _userBox.get(id);
    return model?.toEntity();
  }

  Future<List<UserEntity>> getAllUsers() async {
    return _userBox.values.map((e) => e.toEntity()).toList();
  }

  Future<void> deleteUser(String id) async {
    await _userBox.delete(id);
  }

  Future<void> clearAll() async {
    await _userBox.clear();
  }
}
