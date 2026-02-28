import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pairup/core/api/api_client.dart';
import 'package:pairup/core/api/api_endpoint.dart';
import 'package:pairup/core/services/storage/user_session_service.dart';
import 'package:pairup/features/chat/data/models/message_model.dart';
import 'package:pairup/features/chat/data/services/socket_service.dart';

class ChatSessionArgs extends Equatable {
  final String conversationId;
  final String participantId;
  final String participantName;
  final String participantAvatar;
  final bool isParticipantOnline;
  final DateTime? participantLastSeen;

  const ChatSessionArgs({
    required this.conversationId,
    required this.participantId,
    required this.participantName,
    this.participantAvatar = '',
    this.isParticipantOnline = false,
    this.participantLastSeen,
  });

  @override
  List<Object?> get props => [
    conversationId,
    participantId,
    participantName,
    participantAvatar,
    isParticipantOnline,
    participantLastSeen,
  ];
}

class ChatConversationState extends Equatable {
  final bool isLoading;
  final bool isSending;
  final bool isUploadingImage;
  final bool socketConnected;
  final bool isPartnerTyping;
  final bool isPartnerOnline;
  final DateTime? partnerLastSeen;
  final List<MessageModel> messages;
  final String? errorMessage;

  const ChatConversationState({
    this.isLoading = true,
    this.isSending = false,
    this.isUploadingImage = false,
    this.socketConnected = false,
    this.isPartnerTyping = false,
    this.isPartnerOnline = false,
    this.partnerLastSeen,
    this.messages = const [],
    this.errorMessage,
  });

  ChatConversationState copyWith({
    bool? isLoading,
    bool? isSending,
    bool? isUploadingImage,
    bool? socketConnected,
    bool? isPartnerTyping,
    bool? isPartnerOnline,
    DateTime? partnerLastSeen,
    bool clearPartnerLastSeen = false,
    List<MessageModel>? messages,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChatConversationState(
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      socketConnected: socketConnected ?? this.socketConnected,
      isPartnerTyping: isPartnerTyping ?? this.isPartnerTyping,
      isPartnerOnline: isPartnerOnline ?? this.isPartnerOnline,
      partnerLastSeen: clearPartnerLastSeen
          ? null
          : (partnerLastSeen ?? this.partnerLastSeen),
      messages: messages ?? this.messages,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSending,
    isUploadingImage,
    socketConnected,
    isPartnerTyping,
    isPartnerOnline,
    partnerLastSeen,
    messages,
    errorMessage,
  ];
}

final chatConversationProvider = NotifierProvider.autoDispose
    .family<ChatConversationNotifier, ChatConversationState, ChatSessionArgs>(
      ChatConversationNotifier.new,
    );

class ChatConversationNotifier extends Notifier<ChatConversationState> {
  ChatConversationNotifier(this._args);

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';

  Timer? _typingDebounceTimer;
  Timer? _historySyncTimer;
  bool _typingActive = false;
  bool _initialized = false;
  String? _currentUserId;
  final ChatSessionArgs _args;
  late final ChatSocketService _socketService;

  ApiClient get _apiClient => ref.read(apiClientProvider);
  UserSessionService get _session => ref.read(userSessionServiceProvider);

  @override
  ChatConversationState build() {
    _socketService = ref.read(chatSocketServiceProvider);
    ref.onDispose(disposeResources);

    return ChatConversationState(
      isLoading: true,
      isPartnerOnline: _args.isParticipantOnline,
      partnerLastSeen: _args.participantLastSeen,
    );
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    _currentUserId = _session.getCurrentUserId();
    if (_currentUserId == null || _currentUserId!.trim().isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'User session not found. Please login again.',
      );
      return;
    }

    // Start socket + history together to minimize the window for missed events.
    await Future.wait<void>([_loadHistory(), _connectSocket()]);
    _startHistorySync();
  }

  Future<void> refreshHistory() async {
    await _loadHistory(showLoading: false);
  }

  void onTextChanged(String value) {
    if (!_socketService.isConnected) return;

    if (value.trim().isEmpty) {
      _stopTyping();
      return;
    }

    if (!_typingActive) {
      _typingActive = true;
      _socketService.sendTyping(
        conversationId: _args.conversationId,
        receiverId: _args.participantId,
      );
    }

    _typingDebounceTimer?.cancel();
    _typingDebounceTimer = Timer(
      const Duration(milliseconds: 1200),
      _stopTyping,
    );
  }

  Future<void> sendMessage(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty) return;

    final senderId = _currentUserId;
    if (senderId == null || senderId.isEmpty) {
      state = state.copyWith(
        errorMessage: 'User not found. Please login again.',
      );
      return;
    }

    _stopTyping();
    state = state.copyWith(isSending: true, clearError: true);

    final tempId = _generateClientId();
    final optimistic = MessageModel(
      id: tempId,
      conversationId: _args.conversationId,
      senderId: senderId,
      receiverId: _args.participantId,
      text: text,
      createdAt: DateTime.now(),
      deliveryStatus: MessageDeliveryStatus.pending,
      clientMessageId: tempId,
    );

    state = state.copyWith(messages: [...state.messages, optimistic]);

    try {
      if (_socketService.isConnected) {
        final ack = await _socketService.sendMessage(
          senderId: senderId,
          receiverId: _args.participantId,
          conversationId: _args.conversationId,
          text: text,
          clientMessageId: tempId,
        );

        if (ack != null && _isSuccess(ack)) {
          final serverPayload =
              _readMap(ack['message']) ?? _readMap(ack['data']) ?? ack;
          final confirmed = MessageModel.fromJson(
            serverPayload,
          ).copyWith(deliveryStatus: MessageDeliveryStatus.sent);
          _replaceByClientId(tempId, confirmed);
          state = state.copyWith(isSending: false);
          return;
        }
      }

      final response = await _apiClient.post(
        ApiEndpoints.createMessage,
        data: {
          'conversationId': _args.conversationId,
          'senderId': senderId,
          'receiverId': _args.participantId,
          'text': text,
        },
      );

      final body = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final payload =
          _readMap(body['message']) ?? _readMap(body['data']) ?? body;
      final confirmed = MessageModel.fromJson(
        payload,
      ).copyWith(deliveryStatus: MessageDeliveryStatus.sent);
      _replaceByClientId(tempId, confirmed);
      state = state.copyWith(isSending: false);
    } catch (_) {
      final failed = optimistic.copyWith(
        deliveryStatus: MessageDeliveryStatus.failed,
      );
      _replaceByClientId(tempId, failed);
      state = state.copyWith(
        isSending: false,
        errorMessage: 'Unable to send message. Please try again.',
      );
    }
  }

