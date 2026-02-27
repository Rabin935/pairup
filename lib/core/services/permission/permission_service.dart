import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/services/storage/user_session_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppPermissionType { camera, notifications, sensors }

class PermissionService {
  final DeviceInfoPlugin _deviceInfo;
  final SharedPreferences _prefs;
  static const _startupPermissionAskedPrefix = 'startup_permission_asked_';

  PermissionService({
    required SharedPreferences prefs,
    DeviceInfoPlugin? deviceInfo,
  }) : _prefs = prefs,
       _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  Future<Map<AppPermissionType, PermissionStatus>> requestStartupPermissions(
    BuildContext context,
  ) async {
    final requests = await _buildStartupRequests();
    if (!context.mounted) return <AppPermissionType, PermissionStatus>{};
    final result = <AppPermissionType, PermissionStatus>{};

    for (final request in requests) {
      final currentStatus = await request.permission.status;
      if (currentStatus.isGranted) {
        result[request.type] = currentStatus;
        continue;
      }

      final askedBefore =
          _prefs.getBool(_startupPermissionKey(request.type)) ?? false;
      if (askedBefore) {
        result[request.type] = currentStatus;
        continue;
      }

      if (!context.mounted) {
        result[request.type] = currentStatus;
        continue;
      }

      final status = await requestPermissionWithDialog(
        context: context,
        permission: request.permission,
        title: request.title,
        message: request.message,
      );
      result[request.type] = status;
      await _prefs.setBool(_startupPermissionKey(request.type), true);
    }

    return result;
  }

  Future<PermissionStatus> requestPermissionWithDialog({
    required BuildContext context,
    required Permission permission,
    required String title,
    required String message,
  }) async {
    var status = await permission.status;
    if (status.isGranted) return status;

    if (!status.isPermanentlyDenied && !status.isRestricted) {
      status = await permission.request();
    }

    if (!status.isGranted && context.mounted) {
      await _showDeniedDialog(context, title: title, message: message);
    }

    return status;
  }

  Future<List<_PermissionRequest>> _buildStartupRequests() async {
    final requests = <_PermissionRequest>[
      const _PermissionRequest(
        type: AppPermissionType.camera,
        permission: Permission.camera,
        title: 'Camera Permission Required',
        message:
            'PairUp needs camera access so you can take profile photos and use the in-app camera features.',
      ),
      const _PermissionRequest(
        type: AppPermissionType.sensors,
        permission: Permission.sensors,
        title: 'Sensor Permission Required',
        message:
            'PairUp uses light and motion sensors (gyroscope/accelerometer) to enhance app interactions and safety features.',
      ),
    ];

    if (await _supportsRuntimeNotificationPermission()) {
      requests.insert(
        1,
        const _PermissionRequest(
          type: AppPermissionType.notifications,
          permission: Permission.notification,
          title: 'Notification Permission Required',
          message:
              'Enable notifications to receive new message alerts and match updates instantly.',
        ),
      );
    }

    return requests;
  }

  Future<bool> _supportsRuntimeNotificationPermission() async {
    if (!Platform.isAndroid) return true;

    final info = await _deviceInfo.androidInfo;
    return info.version.sdkInt >= 33;
  }

  Future<void> _showDeniedDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Not now'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await openAppSettings();
              },
              child: const Text('Open settings'),
            ),
          ],
        );
      },
    );
  }

  String _startupPermissionKey(AppPermissionType type) {
    return '$_startupPermissionAskedPrefix${type.name}';
  }
}

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService(prefs: ref.read(sharedPreferencesProvider));
});

class _PermissionRequest {
  final AppPermissionType type;
  final Permission permission;
  final String title;
  final String message;

  const _PermissionRequest({
    required this.type,
    required this.permission,
    required this.title,
    required this.message,
  });
}
