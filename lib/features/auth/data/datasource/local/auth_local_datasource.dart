import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/services/hive/hive_service.dart';
import 'package:pairup/features/auth/data/datasource/auth_datasource.dart';
import 'package:pairup/features/auth/data/models/auth_hive_models.dart';


final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return AuthLocalDatasource(hiveService: hiveService);
});

class AuthLocalDatasource implements IAuthDataSource {
  final HiveService _hiveService;

  AuthLocalDatasource({required HiveService hiveService})
      : _hiveService = hiveService;

  // ================= REGISTER =================
  @override
  Future<bool> register(AuthHiveModel user) async {
    try {
      await _hiveService.regsiter(user);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ================= LOGIN =================
  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      return _hiveService.login(email, password);
    } catch (_) {
      return null;
    }
  }

  // ================= CURRENT USER =================
  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    try {
      // You can later store currentUserId in Hive or SharedPreferences
      // For now, return null or first logged user if applicable
      return null;
    } catch (_) {
      return null;
    }
  }

  // ================= LOGOUT =================
  @override
  Future<bool> logout() async {
    try {
      await _hiveService.logout();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ================= GET USER BY ID =================
  @override
  Future<AuthHiveModel?> getUserById(String authId) async {
    try {
      return _hiveService.getUserById(authId);
    } catch (_) {
      return null;
    }
  }

  // ================= GET USER BY EMAIL =================
  @override
  Future<AuthHiveModel?> getUserByEmail(String email) async {
    try {
      return _hiveService.getUserByEmail(email);
    } catch (_) {
      return null;
    }
  }

  // ================= UPDATE USER =================
  @override
  Future<bool> updateUser(AuthHiveModel user) async {
    try {
      return await _hiveService.updateUser(user);
    } catch (_) {
      return false;
    }
  }

  // ================= DELETE USER =================
  @override
  Future<bool> deleteUser(String authId) async {
    try {
      await _hiveService.deleteUser(authId);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ================= CHECK EMAIL =================
  @override
  Future<bool> doesEmailExist(String email) async {
    try {
      return _hiveService.doesEmailExist(email);
    } catch (_) {
      return false;
    }
  }
}
