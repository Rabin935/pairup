import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pairup/core/api/api_client.dart';
import 'package:pairup/core/services/storage/user_session_service.dart';
import 'package:pairup/core/utils/snackbar_helper.dart';
import 'package:pairup/features/auth/presentation/pages/login_screen.dart';
import 'package:pairup/features/auth/presentation/view_model/auth_viewmodel.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';

  bool _isLoading = true;
  bool _isUpdating = false;

  bool _onlineVisibility = true;

  bool _likesNotification = true;
  bool _postLikesNotification = true;
  bool _matchesNotification = true;
  bool _messagesNotification = true;

  bool _showAge = true;
  bool _showLocation = true;
  bool _showOnlineStatus = true;

  List<dynamic> _blockedUsers = [];
  List<dynamic> _connections = [];

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  String _text(dynamic value, [String fallback = '']) {
    final t = (value ?? '').toString().trim();
    return t.isEmpty ? fallback : t;
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final responses = await Future.wait([
        _apiClient.get('/api/users/me/settings'),
        _apiClient.get('/api/users/blocks'),
        _apiClient.get('/api/connections'),
      ]);

      final settingsBody = responses[0].data as Map<String, dynamic>;
      final blockedBody = responses[1].data as Map<String, dynamic>;
      final connectionsBody = responses[2].data as Map<String, dynamic>;

      final settings = (settingsBody['data'] as Map<String, dynamic>?) ?? {};
      final notification = (settings['notificationPreferences'] as Map<String, dynamic>?) ?? {};
      final privacy = (settings['privacy'] as Map<String, dynamic>?) ?? {};

      if (!mounted) return;

      setState(() {
        _onlineVisibility = (settings['onlineVisibility'] as bool?) ?? true;

        _likesNotification = (notification['likes'] as bool?) ?? true;
        _postLikesNotification = (notification['postLikes'] as bool?) ?? true;
        _matchesNotification = (notification['matches'] as bool?) ?? true;
        _messagesNotification = (notification['messages'] as bool?) ?? true;

        _showAge = (privacy['showAge'] as bool?) ?? true;
        _showLocation = (privacy['showLocation'] as bool?) ?? true;
        _showOnlineStatus = (privacy['showOnlineStatus'] as bool?) ?? true;

        _blockedUsers = (blockedBody['data'] as List<dynamic>?) ?? [];
        _connections = (connectionsBody['connections'] as List<dynamic>?) ?? [];
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showCustomErrorSnackBar(context, 'Unable to load settings');
    }
  }

  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    if (currentPassword.isEmpty || newPassword.length < 6) {
      showCustomErrorSnackBar(context, 'Enter current password and new password (min 6 chars)');
      return;
    }

    setState(() => _isUpdating = true);
    try {
      final response = await _apiClient.patch(
        '/api/users/settings/password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      final body = response.data as Map<String, dynamic>;
      if (!mounted) return;

      if (body['success'] == true) {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        showCustomSuccessSnackBar(context, 'Password changed successfully');
      } else {
        showCustomErrorSnackBar(context, _text(body['message'], 'Unable to change password'));
      }
    } catch (_) {
      if (!mounted) return;
      showCustomErrorSnackBar(context, 'Unable to change password');
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _setVisibility(bool value) async {
    setState(() => _onlineVisibility = value);
    try {
      await _apiClient.patch('/api/users/settings/visibility', data: {'onlineVisibility': value});
      if (!mounted) return;
      showCustomSuccessSnackBar(context, 'Visibility updated');
    } catch (_) {
      if (!mounted) return;
      setState(() => _onlineVisibility = !value);
      showCustomErrorSnackBar(context, 'Unable to update visibility');
    }
  }

  Future<void> _setNotifications() async {
    try {
      await _apiClient.patch(
        '/api/users/settings/notifications',
        data: {
          'likes': _likesNotification,
          'postLikes': _postLikesNotification,
          'matches': _matchesNotification,
          'messages': _messagesNotification,
        },
      );
    } catch (_) {
      if (!mounted) return;
      showCustomErrorSnackBar(context, 'Unable to update notifications');
      await _loadSettings();
    }
  }

  Future<void> _setPrivacy() async {
    try {
      await _apiClient.patch(
        '/api/users/settings/privacy',
        data: {
          'showAge': _showAge,
          'showLocation': _showLocation,
          'showOnlineStatus': _showOnlineStatus,
        },
      );
    } catch (_) {
      if (!mounted) return;
      showCustomErrorSnackBar(context, 'Unable to update privacy settings');
      await _loadSettings();
    }
  }

  Future<void> _blockUser(String userId) async {
    try {
      await _apiClient.post('/api/users/block/$userId');
      if (!mounted) return;
      showCustomSuccessSnackBar(context, 'User blocked');
      await _loadSettings();
    } catch (_) {
      if (!mounted) return;
      showCustomErrorSnackBar(context, 'Unable to block user');
    }
  }

  Future<void> _unblockUser(String userId) async {
    try {
      await _apiClient.delete('/api/users/block/$userId');
      if (!mounted) return;
      showCustomSuccessSnackBar(context, 'User unblocked');
      await _loadSettings();
    } catch (_) {
      if (!mounted) return;
      showCustomErrorSnackBar(context, 'Unable to unblock user');
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text('Are you sure you want to permanently delete your account?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _isUpdating = true);
    try {
      final response = await _apiClient.delete('/api/users/me');
      final body = response.data as Map<String, dynamic>;

      if (!mounted) return;

      if (body['success'] == true) {
        await ref.read(authViewModelProvider.notifier).logout();
        await ref.read(userSessionServiceProvider).clearSession();
        await _secureStorage.delete(key: _tokenKey);

        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        showCustomErrorSnackBar(context, _text(body['message'], 'Unable to delete account'));
      }
    } catch (_) {
      if (!mounted) return;
      showCustomErrorSnackBar(context, 'Unable to delete account');
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9E9E9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSettings,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSectionCard(
                    title: 'Change Password',
                    children: [
                      TextField(
                        controller: _currentPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Current Password'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _newPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'New Password'),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton(
                          onPressed: _isUpdating ? null : _changePassword,
                          child: const Text('Update Password'),
                        ),
                      ),
                    ],
                  ),
                  _buildSectionCard(
                    title: 'Visibility',
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Show me as online'),
                        value: _onlineVisibility,
                        onChanged: _setVisibility,
                      ),
                    ],
                  ),
                  _buildSectionCard(
                    title: 'Notifications',
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Likes notifications'),
                        value: _likesNotification,
                        onChanged: (value) {
                          setState(() => _likesNotification = value);
                          _setNotifications();
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Post likes notifications'),
                        value: _postLikesNotification,
                        onChanged: (value) {
                          setState(() => _postLikesNotification = value);
                          _setNotifications();
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Matches notifications'),
                        value: _matchesNotification,
                        onChanged: (value) {
                          setState(() => _matchesNotification = value);
                          _setNotifications();
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Messages notifications'),
                        value: _messagesNotification,
                        onChanged: (value) {
                          setState(() => _messagesNotification = value);
                          _setNotifications();
                        },
                      ),
                    ],
                  ),
                  _buildSectionCard(
                    title: 'Privacy',
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Show my age'),
                        value: _showAge,
                        onChanged: (value) {
                          setState(() => _showAge = value);
                          _setPrivacy();
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Show my location'),
                        value: _showLocation,
                        onChanged: (value) {
                          setState(() => _showLocation = value);
                          _setPrivacy();
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Show my online status'),
                        value: _showOnlineStatus,
                        onChanged: (value) {
                          setState(() => _showOnlineStatus = value);
                          _setPrivacy();
                        },
                      ),
                    ],
                  ),
                  _buildSectionCard(
                    title: 'Block User',
                    children: [
                      const Text('Tap Block to block a connection.'),
                      const SizedBox(height: 10),
                      if (_connections.isEmpty)
                        const Text('No connections available to block')
                      else
                        ..._connections.map((item) {
                          final user = item['user'] as Map<String, dynamic>?;
                          final userId = _text(user?['id']);
                          final name = '${_text(user?['firstname'], 'User')} ${_text(user?['lastname'])}'.trim();
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.person_outline),
                            title: Text(name.isEmpty ? 'User' : name),
                            trailing: TextButton(
                              onPressed: userId.isEmpty ? null : () => _blockUser(userId),
                              child: const Text('Block'),
                            ),
                          );
                        }),
                    ],
                  ),
                  _buildSectionCard(
                    title: 'Blocked Users',
                    children: [
                      if (_blockedUsers.isEmpty)
                        const Text('No blocked users')
                      else
                        ..._blockedUsers.map((item) {
                          final data = item as Map<String, dynamic>;
                          final id = _text(data['id']);
                          final name = _text(data['name'], 'PairUp user');
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.block),
                            title: Text(name),
                            trailing: TextButton(
                              onPressed: id.isEmpty ? null : () => _unblockUser(id),
                              child: const Text('Unblock'),
                            ),
                          );
                        }),
                    ],
                  ),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _isUpdating ? null : _deleteAccount,
                      icon: const Icon(Icons.delete_forever_outlined),
                      label: const Text('Delete Account'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