  Future<void> sendImage(String imagePath) async {
    final path = imagePath.trim();
    if (path.isEmpty) return;

    final senderId = _currentUserId;
    if (senderId == null || senderId.isEmpty) {
      state = state.copyWith(
        errorMessage: 'User not found. Please login again.',
      );
      return;
    }

    _stopTyping();
    state = state.copyWith(isUploadingImage: true, clearError: true);

    final tempId = _generateClientId();
    final optimistic = MessageModel(
      id: tempId,
      conversationId: _args.conversationId,
      senderId: senderId,
      receiverId: _args.participantId,
      text: '',
      imageUrl: path,
      createdAt: DateTime.now(),
      deliveryStatus: MessageDeliveryStatus.pending,
      clientMessageId: tempId,
    );

    state = state.copyWith(messages: [...state.messages, optimistic]);

    try {
      final formData = FormData.fromMap({
        'conversationId': _args.conversationId,
        'senderId': senderId,
        'receiverId': _args.participantId,
        'image': await MultipartFile.fromFile(path),
      });

      final response = await _apiClient.uploadFile(
        ApiEndpoints.createMessage,
        formData: formData,
      );

      final body = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final payload =
          _readMap(body['message']) ?? _readMap(body['data']) ?? body;
      final confirmed = MessageModel.fromJson(
        payload,
      ).copyWith(deliveryStatus: MessageDeliveryStatus.sent);
      _replaceByClientId(tempId, confirmed);
      state = state.copyWith(isUploadingImage: false);
    } catch (_) {
      final failed = optimistic.copyWith(
        deliveryStatus: MessageDeliveryStatus.failed,
      );
      _replaceByClientId(tempId, failed);
      state = state.copyWith(
        isUploadingImage: false,
        errorMessage: 'Unable to send image. Please try again.',
      );
    }
  }

