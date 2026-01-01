import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:pairup/core/constants/hive_table_constant.dart';
import 'package:pairup/features/user/data/models/user_hive_model.dart';
import 'package:path_provider/path_provider.dart';


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
    if (!Hive.isAdapterRegistered(HiveTableConstant.userTypeId)) {
      Hive.registerAdapter(UserHiveModelAdapter());
    }
  }

  Future<void> _openBoxes() async {
    await Hive.openBox<UserHiveModel>(HiveTableConstant.userTable);
  }

  Future<void> close() async {
    await Hive.close();
  }

  // ================= USER CRUD =================

  Box<UserHiveModel> get _userBox =>
      Hive.box<UserHiveModel>(HiveTableConstant.userTable);

  /// Save user
  Future<UserHiveModel> saveUser(UserHiveModel user) async {
    await _userBox.put(user.userId, user);
    return user;
  }

  /// Get user by ID
  UserHiveModel? getUserById(String userId) {
    return _userBox.get(userId);
  }

  /// Get all users
  List<UserHiveModel> getAllUsers() {
    return _userBox.values.toList();
  }

  /// Update user
  Future<bool> updateUser(UserHiveModel user) async {
    if (_userBox.containsKey(user.userId)) {
      await _userBox.put(user.userId, user);
      return true;
    }
    return false;
  }

  /// Delete user
  Future<void> deleteUser(String userId) async {
    await _userBox.delete(userId);
  }

  /// Check if email exists (for signup)
  bool doesEmailExist(String email) {
    return _userBox.values.any((user) => user.email == email);
  }
}
