import 'package:pairup/core/api/api_endpoint.dart';
import 'package:pairup/features/notification/domain/entities/notification_entities.dart';

class NotificationItemApiModel {
  final String id;
  final NotificationItemType type;
  final String fromUserId;
  final String name;
  final String imageUrl;
  final String? imageId;
  final String message;
  final DateTime? createdAt;
  final String status;
  final bool isRead;
  final DateTime? readAt;

  const NotificationItemApiModel({
    required this.id,
    required this.type,
    required this.fromUserId,
    required this.name,
    this.imageUrl = '',
    this.imageId,
    this.message = '',
    this.createdAt,
    this.status = 'pending',
    this.isRead = false,
    this.readAt,
  });

  factory NotificationItemApiModel.fromLikeJson(Map<String, dynamic> json) {
    final senderId = _readString(json['senderId']);
    final likeId = _readString(json['likeId']).isNotEmpty
        ? _readString(json['likeId'])
        : senderId;

    return NotificationItemApiModel(
      id: likeId,
      type: NotificationItemType.like,
      fromUserId: senderId,
      name: _readString(json['name']).isNotEmpty
          ? _readString(json['name'])
          : 'PairUp user',
      imageUrl: _normalizeImageUrl(_readString(json['image'])),
      message: 'liked your profile',
      createdAt: _readCreatedAt(json),
      status: _readString(json['status']).isNotEmpty
          ? _readString(json['status'])
          : 'pending',
      isRead: false,
    );
  }

  factory NotificationItemApiModel.fromInviteJson(Map<String, dynamic> json) {
    final preview = (json['preview'] as Map<String, dynamic>?) ?? const {};
    final fromUserId = _readString(json['fromUserId']);

    return NotificationItemApiModel(
      id: _readString(json['invitationId']).isNotEmpty
          ? _readString(json['invitationId'])
          : _readString(json['id']),
      type: NotificationItemType.invite,
      fromUserId: fromUserId,
      name: _readString(preview['name']).isNotEmpty
          ? _readString(preview['name'])
          : 'PairUp user',
      imageUrl: _normalizeImageUrl(_readString(preview['avatar'])),
      message: 'sent you a match request',
      createdAt: _readCreatedAt(json),
      status: _readString(json['status']).isNotEmpty
          ? _readString(json['status'])
          : 'pending',
      isRead: false,
    );
  }

  factory NotificationItemApiModel.fromPostLikeJson(Map<String, dynamic> json) {
    return NotificationItemApiModel(
      id: _readString(json['id']),
      type: NotificationItemType.postLike,
      fromUserId: _readString(json['fromUserId']),
      imageId: _readString(json['imageId']).isEmpty
          ? null
          : _readString(json['imageId']),
      name: _readString(json['name']).isNotEmpty
          ? _readString(json['name'])
          : 'PairUp user',
      imageUrl: _normalizeImageUrl(_readString(json['image'])),
      message: _readString(json['message']).isNotEmpty
          ? _readString(json['message'])
          : 'liked your post',
      createdAt: _readCreatedAt(json),
      status: 'received',
      isRead: false,
    );
  }

  NotificationItemEntity toEntity() {
    return NotificationItemEntity(
      id: id,
      type: type,
      fromUserId: fromUserId,
      name: name,
      imageUrl: imageUrl,
      imageId: imageId,
      message: message,
      createdAt: createdAt,
      status: status,
      isRead: isRead,
      readAt: readAt,
    );
  }
}

String _readString(dynamic value) {
  if (value == null) return '';
  return value.toString().trim();
}

DateTime? _readDateTime(dynamic value) {
  if (value is DateTime) return value;
  if (value is int) {
    final isMilliseconds = value > 9999999999;
    return DateTime.fromMillisecondsSinceEpoch(
      isMilliseconds ? value : value * 1000,
      isUtc: true,
    );
  }
  if (value is double) {
    final normalized = value.round();
    final isMilliseconds = normalized > 9999999999;
    return DateTime.fromMillisecondsSinceEpoch(
      isMilliseconds ? normalized : normalized * 1000,
      isUtc: true,
    );
  }
  if (value is String && value.trim().isNotEmpty) {
    final raw = value.trim();
    final asInt = int.tryParse(raw);
    if (asInt != null) {
      final isMilliseconds = asInt > 9999999999;
      return DateTime.fromMillisecondsSinceEpoch(
        isMilliseconds ? asInt : asInt * 1000,
        isUtc: true,
      );
    }
    return DateTime.tryParse(raw);
  }
  return null;
}

DateTime? _readCreatedAt(Map<String, dynamic> json) {
  return _readDateTime(
    json['createdAt'] ??
        json['created_at'] ??
        json['timestamp'] ??
        json['time'] ??
        json['date'] ??
        json['updatedAt'],
  );
}

String _normalizeImageUrl(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return '';
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }
  if (value.startsWith('/')) {
    return '${ApiEndpoints.baseUrl}$value';
  }
  return '${ApiEndpoints.baseUrl}/$value';
}
