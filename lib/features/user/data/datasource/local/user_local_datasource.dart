import 'package:pairup/core/services/hive/hive_service.dart';
import 'package:pairup/features/user/data/datasource/batch_datasource.dart';
import 'package:pairup/features/user/data/models/user_hive_model.dart';

class UserLocalDatasource implements IUserDatasource {
  final HiveService _hiveService;

  UserLocalDatasource({required HiveService hiveservice})
    : _hiveService = hiveservice;

  @override
  Future<bool> createBatch(UserHiveModel user) {
    // TODO: implement createBatch
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteBatch(String user) {
    // TODO: implement deleteBatch
    throw UnimplementedError();
  }

  @override
  Future<List<UserHiveModel>> getAllUser() {
    // TODO: implement getAllUser
    throw UnimplementedError();
  }

  @override
  Future<UserHiveModel> getUserbyId(String userId) {
    // TODO: implement getUserbyId
    throw UnimplementedError();
  }

  @override
  Future<bool> saveUser(UserHiveModel user) {
    // TODO: implement saveUser
    throw UnimplementedError();
  }

  @override
  Future<bool> updateBatch(UserHiveModel user) {
    // TODO: implement updateBatch
    throw UnimplementedError();
  }
}
