import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/services/hive/hive_service.dart';
import 'package:pairup/features/user/data/datasource/user_datasource.dart';
import 'package:pairup/features/user/data/models/user_hive_model.dart';

final userLocalDataSourceProvider = Provider<UserLocalDatasource>((ref) {
  return UserLocalDatasource(hiveservice: ref.read(hiveServiceProvider));
});

class UserLocalDatasource implements IUserDatasource {
  final HiveService _hiveService;

  UserLocalDatasource({required HiveService hiveservice})
    : _hiveService = hiveservice;

  @override
  Future<bool> createUser(UserHiveModel user) async {
    try {
      await _hiveService.createUser(user);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteUser(String userId) async {
    try {
      await _hiveService.deleteUser(userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<UserHiveModel>> getAllUser() async {
    try {
      return _hiveService.getAllUsers();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<UserHiveModel?> getUserbyId(String userId) async {
    try {
      return _hiveService.getUserById(userId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> saveUser(UserHiveModel user) async {
    try {
      await _hiveService.saveUser(user);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateUser(UserHiveModel user) async {
    try {
      await _hiveService.updateUser(user);
      return true;
    } catch (e) {
      return false;
    }
  }
}
