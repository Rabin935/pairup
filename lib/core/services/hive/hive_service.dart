import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../../constants/hive_table_constant.dart';
import '../../../features/user/data/models/user_hive_model.dart';
import '../../../features/auth/data/datasource/models/auth_hive_model.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  // ================= INITIALIZATION =================

  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);
    _registerAdapters();
    await _openBoxes();
  }

  void _registerAdapters() {
        // Register UserHiveModelAdapter (typeId: 0)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserHiveModelAdapter());
    }
    // Register AuthHiveModelAdapter (typeId: 1)
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }

  Future<void> _openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.userTable);
  }

  Future<void> close() async {
    await Hive.close();
  }

  // ================= USER CRUD =================

  Box<UserHiveModel> get _userBox =>
      Hive.box<UserHiveModel>(HiveTableConstant.userTable);

  Future<UserHiveModel> createUser(UserHiveModel user) async {
    await _userBox.put(user.userId, user);
    return user;
  }

  Future<UserHiveModel> saveUser(UserHiveModel user) async {
    await _userBox.put(user.userId, user);
    return user;
  }

  UserHiveModel? getUserById(String userId) {
    return _userBox.get(userId);
  }

  List<UserHiveModel> getAllUsers() {
    return _userBox.values.toList();
  }

  Future<bool> updateUser(UserHiveModel user) async {
    if (_userBox.containsKey(user.userId)) {
      await _userBox.put(user.userId, user);
      return true;
    }
    return false;
  }

  Future<void> deleteUser(String userId) async {
    await _userBox.delete(userId);
  }

  bool doesEmailExist(String email) {
    return _userBox.values.any((user) => user.email == email);
  }

  // ================= AUTH CRUD =================

  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.userTable);

  /// Register (Signup)
  Future<AuthHiveModel> register(AuthHiveModel user) async {
    print(
      'HiveService.register: Storing user with email=${user.email}, password=${user.password}',
    );
    await _authBox.put(user.userId, user);
    print(
      'HiveService.register: User stored. Box contains ${_authBox.length} users',
    );
    // Verify storage
    final stored = _authBox.get(user.userId);
    print(
      'HiveService.register: Verification - stored user email=${stored?.email}, password=${stored?.password}',
    );
    return user;
  }

  /// Login
  AuthHiveModel? login(String email, String password) {
    try {
      print(
        'HiveService.login: Searching for email=$email, password=$password',
      );
      print('HiveService.login: Box contains ${_authBox.length} users');
      _authBox.values.forEach((user) {
        print('  - User in DB: email=${user.email}, password=${user.password}');
      });
      final user = _authBox.values.firstWhere(
        (user) => user.email == email && user.password == password,
      );
      print('HiveService.login: Found user with email=$email');
      return user;
    } catch (e) {
      print('HiveService.login: No user found - $e');
      return null;
    }
  }

  /// Get current user by ID
  AuthHiveModel? getCurrentUser(String authId) {
    return _authBox.get(authId);
  }

  /// Get user by email
  AuthHiveModel? getUserByEmail(String email) {
    try {
      return _authBox.values.firstWhere((user) => user.email == email);
    } catch (_) {
      return null;
    }
  }

  // userID
  AuthHiveModel? getAuthUserById(String userId) {
    try {
      return _authBox.values.firstWhere((user) => user.userId == userId);
    } catch (_) {
      return null;
    }
  }

  /// Update auth user
  Future<bool> updateAuthUser(AuthHiveModel user) async {
    if (_authBox.containsKey(user.userId)) {
      await _authBox.put(user.userId, user);
      return true;
    }
    return false;
  }

  /// Delete auth user
  Future<void> deleteAuthUser(String authId) async {
    await _authBox.delete(authId);
  }

  /// Logout (local only)
  Future<void> logout() async {
    // optional: clear session or cached user
  }

  Future<void> put(String userId, AuthHiveModel user) async {}
}
