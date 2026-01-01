import 'package:pairup/features/user/data/models/user_hive_model.dart';

abstract interface class IUserDatasource {
  Future<List<UserHiveModel>> getAllUser();
  Future<UserHiveModel?> getUserbyId(String userId);
  Future<bool> createUser(UserHiveModel user);
  Future<bool> updateUser(UserHiveModel user);
  Future<bool> deleteUser(String userId);
  Future<bool> saveUser(UserHiveModel user);
}
