import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pairup/core/api/api_client.dart';
import 'package:pairup/core/api/api_endpoint.dart';
import 'package:pairup/core/services/storage/user_session_service.dart';
import 'package:pairup/features/auth/data/datasource/auth_datasource.dart';
import 'package:pairup/features/auth/data/models/auth_api_model.dart';

// Create Provider
final authRemoteDatasourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService;

  @override
  Future<AuthApiModel?> getUserById(String userId) {
    // TODO: implement getUserByIdnew
    throw UnimplementedError();
  }

  @override
  Future<AuthApiModel?> login(String email, String password) {
    return _login(email, password);
  }

  Future<AuthApiModel?> _login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.userLogin,
      data: {'email': email, 'password': password},
    );

    if (response.data['success'] == true) {
      final token = response.data['token'] as String?;
      final data = response.data['data'] as Map<String, dynamic>?;

      if (token != null && token.isNotEmpty) {
        await _secureStorage.write(key: _tokenKey, value: token);
      }

      if (data != null) {
        final user = AuthApiModel.fromJson(data);
        if (user.id != null) {
          await _userSessionService.saveUserSession(
            userId: user.id!,
            email: user.email,
            firstname: user.firstname,
            lastname: user.lastname,
            phoneNumber: user.number,
          );
        }
        return user;
      }
    }

    return null;
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    final response = await _apiClient.post(
      ApiEndpoints.userRegister,
      data: user.toJson(),
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final registeredUser = AuthApiModel.fromJson(data);
      return registeredUser;
    }

    return user;
  }
}
