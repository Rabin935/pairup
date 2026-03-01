import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pairup/features/notification/domain/entities/notification_entities.dart';
import 'package:pairup/features/notification/presentation/state/notification_state.dart';
import 'package:pairup/features/notification/presentation/view_model/notification_viewmodel.dart';
import 'package:pairup/features/user/presentation/pages/public_user_profile_screen.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(notificationViewModelProvider.notifier)
          .loadNotifications(markAllRead: true);
    });
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() {
    return ref
        .read(notificationViewModelProvider.notifier)
        .loadNotifications(showLoading: false, markAllRead: true);
  }

  String _formatRelativeTime(DateTime? value) {
    if (value == null) return '';

    final now = DateTime.now();
    final difference = now.difference(value.toLocal());
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays == 1) return 'Yesterday';
    return '${difference.inDays}d ago';
  }

  String _formatAbsoluteTime(DateTime? value) {
    if (value == null) return '';

    final local = value.toLocal();
    final now = DateTime.now();
    final isSameDay =
        local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
    if (isSameDay) {
      return DateFormat('h:mm a').format(local);
    }

    final isSameYear = local.year == now.year;
    if (isSameYear) {
      return DateFormat('MMM d, h:mm a').format(local);
    }
    return DateFormat('MMM d, yyyy h:mm a').format(local);
  }

  String _formatReceivedTime(DateTime? value) {
    final absolute = _formatAbsoluteTime(value);
    if (absolute.isNotEmpty) return absolute;

    final relative = _formatRelativeTime(value);
    if (relative.isNotEmpty) return relative;
    return 'Time unavailable';
  }

  String _statusLabel(String rawStatus) {
    switch (rawStatus) {
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'declined':
        return 'Declined';
      default:
        return 'Read';
    }
  }

  Future<void> _openPublicProfile(NotificationItemEntity item) async {
    if (item.fromUserId.trim().isEmpty) return;

    ref.read(notificationViewModelProvider.notifier).markAsRead(item);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PublicUserProfileScreen(userId: item.fromUserId.trim()),
      ),
    );

    if (!mounted) return;
    await _refresh();
  }

  Widget _buildNotificationCard(
    NotificationItemEntity item,
    NotificationState state,
  ) {
    final notifier = ref.read(notificationViewModelProvider.notifier);
    final busy = state.processingKeys.contains(item.key);
    final pendingAction =
        (item.type == NotificationItemType.like ||
            item.type == NotificationItemType.invite) &&
        item.status == 'pending';

    final icon = item.type == NotificationItemType.like
        ? Icons.favorite
        : (item.type == NotificationItemType.invite
              ? Icons.person_add_alt_1
              : Icons.photo);
    final iconColor = item.type == NotificationItemType.like
        ? const Color(0xFFE53935)
        : (item.type == NotificationItemType.invite
              ? const Color(0xFF5E35B1)
              : const Color(0xFF1E88E5));

    return Container(
      decoration: BoxDecoration(
        color: item.isRead ? const Color(0xFFF8F9FC) : const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isRead
              ? const Color(0xFFE5E8F0)
              : const Color(0xFFCADBFF),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: item.isRead
                    ? const Color(0xFFAFC3F0)
                    : const Color(0xFF4B7BFF),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: const Color(0xFFEDE9FE),
                          backgroundImage: item.imageUrl.trim().isNotEmpty
                              ? NetworkImage(item.imageUrl.trim())
                              : null,
                          child: item.imageUrl.trim().isEmpty
                              ? Text(
                                  item.name.trim().isEmpty
                                      ? 'P'
                                      : item.name.trim().substring(0, 1),
                                  style: const TextStyle(
                                    color: Color(0xFF5E35B1),
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          right: -1,
                          bottom: -1,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFE5E8F0),
                              ),
                            ),
                            child: Icon(icon, size: 11, color: iconColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF5B6072),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatReceivedTime(item.createdAt),
                            style: const TextStyle(
                              color: Color(0xFF8A90A2),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (item.type == NotificationItemType.postLike)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _openPublicProfile(item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5E35B1),
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: const Text('View Profile'),
                    ),
                  )
                else if (pendingAction)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: busy
                              ? null
                              : () => notifier.respondToNotification(
                                  item,
                                  NotificationItemAction.accept,
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5E35B1),
                            foregroundColor: Colors.white,
                            elevation: 0,
                          ),
                          child: Text(busy ? 'Please wait...' : 'Accept'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: busy
                              ? null
                              : () => notifier.respondToNotification(
                                  item,
                                  NotificationItemAction.decline,
                                ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF5E35B1)),
                          ),
                          child: const Text('Decline'),
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9EDF7),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      _statusLabel(item.status),
                      style: const TextStyle(
                        color: Color(0xFF4A536B),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationViewModelProvider);
    final notifications = state.notifications;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Notifications (${state.unreadCount} unread)',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(notificationViewModelProvider.notifier).markAllAsRead();
            },
            icon: const Icon(Icons.done_all, color: Color(0xFF5E35B1)),
            tooltip: 'Mark all read',
          ),
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh, color: Colors.black87),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: state.status == NotificationStatus.loading && notifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: notifications.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 540, child: _EmptyStatePlaceholder()),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
                      itemCount: notifications.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) =>
                          _buildNotificationCard(notifications[index], state),
                    ),
            ),
      bottomNavigationBar: state.errorMessage == null || notifications.isEmpty
          ? null
          : SafeArea(
              child: Container(
                margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  state.errorMessage!,
                  style: const TextStyle(
                    color: Color(0xFF8A5B00),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
    );
  }
}

class _EmptyStatePlaceholder extends StatelessWidget {
  const _EmptyStatePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 44, color: Color(0xFFB9BBC8)),
            SizedBox(height: 10),
            Text(
              'No notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 6),
            Text(
              'Your likes, requests, and activity updates will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6A6D79)),
            ),
          ],
        ),
      ),
    );
  }
}
