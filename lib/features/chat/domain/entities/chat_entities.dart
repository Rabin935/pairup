import 'package:equatable/equatable.dart';

enum MatchRequestType { like, invite }

class ChatUserEntity extends Equatable {
  final String id;
  final String name;
  final String avatarUrl;
  final bool isOnline;
  final String? location;
  final int? age;
  final DateTime? lastSeen;

  const ChatUserEntity({
    required this.id,
    required this.name,
    this.avatarUrl = '',
    this.isOnline = false,
    this.location,
    this.age,
    this.lastSeen,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    avatarUrl,
    isOnline,
    location,
    age,
    lastSeen,
  ];
}

class ChatThreadEntity extends Equatable {
  final String id;
  final ChatUserEntity participant;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const ChatThreadEntity({
    required this.id,
    required this.participant,
    this.lastMessage = '',
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  @override
  List<Object?> get props => [
    id,
    participant,
    lastMessage,
    lastMessageAt,
    unreadCount,
  ];
}

class NewRequestEntity extends Equatable {
  final String id;
  final String name;
  final String avatarUrl;
  final bool isOnline;

  const NewRequestEntity({
    required this.id,
    required this.name,
    this.avatarUrl = '',
    this.isOnline = false,
  });

  @override
  List<Object?> get props => [id, name, avatarUrl, isOnline];
}

class MatchRequestEntity extends Equatable {
  final String id;
  final MatchRequestType type;
  final String? senderId;
  final String? participantId;
  final String name;
  final String avatarUrl;
  final String subtitle;
  final DateTime? createdAt;

  const MatchRequestEntity({
    required this.id,
    required this.type,
    this.senderId,
    this.participantId,
    required this.name,
    this.avatarUrl = '',
    this.subtitle = '',
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    type,
    senderId,
    participantId,
    name,
    avatarUrl,
    subtitle,
    createdAt,
  ];
}

class ChatOverviewEntity extends Equatable {
  final List<MatchRequestEntity> matchRequests;
  final List<NewRequestEntity> newRequests;
  final List<ChatThreadEntity> chats;

  const ChatOverviewEntity({
    this.matchRequests = const [],
    this.newRequests = const [],
    this.chats = const [],
  });

  static const ChatOverviewEntity empty = ChatOverviewEntity();

  @override
  List<Object?> get props => [matchRequests, newRequests, chats];
}
