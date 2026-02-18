import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/api/api_client.dart';
import 'package:pairup/core/api/api_endpoint.dart';
import 'package:pairup/features/chat/domain/entities/chat_entities.dart';
import 'package:pairup/features/chat/presentation/pages/conversation_chat_screen.dart';
import 'package:pairup/features/chat/presentation/providers/chat_provider.dart';
import 'package:pairup/features/chat/presentation/state/chat_state.dart';
import 'package:pairup/features/chat/presentation/view_model/chat_viewmodel.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late final PageController _pageController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedTabIndex);
    Future.microtask(() {
      ref.read(chatViewModelProvider.notifier).loadChatOverview();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _refresh() {
    return ref.read(chatViewModelProvider.notifier).loadChatOverview();
  }

  Future<String?> _startConversation(String participantId) async {
    try {
      final response = await ref
          .read(apiClientProvider)
          .post(
            ApiEndpoints.conversations,
            data: {'participantId': participantId},
          );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final conversationId = data['conversationId']?.toString().trim();
        if (conversationId != null && conversationId.isNotEmpty) {
          return conversationId;
        }
        final nested = data['data'];
        if (nested is Map<String, dynamic>) {
          final nestedConversationId = nested['conversationId']
              ?.toString()
              .trim();
          if (nestedConversationId != null && nestedConversationId.isNotEmpty) {
            return nestedConversationId;
          }
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open conversation right now'),
          ),
        );
      }
    }
    return null;
  }

  Future<void> _openConversation({
    required String conversationId,
    required String participantId,
    required String participantName,
    required String participantAvatar,
    required bool isOnline,
    DateTime? lastSeen,
  }) async {
    ref
        .read(chatViewModelProvider.notifier)
        .setActiveConversation(conversationId);
    ref
        .read(chatViewModelProvider.notifier)
        .markConversationAsRead(conversationId);

    try {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ConversationChatScreen(
            args: ChatSessionArgs(
              conversationId: conversationId,
              participantId: participantId,
              participantName: participantName,
              participantAvatar: participantAvatar,
              isParticipantOnline: isOnline,
              participantLastSeen: lastSeen,
            ),
          ),
        ),
      );
    } finally {
      ref.read(chatViewModelProvider.notifier).setActiveConversation(null);
    }

    if (!mounted) return;
    await _refresh();
  }

  void _onTabTap(int index) {
    if (_selectedTabIndex == index) return;
    setState(() => _selectedTabIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  String _formatRelativeTime(DateTime? value) {
    if (value == null) return 'Recently';

    final now = DateTime.now();
    final difference = now.difference(value);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${value.day}/${value.month}/${value.year}';
  }

  String _requestActionKey(MatchRequestEntity request) {
    final senderId = (request.senderId ?? request.participantId ?? '').trim();
    return '${request.type.name}:${request.id}:$senderId';
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchRequestPage(
    List<MatchRequestEntity> requests,
    List<String> processingRequestKeys,
  ) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: requests.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: 520,
                  child: _buildEmptyState(
                    icon: Icons.favorite_border,
                    title: 'No match requests',
                    subtitle: 'New likes and invites will appear here.',
                  ),
                ),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: requests.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final request = requests[index];
                final isLike = request.type == MatchRequestType.like;
                final icon = isLike ? Icons.favorite : Icons.person_add_alt_1;
                final iconColor = isLike
                    ? const Color(0xFFE53935)
                    : const Color(0xFF5E35B1);
                final subtitle = request.subtitle.isEmpty
                    ? (isLike ? 'Liked your profile' : 'Invitation request')
                    : request.subtitle;
                final actionKey = _requestActionKey(request);
                final isProcessing = processingRequestKeys.contains(actionKey);
                final notifier = ref.read(chatViewModelProvider.notifier);

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFECECEC)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _UserAvatar(
                            name: request.name,
                            imageUrl: request.avatarUrl,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  request.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Icon(icon, size: 18, color: iconColor),
                              const SizedBox(height: 6),
                              Text(
                                _formatRelativeTime(request.createdAt),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isProcessing
                                  ? null
                                  : () => notifier.declineMatchRequest(request),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(40),
                                side: const BorderSide(
                                  color: Color(0xFF5E35B1),
                                ),
                              ),
                              child: const Text('Decline'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isProcessing
                                  ? null
                                  : () => notifier.acceptMatchRequest(request),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(40),
                                backgroundColor: const Color(0xFF5E35B1),
                                foregroundColor: Colors.white,
                                elevation: 0,
                              ),
                              child: isProcessing
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text('Accept'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildNewRequestPage(List<NewRequestEntity> newRequests) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: newRequests.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: 520,
                  child: _buildEmptyState(
                    icon: Icons.auto_awesome_outlined,
                    title: 'No new requests',
                    subtitle: 'Your new matches will appear here.',
                  ),
                ),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: newRequests.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final request = newRequests[index];
                return InkWell(
                  onTap: () async {
                    final conversationId = await _startConversation(request.id);
                    if (conversationId == null ||
                        conversationId.isEmpty ||
                        !mounted) {
                      return;
                    }
                    await _openConversation(
                      conversationId: conversationId,
                      participantId: request.id,
                      participantName: request.name,
                      participantAvatar: request.avatarUrl,
                      isOnline: request.isOnline,
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFECECEC)),
                    ),
                    child: Row(
                      children: [
                        _UserAvatar(
                          name: request.name,
                          imageUrl: request.avatarUrl,
                          isOnline: request.isOnline,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                request.isOnline
                                    ? 'Online now'
                                    : 'Recently active',
                                style: TextStyle(
                                  color: request.isOnline
                                      ? Colors.green[700]
                                      : Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildChatPage(List<ChatThreadEntity> chats) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: chats.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: 520,
                  child: _buildEmptyState(
                    icon: Icons.chat_bubble_outline,
                    title: 'No chats yet',
                    subtitle: 'Start a match to begin chatting.',
                  ),
                ),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: chats.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final chat = chats[index];
                return InkWell(
                  onTap: () async {
                    await _openConversation(
                      conversationId: chat.id,
                      participantId: chat.participant.id,
                      participantName: chat.participant.name,
                      participantAvatar: chat.participant.avatarUrl,
                      isOnline: chat.participant.isOnline,
                      lastSeen: chat.participant.lastSeen,
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFECECEC)),
                    ),
                    child: Row(
                      children: [
                        _UserAvatar(
                          name: chat.participant.name,
                          imageUrl: chat.participant.avatarUrl,
                          isOnline: chat.participant.isOnline,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chat.participant.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                chat.lastMessage.isEmpty
                                    ? 'Say hello'
                                    : chat.lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatRelativeTime(chat.lastMessageAt),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (chat.unreadCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF5E35B1),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(
                                  chat.unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            else
                              const SizedBox(height: 18),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatViewModelProvider);
    final overview = state.overview;
    final unreadChatCount = overview.chats.fold<int>(
      0,
      (total, chat) => total + chat.unreadCount,
    );
    final hasData =
        overview.matchRequests.isNotEmpty ||
        overview.newRequests.isNotEmpty ||
        overview.chats.isNotEmpty;

    final tabs = [
      _TabData(label: 'Match Requests', count: overview.matchRequests.length),
      _TabData(label: 'New Requests', count: overview.newRequests.length),
      _TabData(label: 'Chats', count: unreadChatCount),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Chats',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
            child: Row(
              children: List.generate(tabs.length, (index) {
                final tab = tabs[index];
                final selected = _selectedTabIndex == index;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index == tabs.length - 1 ? 0 : 8,
                    ),
                    child: _TabButton(
                      label: tab.label,
                      count: tab.count,
                      selected: selected,
                      onTap: () => _onTabTap(index),
                    ),
                  ),
                );
              }),
            ),
          ),
          if (state.errorMessage != null && hasData)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                state.errorMessage!,
                style: const TextStyle(color: Color(0xFF8A5B00), fontSize: 12),
              ),
            ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (state.status == ChatStatus.loading && !hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == ChatStatus.error && !hasData) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 36,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            state.errorMessage ?? 'Unable to load chat data',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton(
                            onPressed: _refresh,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    if (_selectedTabIndex != index) {
                      setState(() => _selectedTabIndex = index);
                    }
                  },
                  children: [
                    _buildMatchRequestPage(
                      overview.matchRequests,
                      state.processingRequestKeys,
                    ),
                    _buildNewRequestPage(overview.newRequests),
                    _buildChatPage(overview.chats),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final String name;
  final String imageUrl;
  final bool isOnline;

  const _UserAvatar({
    required this.name,
    required this.imageUrl,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final initial = trimmed.isEmpty
        ? 'P'
        : trimmed.substring(0, 1).toUpperCase();

    return Stack(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFFEDE9FE),
          backgroundImage: _safeNetworkImage(imageUrl),
          child: imageUrl.trim().isEmpty
              ? Text(
                  initial,
                  style: const TextStyle(
                    color: Color(0xFF5E35B1),
                    fontWeight: FontWeight.w700,
                  ),
                )
              : null,
        ),
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
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

class _TabButton extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = selected
        ? const Color(0xFF5E35B1)
        : const Color(0xFFF2F2F2);
    final textColor = selected ? Colors.white : const Color(0xFF444444);
    final badgeBg = selected ? Colors.white : const Color(0xFFE3E3E3);
    final badgeText = selected
        ? const Color(0xFF5E35B1)
        : const Color(0xFF555555);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  color: badgeText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabData {
  final String label;
  final int count;

  const _TabData({required this.label, required this.count});
}
