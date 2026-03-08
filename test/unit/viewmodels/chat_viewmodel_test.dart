import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pairup/core/api/api_client.dart';
import 'package:pairup/core/services/storage/user_session_service.dart';
import 'package:pairup/features/chat/data/services/socket_service.dart';
import 'package:pairup/features/chat/presentation/providers/chat_provider.dart';

import '../test_helpers/mocks.dart';
import '../test_helpers/widget_test_utils.dart';

void main() {
  const args = ChatSessionArgs(
    conversationId: 'chat-1',
    participantId: 'user-2',
    participantName: 'Taylor',
  );

  late MockApiClient apiClient;
  late MockUserSessionService userSessionService;
  late MockChatSocketService socketService;
  late ProviderContainer container;
  late SocketEventHandlers capturedHandlers;

  setUpAll(registerCommonFallbackValues);

  setUp(() {
    setupFlutterSecureStorageMock(token: 'token-1');

    apiClient = MockApiClient();
    userSessionService = MockUserSessionService();
    socketService = MockChatSocketService();

    when(() => userSessionService.getCurrentUserId()).thenReturn('user-1');
    when(() => socketService.isConnected).thenReturn(false);
    when(
      () => socketService.connect(
        baseUrl: any(named: 'baseUrl'),
        token: any(named: 'token'),
        handlers: any(named: 'handlers'),
      ),
    ).thenAnswer((invocation) {
      capturedHandlers = invocation.namedArguments[#handlers] as SocketEventHandlers;
    });

    when(
      () => socketService.joinChat(
        conversationId: any(named: 'conversationId'),
        userId: any(named: 'userId'),
      ),
    ).thenReturn(null);
    when(
      () => socketService.leaveChat(
        conversationId: any(named: 'conversationId'),
        userId: any(named: 'userId'),
      ),
    ).thenReturn(null);
    when(() => socketService.dispose()).thenReturn(null);
    when(
      () => socketService.sendTyping(
        conversationId: any(named: 'conversationId'),
        receiverId: any(named: 'receiverId'),
      ),
    ).thenReturn(null);
    when(
      () => socketService.stopTyping(
        conversationId: any(named: 'conversationId'),
        receiverId: any(named: 'receiverId'),
      ),
    ).thenReturn(null);
    when(
      () => socketService.markMessageSeen(
        conversationId: any(named: 'conversationId'),
        messageId: any(named: 'messageId'),
        receiverId: any(named: 'receiverId'),
      ),
    ).thenReturn(null);

    when(() => apiClient.get(any())).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: '/api/conversations/chat-1/messages'),
        data: <String, dynamic>{'messages': <dynamic>[]},
        statusCode: 200,
      ),
    );

    container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWith((ref) => apiClient),
        userSessionServiceProvider.overrideWith((ref) => userSessionService),
        chatSocketServiceProvider.overrideWith((ref) => socketService),
      ],
    );

    addTearDown(() {
      tearDownFlutterSecureStorageMock();
      container.dispose();
    });
  });

  test('ChatViewModel send message handles loading, success, and error states', () async {
    final postSuccessCompleter = Completer<Response<dynamic>>();
    when(
      () => apiClient.post(any(), data: any(named: 'data')),
    ).thenAnswer((_) => postSuccessCompleter.future);

    final notifier = container.read(chatConversationProvider(args).notifier);
    await notifier.initialize();

    final successFuture = notifier.sendMessage('Hello');
    expect(container.read(chatConversationProvider(args)).isSending, isTrue);

    postSuccessCompleter.complete(
      Response<dynamic>(
        requestOptions: RequestOptions(path: '/api/messages'),
        data: <String, dynamic>{
          'message': <String, dynamic>{
            'id': 'm-1',
            'conversationId': 'chat-1',
            'senderId': 'user-1',
            'receiverId': 'user-2',
            'body': 'Hello',
            'createdAt': DateTime(2026, 1, 1, 10).toIso8601String(),
            'read': false,
          },
        },
        statusCode: 200,
      ),
    );
    await successFuture;
    final successState = container.read(chatConversationProvider(args));
    expect(successState.isSending, isFalse);
    expect(successState.messages.any((message) => message.text == 'Hello'), isTrue);

    final postErrorCompleter = Completer<Response<dynamic>>();
    when(
      () => apiClient.post(any(), data: any(named: 'data')),
    ).thenAnswer((_) => postErrorCompleter.future);

    final errorFuture = notifier.sendMessage('Fail case');
    expect(container.read(chatConversationProvider(args)).isSending, isTrue);

    postErrorCompleter.completeError(Exception('send failed'));
    await errorFuture;
    final errorState = container.read(chatConversationProvider(args));
    expect(errorState.isSending, isFalse);
    expect(errorState.errorMessage, 'Unable to send message. Please try again.');
  });

  test('ChatViewModel receive message handles loading, success, and error states', () async {
    final notifier = container.read(chatConversationProvider(args).notifier);

    expect(container.read(chatConversationProvider(args)).isLoading, isTrue);
    await notifier.initialize();
    expect(container.read(chatConversationProvider(args)).isLoading, isFalse);

    capturedHandlers.onReceiveMessage?.call(<String, dynamic>{
      'id': 'incoming-1',
      'conversationId': 'chat-1',
      'senderId': 'user-2',
      'receiverId': 'user-1',
      'body': 'Hi there',
      'createdAt': DateTime(2026, 1, 1, 11).toIso8601String(),
      'read': false,
    });

    final successState = container.read(chatConversationProvider(args));
    expect(successState.messages.any((message) => message.id == 'incoming-1'), isTrue);

    when(() => apiClient.get(any())).thenThrow(Exception('history failed'));

    await notifier.refreshHistory();
    expect(
      container.read(chatConversationProvider(args)).errorMessage,
      'Unable to load messages. Please try again.',
    );
  });

  test('ChatViewModel load messages handles loading, success, and error states', () async {
    when(() => apiClient.get(any())).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: '/api/conversations/chat-1/messages'),
        data: <String, dynamic>{
          'messages': <dynamic>[
            <String, dynamic>{
              'id': 'm-1',
              'conversationId': 'chat-1',
              'senderId': 'user-2',
              'receiverId': 'user-1',
              'body': 'Loaded message',
              'createdAt': DateTime(2026, 1, 1, 9).toIso8601String(),
              'read': false,
            },
          ],
        },
        statusCode: 200,
      ),
    );

    final notifier = container.read(chatConversationProvider(args).notifier);

    expect(container.read(chatConversationProvider(args)).isLoading, isTrue);
    await notifier.initialize();

    final successState = container.read(chatConversationProvider(args));
    expect(successState.isLoading, isFalse);
    expect(successState.messages.length, 1);

    when(() => apiClient.get(any())).thenThrow(Exception('load failed'));

    await notifier.refreshHistory();
    expect(
      container.read(chatConversationProvider(args)).errorMessage,
      'Unable to load messages. Please try again.',
    );
  });

  test('ChatViewModel typing indicator handles loading, success, and error states', () async {
    when(() => socketService.isConnected).thenReturn(true);

    final notifier = container.read(chatConversationProvider(args).notifier);

    expect(container.read(chatConversationProvider(args)).isLoading, isTrue);
    await notifier.initialize();

    notifier.onTextChanged('Typing now');
    verify(
      () => socketService.sendTyping(
        conversationId: 'chat-1',
        receiverId: 'user-2',
      ),
    ).called(1);

    capturedHandlers.onTypingStart?.call(<String, dynamic>{
      'conversationId': 'chat-1',
      'userId': 'user-2',
    });

    expect(container.read(chatConversationProvider(args)).isPartnerTyping, isTrue);

    when(() => apiClient.get(any())).thenThrow(Exception('typing error source'));
    await notifier.refreshHistory();

    expect(
      container.read(chatConversationProvider(args)).errorMessage,
      'Unable to load messages. Please try again.',
    );
  });
}