  void markLatestIncomingAsSeen() {
    final latestIncoming = _latestIncomingMessage();
    if (latestIncoming == null) return;

    _socketService.markMessageSeen(
      conversationId: _args.conversationId,
      messageId: latestIncoming.id,
      receiverId: _args.participantId,
    );
  }

  Future<void> _connectSocket() async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null || token.trim().isEmpty) return;

    _socketService.connect(
      baseUrl: ApiEndpoints.baseUrl,
      token: token,
      handlers: SocketEventHandlers(
        onConnected: () {
          state = state.copyWith(socketConnected: true);
          _socketService.joinChat(
            conversationId: _args.conversationId,
            userId: _currentUserId,
          );
          // Pull latest after (re)connect to cover any events missed while offline.
          unawaited(_loadHistory(showLoading: false));
        },
        onDisconnected: () {
          state = state.copyWith(
            socketConnected: false,
            isPartnerTyping: false,
            isPartnerOnline: false,
          );
        },
        onConnectError: (_) {
          state = state.copyWith(
            socketConnected: false,
            errorMessage: 'Connection issue. Reconnecting...',
          );
        },
        onReceiveMessage: _handleReceiveMessage,
        onTypingStart: _handleTypingStart,
        onTypingStop: _handleTypingStop,
        onMessageSeen: _handleMessageSeen,
        onPresenceUpdate: _handlePresenceUpdate,
      ),
    );
  }

  Future<void> _loadHistory({bool showLoading = true}) async {
    if (showLoading) {
      state = state.copyWith(isLoading: true, clearError: true);
    } else {
      state = state.copyWith(clearError: true);
    }

    try {
      final response = await _apiClient.get(
        // This endpoint marks messages as read for the active receiver.
        ApiEndpoints.conversationMessages(_args.conversationId),
      );
      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final items = _readList(data['messages']);
      final previousById = {
        for (final message in state.messages) message.id: message,
      };
      final messages =
          items
              .map(MessageModel.fromJson)
              .where(
                (message) =>
                    message.id.isNotEmpty &&
                    message.conversationId == _args.conversationId,
              )
              .map((message) {
                final previous = previousById[message.id];
                if (previous == null) return message;
                if (previous.isRead && !message.isRead) {
                  return message.copyWith(isRead: true);
                }
                return message;
              })
              .toList()
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      state = state.copyWith(
        isLoading: false,
        messages: messages,
        clearError: true,
      );
      markLatestIncomingAsSeen();
    } on DioException catch (e) {
      final body = _readMap(e.response?.data);
      final serverMessage = _readString(body?['message']);
      state = state.copyWith(
        isLoading: false,
        errorMessage: serverMessage.isNotEmpty
            ? serverMessage
            : 'Unable to load messages. Please try again.',
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load messages. Please try again.',
      );
    }
  }

  void _handleReceiveMessage(Map<String, dynamic> payload) {
    final incoming = MessageModel.fromJson(
      payload,
    ).copyWith(deliveryStatus: MessageDeliveryStatus.sent);

    if (incoming.id.isEmpty ||
        incoming.conversationId != _args.conversationId) {
      return;
    }

    final current = [...state.messages];
    final incomingClientId = incoming.clientMessageId;

    if (incomingClientId != null && incomingClientId.isNotEmpty) {
      final pendingIndex = current.indexWhere(
        (message) => message.clientMessageId == incomingClientId,
      );

      if (pendingIndex != -1) {
        current[pendingIndex] = incoming;
      } else if (!current.any((message) => message.id == incoming.id)) {
        current.add(incoming);
      }
    } else if (!current.any((message) => message.id == incoming.id)) {
      current.add(incoming);
    }

    current.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    if (_currentUserId != null && incoming.senderId == _args.participantId) {
      for (var i = 0; i < current.length; i++) {
        final message = current[i];
        if (message.senderId == _currentUserId && !message.isRead) {
          current[i] = message.copyWith(isRead: true);
        }
      }

      _socketService.markMessageSeen(
        conversationId: _args.conversationId,
        messageId: incoming.id,
        receiverId: _args.participantId,
      );
    }

    state = state.copyWith(messages: current, isSending: false);
  }

  void _handleTypingStart(Map<String, dynamic> payload) {
    final conversationId = _readString(payload['conversationId']);
    final userId = _readString(payload['userId']);

    if (conversationId != _args.conversationId ||
        userId != _args.participantId) {
      return;
    }

    state = state.copyWith(isPartnerTyping: true);
  }

  void _handleTypingStop(Map<String, dynamic> payload) {
    final conversationId = _readString(payload['conversationId']);
    final userId = _readString(payload['userId']);

    if (conversationId != _args.conversationId ||
        userId != _args.participantId) {
      return;
    }

    state = state.copyWith(isPartnerTyping: false);
  }

  void _handlePresenceUpdate(Map<String, dynamic> payload) {
    final userId = _readString(payload['userId']);
    if (userId != _args.participantId) return;

    final status = _readString(payload['status']).toLowerCase();
    final lastSeen = _readDateTime(payload['lastSeen']);
    state = state.copyWith(
      isPartnerOnline: status == 'online',
      partnerLastSeen: lastSeen,
    );
  }

  void _handleMessageSeen(Map<String, dynamic> payload) {
    final conversationId = _readString(payload['conversationId']);
    if (conversationId.isNotEmpty && conversationId != _args.conversationId) {
      return;
    }

    final seenMessageId = _readString(payload['messageId']);
    final currentUserId = _currentUserId;
    if (currentUserId == null || currentUserId.isEmpty) return;

    final updated = [...state.messages];
    var changed = false;

    for (var i = 0; i < updated.length; i++) {
      final message = updated[i];
      if (message.senderId != currentUserId) continue;

      if (seenMessageId.isEmpty ||
          message.id == seenMessageId ||
          message.clientMessageId == seenMessageId) {
        if (!message.isRead) {
          updated[i] = message.copyWith(isRead: true);
          changed = true;
        }
      }
    }

    if (changed) {
      state = state.copyWith(messages: updated);
    }
  }

  void _replaceByClientId(String clientMessageId, MessageModel replacement) {
    final updated = [...state.messages];
    final index = updated.indexWhere(
      (message) => message.clientMessageId == clientMessageId,
    );

    if (index == -1) {
      if (!updated.any((message) => message.id == replacement.id)) {
        updated.add(replacement);
      }
    } else {
      updated[index] = replacement;
    }

    updated.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    state = state.copyWith(messages: updated);
  }

  MessageModel? _latestIncomingMessage() {
    for (var i = state.messages.length - 1; i >= 0; i--) {
      final message = state.messages[i];
      if (message.senderId == _args.participantId) {
        return message;
      }
    }
    return null;
  }

  void _stopTyping() {
    _typingDebounceTimer?.cancel();
    _typingDebounceTimer = null;

    if (!_typingActive) return;
    _typingActive = false;

    _socketService.stopTyping(
      conversationId: _args.conversationId,
      receiverId: _args.participantId,
    );
  }

  void _startHistorySync() {
    _historySyncTimer?.cancel();
    _historySyncTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (state.isLoading || state.isSending || state.isUploadingImage) {
        return;
      }

      // Poll as a safety net when socket delivery is unstable/missed.
      unawaited(_loadHistory(showLoading: false));
    });
  }

  String _generateClientId() {
    final random = Random();
    return '${DateTime.now().millisecondsSinceEpoch}-${random.nextInt(1 << 32)}';
  }

  bool _isSuccess(Map<String, dynamic> payload) {
    final value = payload['success'];
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase();
      return normalized == 'true' || normalized == '1' || normalized == 'ok';
    }
    return false;
  }

  void disposeResources() {
    _stopTyping();
    _historySyncTimer?.cancel();
    _historySyncTimer = null;
    _socketService.leaveChat(
      conversationId: _args.conversationId,
      userId: _currentUserId,
    );
    _socketService.dispose();
  }
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

Map<String, dynamic>? _readMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, data) => MapEntry(key.toString(), data));
  }
  return null;
}

List<Map<String, dynamic>> _readList(dynamic value) {
  if (value is List<dynamic>) {
    return value.map(_readMap).whereType<Map<String, dynamic>>().toList();
  }
  return const [];
}
