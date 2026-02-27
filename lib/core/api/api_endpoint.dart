import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Base URL (host + port only)
  // For Android Emulator use: 'http://10.0.2.2:<port>'
  // For Physical Device use your computer's IP: 'http://192.168.x.x:<port>'

  static const bool isPhysicalDevice = false;

  static const String comIpAddress = "192.168.1.1";
  static const int serverPort = 5000;

  static String get baseUrl {
    if (isPhysicalDevice) {
      return 'http://$comIpAddress:$serverPort';
    }

    if (kIsWeb) {
      return 'http://localhost:$serverPort';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:$serverPort';
    } else if (Platform.isIOS) {
      return "http://localhost:$serverPort";
    } else {
      return "http://localhost:$serverPort";
    }
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
