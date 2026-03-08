import 'package:equatable/equatable.dart';

enum NotificationItemType { like, invite, postLike }

enum NotificationItemAction { accept, decline }

class NotificationItemEntity extends Equatable {
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

  const NotificationItemEntity({
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

  String get key => '${type.name}:$id';

  NotificationItemEntity copyWith({
    String? id,
    NotificationItemType? type,
    String? fromUserId,
    String? name,
    String? imageUrl,
    String? imageId,
    String? message,
    DateTime? createdAt,
    String? status,
    bool? isRead,
    DateTime? readAt,
    bool clearReadAt = false,
  }) {
    return NotificationItemEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      fromUserId: fromUserId ?? this.fromUserId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      imageId: imageId ?? this.imageId,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      isRead: isRead ?? this.isRead,
      readAt: clearReadAt ? null : (readAt ?? this.readAt),
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    fromUserId,
    name,
    imageUrl,
    imageId,
    message,
    createdAt,
    status,
    isRead,
    readAt,
  ];
}
