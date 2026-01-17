import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/services/hive/hive_service.dart';
import 'package:pairup/core/services/storage/user_session_service.dart';
import 'package:pairup/features/auth/data/datasource/auth_datasource.dart';
import 'package:pairup/features/auth/data/models/auth_hive_model.dart';

final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  final userSessionService = ref.read(userSessionServiceProvider);
  return AuthLocalDatasource(
    hiveService: hiveService,
    userSessionService: userSessionService,
  );
});

class AuthLocalDatasource implements IAuthLocalDataSource {
  final HiveService _hiveService;
  final UserSessionService _userSessionService;

  AuthLocalDatasource({
    required HiveService hiveService,
    required UserSessionService userSessionService,
  }) : _hiveService = hiveService,
       _userSessionService = userSessionService;

  @override
  Future<bool> register(AuthHiveModel user) async {
    try {
      await _hiveService.register(user);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      final user = _hiveService.login(email, password);
      if (user != null) {
        // Save user session to SharedPreferences
        await _userSessionService.saveUserSession(
          userId: user.userId,
          email: user.email,
          fullName: user.name,
        );
      }
      return user;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    try {
      if (!_userSessionService.isLoggedIn()) {
        return null;
      }
      final userId = _userSessionService.getCurrentUserUserId();
      if (userId == null) {
        return null;
      }

      return _hiveService.getAuthUserById(userId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _userSessionService.clearSession();
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
    try {
      return _hiveService.getUserByEmail(email);
    } catch (e) {
      return null;
    }
  }

  //  @override
  // Future<bool> updateUser(AuthHiveModel user) async {
  //   try {
  //     return await _hiveService.updateUser(user);
  //   } catch (e) {
  //     return false;
  //   }
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
