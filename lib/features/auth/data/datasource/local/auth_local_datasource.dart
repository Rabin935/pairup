import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/services/hive/hive_service.dart';
import 'package:pairup/features/auth/data/datasource/auth_datasource.dart';
import 'package:pairup/features/auth/data/datasource/models/auth_hive_model.dart';

final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return AuthLocalDatasource(hiveService: hiveService);
});

class AuthLocalDatasource implements IAuthDataSource {
  final HiveService _hiveService;

  AuthLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<bool> register(AuthHiveModel user) async {
    try {
      print(
        'AuthLocalDatasource.register: email=${user.email}, password=${user.password}',
      );
      await _hiveService.register(user);
      print('AuthLocalDatasource.register success');
      return true;
    } catch (e) {
      print('AuthLocalDatasource.register error: $e');
      return false;
    }
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    return _hiveService.login(email, password);
  }

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    return null; // optional: session handling later
  }

  @override
  Future<bool> logout() async {
    try {
      await _hiveService.logout();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<AuthHiveModel?> getAuthUserById(String userId) async {
    try {
      return _hiveService.getAuthUserById(userId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthHiveModel?> getUserByEmail(String email) async {
    return _hiveService.getUserByEmail(email);
  }

  // @override
  // Future<bool> updateUser(AuthHiveModel user) async {
  //   return _hiveService.updateUser(user);
  // }

  @override
  Future<bool> deleteUser(String userId) async {
    try {
      await _hiveService.deleteUser(userId);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> doesEmailExist(String email) async {
    return _hiveService.doesEmailExist(email);
  }
}
