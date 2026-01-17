class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - change this for production
  static const String baseUrl = 'http://10.0.2.2:3000';
  //static const String baseUrl = 'http://localhost:3000/api/v1';
  // For Android Emulator use: 'http://10.0.2.2:3000/api/v1'
  // For Physical Device use your computer's IP: 'http://192.168.x.x:5000/api/v1'

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ AUTH BASE ============
  static const String auth = '/api/auth';

  // ============ AUTH ENDPOINTS ============
  static const String userRegister = '$auth/users';
  static const String userLogin = '$auth/users/login';
  static String userById(String id) => '$auth/users/$id';
  static String userPhoto(String id) => '$auth/users/$id/photo';
}
