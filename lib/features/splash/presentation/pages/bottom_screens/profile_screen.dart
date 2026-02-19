import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pairup/core/api/api_client.dart';
import 'package:pairup/core/utils/snackbar_helper.dart';
import 'package:pairup/core/services/storage/user_session_service.dart';
import 'package:pairup/features/auth/presentation/pages/login_screen.dart';
import 'package:pairup/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:pairup/features/splash/presentation/pages/bottom_screens/profile_settings_screen.dart';
import 'package:pairup/features/splash/presentation/pages/bottom_screens/profile_view_edit_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  late final PageController _sectionPageController;

  Map<String, dynamic>? _user;
  Map<String, dynamic>? _activity;
  List<dynamic> _connections = [];
  bool _isLoading = true;
  bool _isSaving = false;
  int _selectedSectionIndex = 0;

  @override
  void initState() {
    super.initState();
    _sectionPageController = PageController();
    _loadProfileData();
  }

  @override
  void dispose() {
    _sectionPageController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    try {
      final responses = await Future.wait([
        _apiClient.get('/api/users/me'),
        _apiClient.get('/api/users/me/stats'),
        _apiClient.get('/api/connections'),
      ]);

      final meBody = responses[0].data as Map<String, dynamic>;
      final statsBody = responses[1].data as Map<String, dynamic>;
      final connectionsBody = responses[2].data as Map<String, dynamic>;

      if (!mounted) return;

      setState(() {
        _user = meBody['data'] as Map<String, dynamic>?;
        _activity = statsBody['data'] as Map<String, dynamic>?;
        _connections = (connectionsBody['connections'] as List<dynamic>?) ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showCustomErrorSnackBar(context, 'Unable to load profile data');
    }
  }

  String _text(dynamic value, [String fallback = '']) {
    final result = (value ?? '').toString().trim();
    return result.isEmpty ? fallback : result;
  }

  String get _firstName => _text(_user?['firstname']);
  String get _lastName => _text(_user?['lastname']);
  String get _fullName {
    final full = '$_firstName $_lastName'.trim();
    if (full.isNotEmpty) return full;
    return _text(_user?['email'], 'User');
  }

  String get _location => _text(_user?['location'], 'Location not added');
  String get _bio => _text(_user?['bio'], 'No bio added yet.');
  bool get _isProfileComplete => _user?['isProfileComplete'] == true;

  List<String> get _interests {
    final raw = _user?['interests'];
    if (raw is List) {
      return raw.map((item) => item.toString()).where((item) => item.trim().isNotEmpty).toList();
    }
    return <String>[];
  }

  List<String> get _imageUrls {
    final urls = <String>[];
    final profileImage = _text(_user?['profileImage']);
    final image = _text(_user?['image']);
    if (profileImage.isNotEmpty) urls.add(profileImage);
    if (image.isNotEmpty && image != profileImage) urls.add(image);

    final rawImages = _user?['images'];
    if (rawImages is List) {
      for (final item in rawImages) {
        if (item is Map<String, dynamic>) {
          final url = _text(item['url']);
          if (url.isNotEmpty && !urls.contains(url)) {
            urls.add(url);
          }
        }
      }
    }
    return urls;
  }

  Future<void> _openViewProfile() async {
    if (_user == null) return;
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileViewEditScreen(userData: _user!),
      ),
    );

    if (updated == true) {
      await _loadProfileData();
    }
  }

  Future<void> _logout() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      await ref.read(authViewModelProvider.notifier).logout();
      await ref.read(userSessionServiceProvider).clearSession();
      await _secureStorage.delete(key: _tokenKey);

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;
      showCustomErrorSnackBar(context, 'Unable to logout right now');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileSettingsScreen()),
    );
    if (!mounted) return;
    await _loadProfileData();
  }

  void _openSectionPage(int index) {
    if (_selectedSectionIndex == index) return;
    setState(() => _selectedSectionIndex = index);
    _sectionPageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  double _photosHeight(int imageCount) {
    if (imageCount == 0) return 110;
    final rows = (imageCount / 3).ceil();
    return (rows * 110).toDouble();
  }

  void _showConnectionsDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Connections'),
          content: SizedBox(
            width: double.maxFinite,
            child: _connections.isEmpty
                ? const Text('No connections yet.')
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total connections: ${_connections.length}'),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 260,
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _connections.length,
                          separatorBuilder: (context, index) => const Divider(height: 12),
                          itemBuilder: (context, index) {
                            final conn = _connections[index] as Map<String, dynamic>;
                            final user = conn['user'] as Map<String, dynamic>?;
                            final name =
                                '${_text(user?['firstname'], 'User')} ${_text(user?['lastname'])}'.trim();
                            return Text(name.isEmpty ? 'User' : name);
                          },
                        ),
                      ),
                    ],
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrls = _imageUrls;
    final avatarUrl = imageUrls.isNotEmpty ? imageUrls.first : '';
    final views = (_activity?['views'] ?? 0).toString();
    final likes = (_activity?['likes'] ?? 0).toString();
    final matches = (_activity?['matches'] ?? 0).toString();
    final sectionHeight = _photosHeight(imageUrls.length) > 130
      ? _photosHeight(imageUrls.length)
      : 130.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfileData,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  if (!_isProfileComplete)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFD88A)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Complete your details to unlock Discover cards',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: _openViewProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7F3DDB),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Complete Profile',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _fullName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _location,
                                    style: const TextStyle(color: Colors.grey, fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 38,
                        backgroundColor: const Color(0xFFEDE9FE),
                        backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                        child: avatarUrl.isEmpty
                            ? const Icon(Icons.person, color: Color(0xFF7F3DDB), size: 36)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _openViewProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7F3DDB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'View Profile',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: _showConnectionsDialog,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE9E9E9)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Connections',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                              ),
                              const Spacer(),
                              const Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_connections.length} total connections',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Tap to view connection names',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE9E9E9)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'About Me',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(_bio),
                        const SizedBox(height: 12),
                        const Text(
                          'Interests',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _interests.isEmpty
                              ? [
                                  const Chip(label: Text('No interests added')),
                                ]
                              : _interests
                                    .map((interest) => Chip(label: Text(interest)))
                                    .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SectionTabButton(
                            label: 'Photos',
                            isSelected: _selectedSectionIndex == 0,
                            onTap: () => _openSectionPage(0),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _SectionTabButton(
                            label: 'Activity',
                            isSelected: _selectedSectionIndex == 1,
                            onTap: () => _openSectionPage(1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: sectionHeight,
                    child: PageView(
                      controller: _sectionPageController,
                      onPageChanged: (index) {
                        if (_selectedSectionIndex != index) {
                          setState(() => _selectedSectionIndex = index);
                        }
                      },
                      children: [
                        if (imageUrls.isEmpty)
                          Container(
                            height: 110,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE9E9E9)),
                            ),
                            child: const Text('No photos uploaded yet'),
                          )
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 6,
                              crossAxisSpacing: 6,
                              childAspectRatio: 1,
                            ),
                            itemCount: imageUrls.length,
                            itemBuilder: (context, index) {
                              final image = imageUrls[index];
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: const Color(0xFFF1F1F1),
                                    child: const Icon(Icons.broken_image_outlined),
                                  ),
                                ),
                              );
                            },
                          ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE9E9E9)),
                          ),
                          child: Row(
                            children: [
                              Expanded(child: _StatTile(label: 'Views', value: views)),
                              Expanded(child: _StatTile(label: 'Likes', value: likes)),
                              Expanded(child: _StatTile(label: 'Matches', value: matches)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _isSaving ? null : _logout,
                      icon: _isSaving
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

class _SectionTabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SectionTabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? const Color(0xFF7F3DDB) : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
