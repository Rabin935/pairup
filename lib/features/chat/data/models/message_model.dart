import 'package:equatable/equatable.dart';

enum MessageDeliveryStatus { pending, sent, failed }

class MessageModel extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String text;
  final String imageUrl;
  final DateTime createdAt;
  final bool isRead;
  final MessageDeliveryStatus deliveryStatus;
  final String? clientMessageId;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.createdAt,
    this.imageUrl = '',
    this.isRead = false,
    this.deliveryStatus = MessageDeliveryStatus.sent,
    this.clientMessageId,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final senderId = _readString(json['senderId']).isNotEmpty
        ? _readString(json['senderId'])
        : _readString(json['sender']);
    final receiverId = _readString(json['receiverId']).isNotEmpty
        ? _readString(json['receiverId'])
        : _readString(json['receiver']);

    return MessageModel(
      id: _readString(json['id']).isNotEmpty
          ? _readString(json['id'])
          : _readString(json['_id']),
      conversationId: _readString(json['conversationId']).isNotEmpty
          ? _readString(json['conversationId'])
          : _readString(json['chatId']),
      senderId: senderId,
      receiverId: receiverId,
      text: _readString(json['body']).isNotEmpty
          ? _readString(json['body'])
          : _readString(json['text']),
      imageUrl: _readString(json['imageUrl']).isNotEmpty
          ? _readString(json['imageUrl'])
          : _readString(json['image']),
      createdAt:
          _readDateTime(json['createdAt']) ??
          _readDateTime(json['timestamp']) ??
          DateTime.now(),
      isRead: _readBool(json['read']) || _readBool(json['isRead']),
      clientMessageId: _readString(json['clientMessageId']).isEmpty
          ? null
          : _readString(json['clientMessageId']),
      deliveryStatus: MessageDeliveryStatus.sent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'receiverId': receiverId,
      'body': text,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'read': isRead,
      if (clientMessageId != null) 'clientMessageId': clientMessageId,
    };
  }

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? receiverId,
    String? text,
    String? imageUrl,
    DateTime? createdAt,
    bool? isRead,
    MessageDeliveryStatus? deliveryStatus,
    String? clientMessageId,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      clientMessageId: clientMessageId ?? this.clientMessageId,
    );
  }

  bool get hasText => text.trim().isNotEmpty;

  bool get hasImage => imageUrl.trim().isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    conversationId,
    senderId,
    receiverId,
    text,
    imageUrl,
    createdAt,
    isRead,
    deliveryStatus,
    clientMessageId,
  ];
}

String _readString(dynamic value) {
  if (value == null) return '';
  return value.toString().trim();
}

bool _readBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
  return false;
}

DateTime? _readDateTime(dynamic value) {
  if (value is DateTime) return value;
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value.trim());
  }
  return null;
}
