import 'package:pairup/features/auth/data/models/auth_hive_model.dart';

abstract interface class IAuthDataSource {
  Future<bool> register(AuthHiveModel user);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel?> getCurrentUser();
  Future<bool> logout();
  Future<bool> doesEmailExist(String email);

  Future<AuthHiveModel?> getAuthUserById(String userId);
  Future<AuthHiveModel?> getUserByEmail(String email);
  // Future<bool> updateUser(AuthHiveModel user);
  Future<bool> deleteUser(String userId);
}
