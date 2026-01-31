import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - change this for production
  // static const String baseUrl =
  //     'http://10.0.2.2:3000'; // just the server, no /api/auth
  // For Android Emulator use: 'http://10.0.2.2:3000'
  // For Physical Device use your computer's IP: 'http://192.168.x.x:3000'

  static const bool isPhysicalDevice = false;

  static const String comIpAddress = "192.168.1.1";

  static String get baseUrl {
    if (isPhysicalDevice) {
      return 'http://$comIpAddress:3000/api';
    }

    if (kIsWeb) {
      return 'http://localhost:3000/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    } else if (Platform.isIOS) {
      return "http://localhost:3000/api";
    } else {
      return "http://localhost:3000/api";
    }
  }

  static const connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ AUTH ENDPOINTS ============
  static const String userRegister = '/api/auth/register'; // match your backend
  static const String userLogin = '/api/auth/login'; // match your backend
  static String userById(String id) => '/api/auth/users/$id';
  static String userPhoto(String id) => '/api/auth/users/$id/photo';
}
