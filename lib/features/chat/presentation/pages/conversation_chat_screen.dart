import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pairup/core/api/api_endpoint.dart';
import 'package:pairup/core/services/storage/user_session_service.dart';
import 'package:pairup/features/chat/data/models/message_model.dart';
import 'package:pairup/features/chat/presentation/providers/chat_provider.dart';

class ConversationChatScreen extends StatelessWidget {
  final ChatSessionArgs args;

  const ConversationChatScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return _ConversationChatView(args: args);
  }
}

class _ConversationChatView extends ConsumerStatefulWidget {
  final ChatSessionArgs args;

  const _ConversationChatView({required this.args});

  @override
  ConsumerState<_ConversationChatView> createState() =>
      _ConversationChatScreenState();
}

class _ConversationChatScreenState
    extends ConsumerState<_ConversationChatView> {
  late final TextEditingController _messageController;
  late final ScrollController _scrollController;
  final ImagePicker _imagePicker = ImagePicker();
  late final String _currentUserId;
  int _lastMessageCount = 0;
  bool _lastTypingState = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _currentUserId =
        ref.read(userSessionServiceProvider).getCurrentUserId() ?? '';

    Future.microtask(() {
      ref.read(chatConversationProvider(widget.args).notifier).initialize();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToLatest({bool smooth = true}) {
    if (!_scrollController.hasClients) return;
    if (smooth) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(0);
    }
  }

  String _formatStatusText(bool isOnline, DateTime? lastSeen, bool isTyping) {
    if (isTyping) return 'Typing...';
    if (isOnline) return 'Online';
    if (lastSeen != null) {
      final now = DateTime.now();
      final diff = now.difference(lastSeen);
      if (diff.inMinutes < 1) return 'Last seen just now';
      if (diff.inMinutes < 60) return 'Last seen ${diff.inMinutes}m ago';
      if (diff.inHours < 24) return 'Last seen ${diff.inHours}h ago';
      return 'Last seen ${DateFormat('dd MMM, hh:mm a').format(lastSeen)}';
    }
    return 'Offline';
  }

  String _formatTime(DateTime value) {
    return DateFormat('hh:mm a').format(value);
  }

  String _messageStatus(MessageModel message) {
    if (message.deliveryStatus == MessageDeliveryStatus.pending) {
      return 'Sending...';
    }
    if (message.deliveryStatus == MessageDeliveryStatus.failed) {
      return 'Failed';
    }
    return message.isRead ? 'Seen' : 'Sent';
  }

  Future<void> _onSend() async {
    final text = _messageController.text;
    if (text.trim().isEmpty) return;
    _messageController.clear();
    await ref
        .read(chatConversationProvider(widget.args).notifier)
        .sendMessage(text);
    _scrollToLatest();
  }

  Future<void> _onPickImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;

    await ref
        .read(chatConversationProvider(widget.args).notifier)
        .sendImage(picked.path);
    _scrollToLatest();
  }

  Widget _buildMessageContent(MessageModel message, bool isMine) {
    final children = <Widget>[];

    if (message.hasImage) {
      final raw = message.imageUrl.trim();
      if (_isLocalImagePath(raw)) {
        children.add(
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(raw),
                  width: 210,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 210,
                      height: 150,
                      color: Colors.black12,
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image_outlined),
                    );
                  },
                ),
              ),
              if (message.deliveryStatus == MessageDeliveryStatus.pending)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      } else {
        children.add(
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              _resolveImageUrl(raw),
              width: 210,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 210,
                  height: 150,
                  color: Colors.black12,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image_outlined),
                );
              },
            ),
          ),
        );
      }
    }

    if (message.hasText) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(height: 8));
      }
      children.add(
        Text(
          message.text,
          style: TextStyle(
            color: isMine ? Colors.white : Colors.black87,
            fontSize: 14,
          ),
        ),
      );
    }

    if (children.isEmpty) {
      children.add(
        Text(
          'Message',
          style: TextStyle(
            color: isMine ? Colors.white : Colors.black87,
            fontSize: 14,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatConversationProvider(widget.args));
    final notifier = ref.read(chatConversationProvider(widget.args).notifier);
    final messages = state.messages.reversed.toList();

    if (_lastMessageCount != state.messages.length ||
        _lastTypingState != state.isPartnerTyping) {
      _lastMessageCount = state.messages.length;
      _lastTypingState = state.isPartnerTyping;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToLatest();
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFEDE9FE),
              backgroundImage: _safeNetworkImage(widget.args.participantAvatar),
              child: widget.args.participantAvatar.trim().isEmpty
                  ? Text(
                      widget.args.participantName.trim().isEmpty
                          ? 'P'
                          : widget.args.participantName
                                .trim()
                                .substring(0, 1)
                                .toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF5E35B1),
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.args.participantName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: state.isPartnerOnline
                              ? Colors.green
                              : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _formatStatusText(
                            state.isPartnerOnline,
                            state.partnerLastSeen,
                            state.isPartnerTyping,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Builder(
              builder: (context) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.errorMessage != null && state.messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 32,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            state.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton(
                            onPressed: notifier.refreshHistory,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet. Say hello!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  itemCount: messages.length + (state.isPartnerTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (state.isPartnerTyping && index == 0) {
                      return const _TypingBubble();
                    }

                    final messageIndex = state.isPartnerTyping
                        ? index - 1
                        : index;
                    final message = messages[messageIndex];
                    final isMine = message.senderId == _currentUserId;

                    return Align(
                      alignment: isMine
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.74,
                          ),
                          child: Column(
                            crossAxisAlignment: isMine
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isMine
                                      ? const Color(0xFF5E35B1)
                                      : const Color(0xFFF2F2F2),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: Radius.circular(
                                      isMine ? 16 : 4,
                                    ),
                                    bottomRight: Radius.circular(
                                      isMine ? 4 : 16,
                                    ),
                                  ),
                                ),
                                child: _buildMessageContent(message, isMine),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _formatTime(message.createdAt),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 10.5,
                                    ),
                                  ),
                                  if (isMine) ...[
                                    const SizedBox(width: 6),
                                    Text(
                                      _messageStatus(message),
                                      style: TextStyle(
                                        color: message.isRead
                                            ? Colors.green[700]
                                            : Colors.grey[600],
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (state.errorMessage != null && state.messages.isNotEmpty)
            Container(
              width: double.infinity,
              color: const Color(0xFFFFF4E5),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                state.errorMessage!,
                style: const TextStyle(color: Color(0xFF8A5B00), fontSize: 12),
              ),
            ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: state.isUploadingImage ? null : _onPickImage,
                    icon: Icon(
                      Icons.image_outlined,
                      color: state.isUploadingImage
                          ? Colors.grey
                          : const Color(0xFF5E35B1),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                      onChanged: notifier.onTextChanged,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                          borderSide: BorderSide(color: Color(0xFF5E35B1)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: (state.isSending || state.isUploadingImage)
                        ? null
                        : _onSend,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: (state.isSending || state.isUploadingImage)
                            ? const Color(0xFFB8A5DA)
                            : const Color(0xFF5E35B1),
                        shape: BoxShape.circle,
                      ),
                      child: (state.isSending || state.isUploadingImage)
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

NetworkImage? _safeNetworkImage(String rawUrl) {
  final resolved = _resolveImageUrl(rawUrl);
  if (resolved.isEmpty) return null;

  final uri = Uri.tryParse(resolved);
  if (uri == null || uri.scheme.isEmpty || uri.host.isEmpty) {
    return null;
  }

  return NetworkImage(resolved);
}

String _resolveImageUrl(String rawUrl) {
  final value = rawUrl.trim();
  if (value.isEmpty) return '';

  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }

  if (value.startsWith('/')) {
    return '${ApiEndpoints.baseUrl}$value';
  }

  return '${ApiEndpoints.baseUrl}/$value';
}

bool _isLocalImagePath(String rawUrl) {
  final value = rawUrl.trim();
  if (value.isEmpty) return false;

  if (value.startsWith('http://') || value.startsWith('https://')) {
    return false;
  }

  if (value.startsWith('/uploads/') || value.startsWith('uploads/')) {
    return false;
  }

  if (RegExp(r'^[a-zA-Z]+://').hasMatch(value)) {
    return false;
  }

  return true;
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              _TypingDot(delay: 0),
              SizedBox(width: 3),
              _TypingDot(delay: 200),
              SizedBox(width: 3),
              _TypingDot(delay: 400),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  final int delay;

  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.4,
      upperBound: 1,
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (!mounted) return;
      _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
