import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/api/api_client.dart';
import 'package:pairup/core/api/api_endpoint.dart';
import 'package:pairup/core/services/storage/user_session_service.dart';
import 'package:pairup/features/chat/data/services/socket_service.dart';
import 'package:pairup/features/chat/domain/usecases/get_chat_overview_usecase.dart';
import 'package:pairup/features/chat/domain/entities/chat_entities.dart';
import 'package:pairup/features/chat/presentation/state/chat_state.dart';

final chatViewModelProvider = NotifierProvider<ChatViewModel, ChatState>(
  ChatViewModel.new,
);

class ChatViewModel extends Notifier<ChatState> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';

  late final GetChatOverviewUsecase _getChatOverviewUsecase;
  late final UserSessionService _userSessionService;
  late final ChatSocketService _socketService;
  late final ApiClient _apiClient;
  Timer? _refreshTimer;
  String? _currentUserId;
  String? _activeConversationId;
  bool _socketBootstrapped = false;

  @override
  ChatState build() {
    _getChatOverviewUsecase = ref.read(getChatOverviewUsecaseProvider);
    _userSessionService = ref.read(userSessionServiceProvider);
    _apiClient = ref.read(apiClientProvider);
    _socketService = ChatSocketService();
    ref.onDispose(() {
      _refreshTimer?.cancel();
      _socketService.dispose();
    });
    return const ChatState();
  }

  Future<void> loadChatOverview({bool showLoading = true}) async {
    _currentUserId = _userSessionService.getCurrentUserId();
    final currentUserId = _currentUserId;
    if (currentUserId == null || currentUserId.trim().isEmpty) {
      state = state.copyWith(
        status: ChatStatus.error,
        errorMessage: 'User session not found. Please login again.',
      );
      return;
    }

    if (showLoading) {
      state = state.copyWith(
        status: ChatStatus.loading,
        clearErrorMessage: true,
      );
    } else {
      state = state.copyWith(clearErrorMessage: true);
    }

    await _connectRealtimeIfNeeded();

    final result = await _getChatOverviewUsecase(
      GetChatOverviewUsecaseParams(currentUserId: currentUserId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: ChatStatus.error,
        errorMessage: failure.message,
      ),
      (overview) => state = state.copyWith(
        status: ChatStatus.loaded,
        overview: overview,
        clearErrorMessage: true,
      ),
    );
  }

  void markConversationAsRead(String conversationId) {
    final chats = [...state.overview.chats];
    final index = chats.indexWhere((chat) => chat.id == conversationId);
    if (index == -1) return;

    final target = chats[index];
    chats[index] = ChatThreadEntity(
      id: target.id,
      participant: target.participant,
      lastMessage: target.lastMessage,
      lastMessageAt: target.lastMessageAt,
      unreadCount: 0,
    );

    state = state.copyWith(
      overview: ChatOverviewEntity(
        matchRequests: state.overview.matchRequests,
        newRequests: state.overview.newRequests,
        chats: chats,
      ),
    );
  }

  void setActiveConversation(String? conversationId) {
    final normalized = conversationId?.trim();
    _activeConversationId = (normalized == null || normalized.isEmpty)
        ? null
        : normalized;
    if (_activeConversationId != null) {
      markConversationAsRead(_activeConversationId!);
    }
  }

  Future<void> acceptMatchRequest(MatchRequestEntity request) async {
    await _handleMatchRequestAction(request: request, accept: true);
  }

  Future<void> declineMatchRequest(MatchRequestEntity request) async {
    await _handleMatchRequestAction(request: request, accept: false);
  }

  Future<void> _connectRealtimeIfNeeded() async {
    if (_socketBootstrapped) return;

    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null || token.trim().isEmpty) return;

    _socketBootstrapped = true;
    _socketService.connect(
      baseUrl: ApiEndpoints.baseUrl,
      token: token,
      handlers: SocketEventHandlers(
        onConnected: () {
          state = state.copyWith(clearErrorMessage: true);
          // Sync latest previews in case messages arrived while socket was down.
          loadChatOverview(showLoading: false);
        },
        onDisconnected: () {
          state = state.copyWith(
            errorMessage: 'Realtime disconnected. Reconnecting...',
          );
        },
        onReceiveMessage: _handleRealtimeMessage,
        onPresenceUpdate: _handlePresenceUpdate,
        onInviteCreated: _handleRequestEvent,
        onMatchRequest: _handleRequestEvent,
        onInviteAccepted: _handleMatchCreatedEvent,
        onLikeAccepted: _handleMatchCreatedEvent,
        onChatMatchCreated: _handleMatchCreatedEvent,
        onInviteRejected: _handleRequestRemovedEvent,
        onConnectError: (_) {
          state = state.copyWith(
            errorMessage: 'Realtime connection issue. Trying to reconnect...',
          );
        },
      ),
    );
  }

  void _handleRealtimeMessage(Map<String, dynamic> payload) {
    final normalizedPayload = _normalizeRealtimePayload(payload);
    final conversationId = _readString(
      normalizedPayload['conversationId'] ?? normalizedPayload['chatId'],
    );
    if (conversationId.isEmpty) return;

    final senderId = _readString(
      normalizedPayload['senderId'] ?? normalizedPayload['sender'],
    );
    final textBody = _readString(normalizedPayload['body']);
    final text = textBody.isNotEmpty
        ? textBody
        : _readString(normalizedPayload['text']);
    final imageUrl = _readString(
      normalizedPayload['imageUrl'] ??
          normalizedPayload['image'] ??
          normalizedPayload['photo'],
    );
    final createdAt =
        _readDateTime(normalizedPayload['createdAt']) ?? DateTime.now();
    final messagePreview = text.isNotEmpty
        ? text
        : (imageUrl.isNotEmpty ? 'Photo' : 'New message');

    final chats = [...state.overview.chats];
    final index = chats.indexWhere((chat) => chat.id == conversationId);
    if (index == -1) {
      _scheduleRefresh();
      return;
    }

    final existing = chats[index];
    final currentUserId = _currentUserId ?? '';
    final isIncoming = senderId.isNotEmpty && senderId != currentUserId;
    final shouldIncrementUnread =
        isIncoming && existing.id != _activeConversationId;
    final updated = ChatThreadEntity(
      id: existing.id,
      participant: existing.participant,
      lastMessage: messagePreview,
      lastMessageAt: createdAt,
      unreadCount: shouldIncrementUnread
          ? existing.unreadCount + 1
          : existing.unreadCount,
    );

    chats.removeAt(index);
    chats.insert(0, updated);

    state = state.copyWith(
      overview: ChatOverviewEntity(
        matchRequests: state.overview.matchRequests,
        newRequests: state.overview.newRequests,
        chats: chats,
      ),
      status: ChatStatus.loaded,
    );
  }

  void _handlePresenceUpdate(Map<String, dynamic> payload) {
    final participantId = _readString(payload['userId']);
    if (participantId.isEmpty) return;

    final status = _readString(payload['status']).toLowerCase();
    final isOnline = status == 'online';
    final lastSeen = _readDateTime(payload['lastSeen']);

    final chats = state.overview.chats.map((chat) {
      if (chat.participant.id != participantId) return chat;

      return ChatThreadEntity(
        id: chat.id,
        participant: ChatUserEntity(
          id: chat.participant.id,
          name: chat.participant.name,
          avatarUrl: chat.participant.avatarUrl,
          isOnline: isOnline,
          location: chat.participant.location,
          age: chat.participant.age,
          lastSeen: lastSeen ?? chat.participant.lastSeen,
        ),
        lastMessage: chat.lastMessage,
        lastMessageAt: chat.lastMessageAt,
        unreadCount: chat.unreadCount,
      );
    }).toList();

    state = state.copyWith(
      overview: ChatOverviewEntity(
        matchRequests: state.overview.matchRequests,
        newRequests: state.overview.newRequests,
        chats: chats,
      ),
    );
  }

  void _handleRequestEvent(Map<String, dynamic> payload) {
    final toUserId = _readString(payload['toUserId']);
    final currentUserId = _currentUserId ?? '';
    if (toUserId.isNotEmpty && toUserId != currentUserId) return;
    _scheduleRefresh();
  }

  void _handleMatchCreatedEvent(Map<String, dynamic> payload) {
    final senderId = _readString(payload['senderId']);
    final receiverId = _readString(payload['receiverId']);
    final currentUserId = _currentUserId ?? '';
    if (currentUserId.isEmpty) return;
    if (senderId != currentUserId && receiverId != currentUserId) return;
    _scheduleRefresh();
  }

  void _handleRequestRemovedEvent(Map<String, dynamic> payload) {
    final toUserId = _readString(payload['toUserId']);
    final currentUserId = _currentUserId ?? '';
    if (toUserId.isNotEmpty && toUserId != currentUserId) return;
    _scheduleRefresh();
  }

  Future<void> _handleMatchRequestAction({
    required MatchRequestEntity request,
    required bool accept,
  }) async {
    final key = _requestActionKey(request);
    if (state.processingRequestKeys.contains(key)) return;

    state = state.copyWith(
      processingRequestKeys: [...state.processingRequestKeys, key],
      clearErrorMessage: true,
    );

    try {
      if (request.type == MatchRequestType.like) {
        final senderId = _resolveSenderId(request);
        if (senderId.isEmpty) {
          throw StateError('Missing sender id for like request');
        }

        await _apiClient.post(
          accept
              ? ApiEndpoints.acceptLike(senderId)
              : ApiEndpoints.declineLike(senderId),
        );
      } else {
        final invitationId = request.id.trim();
        if (invitationId.isEmpty) {
          throw StateError('Missing invitation id');
        }

        await _apiClient.post(
          accept
              ? ApiEndpoints.acceptInvite(invitationId)
              : ApiEndpoints.rejectInvite(invitationId),
        );
      }

      await loadChatOverview(showLoading: false);
    } on DioException catch (e) {
      final body = _readMap(e.response?.data);
      final serverMessage = _readString(body?['message']);
      state = state.copyWith(
        errorMessage: serverMessage.isNotEmpty
            ? serverMessage
            : (accept
                  ? 'Unable to accept request. Please try again.'
                  : 'Unable to decline request. Please try again.'),
      );
    } catch (_) {
      state = state.copyWith(
        errorMessage: accept
            ? 'Unable to accept request. Please try again.'
            : 'Unable to decline request. Please try again.',
      );
    } finally {
      final updatedKeys = [...state.processingRequestKeys]
        ..removeWhere((item) => item == key);
      state = state.copyWith(processingRequestKeys: updatedKeys);
    }
  }

  void _scheduleRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer(const Duration(milliseconds: 500), () {
      loadChatOverview(showLoading: false);
    });
  }
}

String _requestActionKey(MatchRequestEntity request) {
  final senderId = _resolveSenderId(request);
  return '${request.type.name}:${request.id}:$senderId';
}

String _resolveSenderId(MatchRequestEntity request) {
  final sender = request.senderId?.trim();
  if (sender != null && sender.isNotEmpty) return sender;
  final participant = request.participantId?.trim();
  if (participant != null && participant.isNotEmpty) return participant;
  return '';
}

Map<String, dynamic> _normalizeRealtimePayload(Map<String, dynamic> payload) {
  final message = _readMap(payload['message']);
  if (message != null) return message;

  final data = _readMap(payload['data']);
  if (data != null) {
    final nestedMessage = _readMap(data['message']);
    if (nestedMessage != null) return nestedMessage;
    return data;
  }

  return payload;
}

Map<String, dynamic>? _readMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, data) => MapEntry(key.toString(), data));
  }
  return null;
}

String _readString(dynamic value) {
  if (value == null) return '';
  return value.toString().trim();
}

DateTime? _readDateTime(dynamic value) {
  if (value is DateTime) return value;
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value.trim());
  }
  return null;
}
