import 'package:pairup/core/api/api_endpoint.dart';
import 'package:pairup/features/chat/domain/entities/chat_entities.dart';

class ChatUserApiModel {
  final String id;
  final String name;
  final String avatarUrl;
  final bool isOnline;
  final String? location;
  final int? age;
  final DateTime? lastSeen;

  const ChatUserApiModel({
    required this.id,
    required this.name,
    this.avatarUrl = '',
    this.isOnline = false,
    this.location,
    this.age,
    this.lastSeen,
  });

  factory ChatUserApiModel.fromJson(Map<String, dynamic> json) {
    final firstName = _readString(json['firstname']);
    final lastName = _readString(json['lastname']);
    final combinedName = '$firstName $lastName'.trim();

    return ChatUserApiModel(
      id: _readString(json['id']).isNotEmpty
          ? _readString(json['id'])
          : _readString(json['_id']),
      name: _readString(json['name']).isNotEmpty
          ? _readString(json['name'])
          : (combinedName.isNotEmpty ? combinedName : 'PairUp user'),
      avatarUrl: _readString(json['avatar']).isNotEmpty
          ? _normalizeImageUrl(_readString(json['avatar']))
          : (_readString(json['profileImage']).isNotEmpty
                ? _normalizeImageUrl(_readString(json['profileImage']))
                : _normalizeImageUrl(_readString(json['image']))),
      isOnline: _readBool(json['isOnline']) || _readBool(json['online']),
      location: _readString(json['location']).isEmpty
          ? null
          : _readString(json['location']),
      age: _readInt(json['age']),
      lastSeen: _readDateTime(json['lastSeen']),
    );
  }

  ChatUserEntity toEntity() {
    return ChatUserEntity(
      id: id,
      name: name,
      avatarUrl: avatarUrl,
      isOnline: isOnline,
      location: location,
      age: age,
      lastSeen: lastSeen,
    );
  }
}

