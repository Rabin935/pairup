import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pairup/core/services/storage/user_session_service.dart';
import 'package:pairup/features/notification/domain/entities/notification_entities.dart';
import 'package:pairup/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:pairup/features/notification/domain/usecases/respond_notification_usecase.dart';
import 'package:pairup/features/notification/presentation/state/notification_state.dart';

final notificationViewModelProvider =
    NotifierProvider<NotificationViewModel, NotificationState>(
      NotificationViewModel.new,
    );

class NotificationViewModel extends Notifier<NotificationState> {
  static const String _readStoragePrefix = 'pairup:notifications:read';

  late final GetNotificationsUsecase _getNotificationsUsecase;
  late final RespondNotificationUsecase _respondNotificationUsecase;
  late final UserSessionService _userSessionService;
  late final SharedPreferences _sharedPreferences;

  Timer? _pollingTimer;
  bool _isFetching = false;

  @override
  NotificationState build() {
    _getNotificationsUsecase = ref.read(getNotificationsUsecaseProvider);
    _respondNotificationUsecase = ref.read(respondNotificationUsecaseProvider);
    _userSessionService = ref.read(userSessionServiceProvider);
    _sharedPreferences = ref.read(sharedPreferencesProvider);
    _startPolling();

    ref.onDispose(() {
      _pollingTimer?.cancel();
      _pollingTimer = null;
    });
    return const NotificationState();
  }

  Future<void> loadNotifications({
    bool showLoading = true,
    bool markAllRead = false,
  }) async {
    if (_isFetching) return;
    _isFetching = true;

    if (showLoading) {
      state = state.copyWith(
        status: NotificationStatus.loading,
        clearErrorMessage: true,
      );
    } else {
      state = state.copyWith(clearErrorMessage: true);
    }

    final result = await _getNotificationsUsecase();
    result.fold(
      (failure) {
        state = state.copyWith(
          status: NotificationStatus.error,
          errorMessage: failure.message,
        );
      },
      (items) {
        final readMap = _readStoredReadMap();
        final fetched = items.map((item) {
          final readAtRaw = readMap[item.key];
          if (item.isRead || readAtRaw != null) {
            return item.copyWith(
              isRead: true,
              readAt: _tryParseDate(readAtRaw),
            );
          }
          return item;
        }).toList();

        final fetchedKeys = fetched.map((item) => item.key).toSet();
        final previousHistory = state.notifications.where((item) {
          if (fetchedKeys.contains(item.key)) return false;
          return item.status != 'pending' || item.isRead;
        });

        final merged = [...fetched, ...previousHistory];
        merged.sort((left, right) {
          final leftMs = left.createdAt?.millisecondsSinceEpoch ?? 0;
          final rightMs = right.createdAt?.millisecondsSinceEpoch ?? 0;
          return rightMs.compareTo(leftMs);
        });

        state = state.copyWith(
          status: NotificationStatus.loaded,
          notifications: merged,
          clearErrorMessage: true,
        );

        if (markAllRead) {
          markAllAsRead();
        }
      },
    );

    _isFetching = false;
  }

  Future<void> respondToNotification(
    NotificationItemEntity notification,
    NotificationItemAction action,
  ) async {
    final key = notification.key;
    if (state.processingKeys.contains(key)) return;

    if (notification.type == NotificationItemType.postLike) {
      markAsRead(notification);
      return;
    }

    state = state.copyWith(
      processingKeys: [...state.processingKeys, key],
      clearErrorMessage: true,
    );

    final result = await _respondNotificationUsecase(
      RespondNotificationUsecaseParams(
        notification: notification,
        action: action,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (_) {
        final nextStatus = _resolveActionStatus(notification.type, action);
        final now = DateTime.now();
        final updated = state.notifications.map((item) {
          if (item.key != key) return item;
          return item.copyWith(status: nextStatus, isRead: true, readAt: now);
        }).toList();

        state = state.copyWith(notifications: updated);
        _persistReadKeys({key: now.toIso8601String()});
      },
    );

    final nextProcessing = [...state.processingKeys]
      ..removeWhere((item) => item == key);
    state = state.copyWith(processingKeys: nextProcessing);
  }

  void markAsRead(NotificationItemEntity notification) {
    if (notification.isRead) return;
    final now = DateTime.now();
    final updated = state.notifications.map((item) {
      if (item.key != notification.key) return item;
      return item.copyWith(isRead: true, readAt: now);
    }).toList();
    state = state.copyWith(notifications: updated);
    _persistReadKeys({notification.key: now.toIso8601String()});
  }

  void markAllAsRead() {
    final unread = state.notifications.where((item) => !item.isRead).toList();
    if (unread.isEmpty) return;
    final now = DateTime.now();
    final updated = state.notifications
        .map(
          (item) =>
              item.isRead ? item : item.copyWith(isRead: true, readAt: now),
        )
        .toList();
    state = state.copyWith(notifications: updated);
    _persistReadKeys({
      for (final item in unread) item.key: now.toIso8601String(),
    });
  }

  void _startPolling() {
    _pollingTimer ??= Timer.periodic(const Duration(seconds: 15), (_) {
      loadNotifications(showLoading: false);
    });
  }

  String _resolveActionStatus(
    NotificationItemType type,
    NotificationItemAction action,
  ) {
    if (action == NotificationItemAction.accept) {
      return 'accepted';
    }
    if (type == NotificationItemType.invite) {
      return 'rejected';
    }
    return 'declined';
  }

  String _storageKey() {
    final userId = _userSessionService.getCurrentUserId();
    final normalized = (userId ?? 'anonymous').trim();
    return '$_readStoragePrefix:$normalized';
  }

  Map<String, String> _readStoredReadMap() {
    final raw = _sharedPreferences.getString(_storageKey());
    if (raw == null || raw.trim().isEmpty) {
      return {};
    }

    try {
      final parsed = jsonDecode(raw);
      if (parsed is! Map) return {};

      final normalized = <String, String>{};
      parsed.forEach((key, value) {
        final mapKey = key.toString().trim();
        final mapValue = value?.toString().trim() ?? '';
        if (mapKey.isNotEmpty && mapValue.isNotEmpty) {
          normalized[mapKey] = mapValue;
        }
      });
      return normalized;
    } catch (_) {
      return {};
    }
  }

  void _persistReadKeys(Map<String, String> keysToStore) {
    if (keysToStore.isEmpty) return;

    final existing = _readStoredReadMap();
    final merged = <String, String>{...existing, ...keysToStore};
    _sharedPreferences.setString(_storageKey(), jsonEncode(merged));
  }
}

DateTime? _tryParseDate(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return DateTime.tryParse(value.trim());
}
