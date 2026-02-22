import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

typedef SocketMapHandler = void Function(Map<String, dynamic> payload);

class SocketEventHandlers {
  final VoidCallback? onConnected;
  final VoidCallback? onDisconnected;
  final void Function(Object error)? onConnectError;
  final SocketMapHandler? onReceiveMessage;
  final SocketMapHandler? onTypingStart;
  final SocketMapHandler? onTypingStop;
  final SocketMapHandler? onMessageSeen;
  final SocketMapHandler? onPresenceUpdate;
  final SocketMapHandler? onInviteCreated;
  final SocketMapHandler? onMatchRequest;
  final SocketMapHandler? onInviteAccepted;
  final SocketMapHandler? onLikeAccepted;
  final SocketMapHandler? onChatMatchCreated;
  final SocketMapHandler? onInviteRejected;

  const SocketEventHandlers({
    this.onConnected,
    this.onDisconnected,
    this.onConnectError,
    this.onReceiveMessage,
    this.onTypingStart,
    this.onTypingStop,
    this.onMessageSeen,
    this.onPresenceUpdate,
    this.onInviteCreated,
    this.onMatchRequest,
    this.onInviteAccepted,
    this.onLikeAccepted,
    this.onChatMatchCreated,
    this.onInviteRejected,
  });
}

final chatSocketServiceProvider = Provider.autoDispose<ChatSocketService>((
  ref,
) {
  final service = ChatSocketService();
  ref.onDispose(service.dispose);
  return service;
});

class ChatSocketService {
  io.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  void connect({
    required String baseUrl,
    required String token,
    required SocketEventHandlers handlers,
  }) {
    if (_socket != null) {
      disconnect();
    }

    final socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(25)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setAuth({'token': token})
          // Backend accepts token from query as well. Keep both for reliability.
          .setQuery({'token': token})
          .build(),
    );

    _socket = socket;

    socket.onConnect((_) => handlers.onConnected?.call());
    socket.onDisconnect((_) => handlers.onDisconnected?.call());
    socket.onConnectError((error) => handlers.onConnectError?.call(error));

    // Support both backend naming styles.
    socket.on('receiveMessage', (data) {
      final map = _safeMap(data);
      if (map != null) handlers.onReceiveMessage?.call(map);
    });
    socket.on('receive_message', (data) {
      final map = _safeMap(data);
      if (map != null) handlers.onReceiveMessage?.call(map);
    });

    socket.on('typing:start', (data) {
      final map = _safeMap(data);
      if (map != null) handlers.onTypingStart?.call(map);
    });
    socket.on('typing', (data) {
      final map = _safeMap(data);
      if (map != null) handlers.onTypingStart?.call(map);
    });

    socket.on('typing:stop', (data) {
      final map = _safeMap(data);
      if (map != null) handlers.onTypingStop?.call(map);
    });
    socket.on('stop_typing', (data) {
      final map = _safeMap(data);
      if (map != null) handlers.onTypingStop?.call(map);
    });

    socket.on('message_seen', (data) {
      final map = _safeMap(data);
      if (map != null) handlers.onMessageSeen?.call(map);
    });
    socket.on('message:seen', (data) {
      final map = _safeMap(data);
      if (map != null) handlers.onMessageSeen?.call(map);
    });

    socket.on('presence:update', (data) {
      final map = _safeMap(data);
      if (map != null) handlers.onPresenceUpdate?.call(map);
    });

    socket.on('invite:created', (data) {
      final map = _safeMap(data);
      if (map != null) handlers.onInviteCreated?.call(map);
    });
    socket.on('matchRequest', (data) {
      final map = _safeMap(data);
      if (map != null) handlers.onMatchRequest?.call(map);
    });
    socket.on('invite:accepted', (data) {
      final map = _safeMap(data);
      if (map != null) handlers.onInviteAccepted?.call(map);
    });
    socket.on('like:accepted', (data) {
      final map = _safeMap(data);
      if (map != null) handlers.onLikeAccepted?.call(map);
    });
    socket.on('chat:match:created', (data) {
      final map = _safeMap(data);
      if (map != null) handlers.onChatMatchCreated?.call(map);
    });
    socket.on('invite:rejected', (data) {
      final map = _safeMap(data);
      if (map != null) handlers.onInviteRejected?.call(map);
    });

    socket.connect();
  }

  void joinChat({required String conversationId, String? userId}) {
    final socket = _socket;
    if (socket == null || !socket.connected) return;

    socket.emit('joinConversation', {
      'conversationId': conversationId,
      if (userId != null) 'userId': userId,
    });

    socket.emit('join_chat', {
      'conversationId': conversationId,
      'chatId': conversationId,
      if (userId != null) 'userId': userId,
    });
  }

  void leaveChat({required String conversationId, String? userId}) {
    final socket = _socket;
    if (socket == null || !socket.connected) return;

    socket.emit('leaveConversation', {
      'conversationId': conversationId,
      if (userId != null) 'userId': userId,
    });
    socket.emit('leave_chat', {
      'conversationId': conversationId,
      'chatId': conversationId,
      if (userId != null) 'userId': userId,
    });
  }

  Future<Map<String, dynamic>?> sendMessage({
    required String senderId,
    required String receiverId,
    required String conversationId,
    required String text,
    required String clientMessageId,
  }) async {
    final socket = _socket;
    if (socket == null || !socket.connected) return null;

    final completer = Completer<Map<String, dynamic>?>();

    socket.emitWithAck(
      'sendMessage',
      {
        'senderId': senderId,
        'receiverId': receiverId,
        'conversationId': conversationId,
        'text': text,
        'clientMessageId': clientMessageId,
      },
      ack: (data) {
        completer.complete(_safeMap(data));
      },
    );

    return completer.future.timeout(
      const Duration(seconds: 12),
      onTimeout: () => null,
    );
  }

  void sendTyping({
    required String conversationId,
    required String receiverId,
  }) {
    final socket = _socket;
    if (socket == null || !socket.connected) return;

    final payload = {
      'conversationId': conversationId,
      'receiverId': receiverId,
    };

    socket.emit('typing:start', payload);
    socket.emit('typing', payload);
  }

  void stopTyping({
    required String conversationId,
    required String receiverId,
  }) {
    final socket = _socket;
    if (socket == null || !socket.connected) return;

    final payload = {
      'conversationId': conversationId,
      'receiverId': receiverId,
    };

    socket.emit('typing:stop', payload);
    socket.emit('stop_typing', payload);
  }

  void markMessageSeen({
    required String conversationId,
    required String messageId,
    required String receiverId,
  }) {
    final socket = _socket;
    if (socket == null || !socket.connected) return;

    socket.emit('message_seen', {
      'conversationId': conversationId,
      'messageId': messageId,
      'receiverId': receiverId,
    });
  }

  void disconnect() {
    final socket = _socket;
    if (socket == null) return;
    socket.disconnect();
    socket.dispose();
    _socket = null;
  }

  void dispose() {
    disconnect();
  }
}

Map<String, dynamic>? _safeMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, data) => MapEntry(key.toString(), data));
  }
  return null;
}
