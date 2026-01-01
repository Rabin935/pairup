import 'package:pairup/features/user/data/models/user_hive_model.dart';

abstract interface class IUserDatasource {
  Future<List<UserHiveModel>> getAllUser();
  Future<UserHiveModel> getUserbyId(String userId);
  Future<bool> createBatch(UserHiveModel user);
  Future<bool> updateBatch(UserHiveModel user);
  Future<bool> deleteBatch(String user);
  Future<bool> saveUser(UserHiveModel user);
}
