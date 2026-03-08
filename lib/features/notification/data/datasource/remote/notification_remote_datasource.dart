import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/api/api_client.dart';
import 'package:pairup/core/api/api_endpoint.dart';
import 'package:pairup/features/notification/data/datasource/notification_datasource.dart';
import 'package:pairup/features/notification/data/models/notification_api_models.dart';
import 'package:pairup/features/notification/domain/entities/notification_entities.dart';

final notificationRemoteDataSourceProvider =
    Provider<INotificationRemoteDataSource>((ref) {
      return NotificationRemoteDataSource(
        apiClient: ref.read(apiClientProvider),
      );
    });

class NotificationRemoteDataSource implements INotificationRemoteDataSource {
  final ApiClient _apiClient;

  NotificationRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<NotificationItemApiModel>> getNotifications() async {
    final responses = await Future.wait<Response<dynamic>?>([
      _safeGet(ApiEndpoints.pendingLikes),
      _safeGet(ApiEndpoints.pendingInvites),
      _safeGet(ApiEndpoints.postLikeNotifications),
    ]);

    if (responses.every((item) => item == null)) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.pendingLikes),
        message: 'Unable to load notifications',
      );
    }

    final likes = _parseLikeNotifications(responses[0]?.data);
    final invites = _parseInviteNotifications(responses[1]?.data);
    final postLikes = _parsePostLikeNotifications(responses[2]?.data);

    final merged = [...likes, ...invites, ...postLikes];
    merged.sort((left, right) {
      final leftMs = left.createdAt?.millisecondsSinceEpoch ?? 0;
      final rightMs = right.createdAt?.millisecondsSinceEpoch ?? 0;
      return rightMs.compareTo(leftMs);
    });
    return merged;
  }

  @override
  Future<void> respondToNotification({
    required NotificationItemType type,
    required String notificationId,
    required String fromUserId,
    required NotificationItemAction action,
  }) async {
    if (type == NotificationItemType.postLike) return;

    if (type == NotificationItemType.like) {
      final senderId = fromUserId.trim();
      if (senderId.isEmpty) return;
      await _apiClient.post(
        action == NotificationItemAction.accept
            ? ApiEndpoints.acceptLike(senderId)
            : ApiEndpoints.declineLike(senderId),
      );
      return;
    }

    final inviteId = notificationId.trim();
    if (inviteId.isEmpty) return;
    await _apiClient.post(
      action == NotificationItemAction.accept
          ? ApiEndpoints.acceptInvite(inviteId)
          : ApiEndpoints.rejectInvite(inviteId),
    );
  }

  Future<Response<dynamic>?> _safeGet(String path) async {
    try {
      return await _apiClient.get(path);
    } catch (_) {
      return null;
    }
  }

  List<NotificationItemApiModel> _parseLikeNotifications(dynamic payload) {
    final body = payload is Map<String, dynamic>
        ? payload
        : const <String, dynamic>{};
    final nested = body['data'] is Map<String, dynamic>
        ? body['data'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final source = body['likes'] ?? nested['likes'];
    final rows = _readMapList(source);

    return rows
        .map(NotificationItemApiModel.fromLikeJson)
        .where(
          (item) => item.id.isNotEmpty && item.fromUserId.trim().isNotEmpty,
        )
        .toList();
  }

  List<NotificationItemApiModel> _parseInviteNotifications(dynamic payload) {
    final body = payload is Map<String, dynamic>
        ? payload
        : const <String, dynamic>{};
    final nested = body['data'] is Map<String, dynamic>
        ? body['data'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final source = body['invitations'] ?? nested['invitations'];
    final rows = _readMapList(source);

    return rows
        .map(NotificationItemApiModel.fromInviteJson)
        .where(
          (item) => item.id.isNotEmpty && item.fromUserId.trim().isNotEmpty,
        )
        .toList();
  }

  List<NotificationItemApiModel> _parsePostLikeNotifications(dynamic payload) {
    final body = payload is Map<String, dynamic>
        ? payload
        : const <String, dynamic>{};
    final nested = body['data'] is Map<String, dynamic>
        ? body['data'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final source = body['notifications'] ?? nested['notifications'];
    final rows = _readMapList(source);

    return rows
        .map(NotificationItemApiModel.fromPostLikeJson)
        .where(
          (item) => item.id.isNotEmpty && item.fromUserId.trim().isNotEmpty,
        )
        .toList();
  }
}

List<Map<String, dynamic>> _readMapList(dynamic value) {
  if (value is List<dynamic>) {
    return value.whereType<Map<String, dynamic>>().toList();
  }
  return const [];
}