class ChatThreadApiModel {
  final String id;
  final ChatUserApiModel participant;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const ChatThreadApiModel({
    required this.id,
    required this.participant,
    this.lastMessage = '',
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  factory ChatThreadApiModel.fromJson(
    Map<String, dynamic> json, {
    required String currentUserId,
  }) {
    final participants = ((json['participants'] as List<dynamic>?) ?? [])
        .whereType<Map<String, dynamic>>()
        .map(ChatUserApiModel.fromJson)
        .toList();

    final participant = _pickParticipant(participants, currentUserId);

    return ChatThreadApiModel(
      id: _readString(json['id']).isNotEmpty
          ? _readString(json['id'])
          : _readString(json['_id']),
      participant: participant,
      lastMessage: _readString(json['lastMessage']),
      lastMessageAt:
          _readDateTime(json['lastMessageAt']) ??
          _readDateTime(json['updatedAt']),
      unreadCount:
          _readInt(json['unreadCount']) ?? _readInt(json['unread']) ?? 0,
    );
  }

  ChatThreadEntity toEntity() {
    return ChatThreadEntity(
      id: id,
      participant: participant.toEntity(),
      lastMessage: lastMessage,
      lastMessageAt: lastMessageAt,
      unreadCount: unreadCount,
    );
  }
}

class NewRequestApiModel {
  final String id;
  final String name;
  final String avatarUrl;
  final bool isOnline;

  const NewRequestApiModel({
    required this.id,
    required this.name,
    this.avatarUrl = '',
    this.isOnline = false,
  });

  factory NewRequestApiModel.fromJson(Map<String, dynamic> json) {
    final firstName = _readString(json['firstname']);
    final lastName = _readString(json['lastname']);
    final combinedName = '$firstName $lastName'.trim();

    return NewRequestApiModel(
      id: _readString(json['_id']).isNotEmpty
          ? _readString(json['_id'])
          : _readString(json['id']),
      name: _readString(json['name']).isNotEmpty
          ? _readString(json['name'])
          : (combinedName.isNotEmpty ? combinedName : 'PairUp user'),
      avatarUrl: _readString(json['profileImage']).isNotEmpty
          ? _normalizeImageUrl(_readString(json['profileImage']))
          : (_readString(json['avatar']).isNotEmpty
                ? _normalizeImageUrl(_readString(json['avatar']))
                : _normalizeImageUrl(_readString(json['image']))),
      isOnline: _readBool(json['isOnline']) || _readBool(json['online']),
    );
  }

  NewRequestEntity toEntity() {
    return NewRequestEntity(
      id: id,
      name: name,
      avatarUrl: avatarUrl,
      isOnline: isOnline,
    );
  }
}

class MatchRequestApiModel {
  final String id;
  final MatchRequestType type;
  final String? senderId;
  final String? participantId;
  final String name;
  final String avatarUrl;
  final String subtitle;
  final DateTime? createdAt;

  const MatchRequestApiModel({
    required this.id,
    required this.type,
    this.senderId,
    this.participantId,
    required this.name,
    this.avatarUrl = '',
    this.subtitle = '',
    this.createdAt,
  });

  factory MatchRequestApiModel.fromLikeJson(Map<String, dynamic> json) {
    final senderId = _readString(json['senderId']);
    final id = _readString(json['likeId']).isNotEmpty
        ? _readString(json['likeId'])
        : senderId;

    return MatchRequestApiModel(
      id: id,
      type: MatchRequestType.like,
      senderId: senderId.isEmpty ? null : senderId,
      participantId: senderId.isEmpty ? null : senderId,
      name: _readString(json['name']).isNotEmpty
          ? _readString(json['name'])
          : 'PairUp user',
      avatarUrl: _readString(json['image']).isNotEmpty
          ? _normalizeImageUrl(_readString(json['image']))
          : _normalizeImageUrl(_readString(json['profileImage'])),
      subtitle: 'Liked your profile',
      createdAt: _readDateTime(json['createdAt']),
    );
  }

  factory MatchRequestApiModel.fromInviteJson(Map<String, dynamic> json) {
    final preview = (json['preview'] as Map<String, dynamic>?) ?? const {};
    final fromUserId = _readString(json['fromUserId']);
    final age = _readInt(preview['age']);
    final location = _readString(preview['location']);
    final details = [
      if (age != null) '$age yrs',
      if (location.isNotEmpty) location,
    ];

    return MatchRequestApiModel(
      id: _readString(json['invitationId']).isNotEmpty
          ? _readString(json['invitationId'])
          : _readString(json['id']),
      type: MatchRequestType.invite,
      senderId: fromUserId.isEmpty ? null : fromUserId,
      participantId: fromUserId.isEmpty ? null : fromUserId,
      name: _readString(preview['name']).isNotEmpty
          ? _readString(preview['name'])
          : 'PairUp user',
      avatarUrl: _normalizeImageUrl(_readString(preview['avatar'])),
      subtitle: details.isEmpty ? 'Invitation request' : details.join(' - '),
      createdAt: _readDateTime(json['createdAt']),
    );
  }

  MatchRequestEntity toEntity() {
    return MatchRequestEntity(
      id: id,
      type: type,
      senderId: senderId,
      participantId: participantId,
      name: name,
      avatarUrl: avatarUrl,
      subtitle: subtitle,
      createdAt: createdAt,
    );
  }
}

class ChatOverviewApiModel {
  final List<MatchRequestApiModel> matchRequests;
  final List<NewRequestApiModel> newRequests;
  final List<ChatThreadApiModel> chats;

  const ChatOverviewApiModel({
    required this.matchRequests,
    required this.newRequests,
    required this.chats,
  });

  ChatOverviewEntity toEntity() {
    return ChatOverviewEntity(
      matchRequests: matchRequests.map((item) => item.toEntity()).toList(),
      newRequests: newRequests.map((item) => item.toEntity()).toList(),
      chats: chats.map((item) => item.toEntity()).toList(),
    );
  }
}

ChatUserApiModel _pickParticipant(
  List<ChatUserApiModel> participants,
  String currentUserId,
) {
  if (participants.isEmpty) {
    return const ChatUserApiModel(id: '', name: 'PairUp user');
  }

  for (final participant in participants) {
    if (participant.id.isNotEmpty && participant.id != currentUserId) {
      return participant;
    }
  }
  return participants.first;
}

String _readString(dynamic value) {
  if (value == null) return '';
  final parsed = value.toString().trim();
  return parsed;
}

bool _readBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' ||
        normalized == '1' ||
        normalized == 'yes' ||
        normalized == 'online';
  }
  return false;
}

int? _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String && value.trim().isNotEmpty) {
    return int.tryParse(value.trim());
  }
  return null;
}

DateTime? _readDateTime(dynamic value) {
  if (value is DateTime) return value;
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value.trim());
  }
  return null;
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
