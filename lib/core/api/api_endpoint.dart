import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Optional overrides:
  // --dart-define=API_BASE_URL=http://localhost:5000
  // --dart-define=API_HOST=192.168.1.10
  // --dart-define=API_PORT=5000
  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
  );
  static const String _apiHostOverride = String.fromEnvironment('API_HOST');
  static const String _apiPortOverride = String.fromEnvironment('API_PORT');

  static const int _defaultServerPort = 5000;

  static int get serverPort {
    final parsed = int.tryParse(_apiPortOverride);
    return parsed ?? _defaultServerPort;
  }

  static String get baseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) {
      return _apiBaseUrlOverride;
    }

    final host = _resolveHost();
    return 'http://$host:$serverPort';
  }

  static String _resolveHost() {
    if (_apiHostOverride.isNotEmpty) {
      return _apiHostOverride;
    }

    if (kIsWeb) {
      return 'localhost';
    }

    if (Platform.isAndroid) {
      // Android emulator maps host machine localhost to 10.0.2.2.
      return '10.0.2.2';
    }

    // iOS simulator + desktop platforms can use localhost directly.
    return 'localhost';
  }

  static const connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ AUTH ENDPOINTS ============
  static const String userRegister = '/api/auth/register'; // match your backend
  static const String userLogin = '/api/auth/login'; // match your backend
  static String userById(String id) => '/api/auth/users/$id';
  static String userPhoto(String id) => '/api/auth/users/$id/photo';

  // ============ CHAT ENDPOINTS ============
  static const String conversations = '/api/conversations';
  static const String matches = '/api/matches';
  static const String pendingLikes = '/api/likes/pending';
  static const String pendingInvites = '/api/invites/pending';
  static const String postLikeNotifications =
      '/api/users/me/post-like-notifications';
  static String acceptLike(String senderId) => '/api/likes/$senderId/accept';
  static String declineLike(String senderId) => '/api/likes/$senderId/decline';
  static String acceptInvite(String invitationId) =>
      '/api/invites/$invitationId/accept';
  static String rejectInvite(String invitationId) =>
      '/api/invites/$invitationId/reject';

  static String conversationMessages(String conversationId) =>
      '/api/conversations/$conversationId/messages';
  static String chatMessages(String conversationId) =>
      '/api/messages/$conversationId';
  static const String createMessage = '/api/messages';
}
