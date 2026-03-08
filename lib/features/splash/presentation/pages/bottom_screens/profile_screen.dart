import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pairup/core/api/api_client.dart';
import 'package:pairup/core/localization/app_localizations.dart';
import 'package:pairup/core/utils/snackbar_helper.dart';
import 'package:pairup/core/services/storage/user_session_service.dart';
import 'package:pairup/features/auth/presentation/pages/login_screen.dart';
import 'package:pairup/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:pairup/features/splash/presentation/pages/bottom_screens/profile_settings_screen.dart';
import 'package:pairup/features/splash/presentation/pages/bottom_screens/profile_view_edit_screen.dart';
import 'package:pairup/features/user/domain/usecases/get_public_user_profile_usecase.dart';
import 'package:pairup/features/user/presentation/pages/public_user_profile_screen.dart';

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
  List<_ConnectionPreview> _connectionPreviews = [];
  final Set<String> _likedPhotoUrls = <String>{};
  final Set<String> _deletingPhotoIds = <String>{};
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
      final rawConnections =
          (connectionsBody['connections'] as List<dynamic>?) ?? [];

      var connectionPreviews = _buildConnectionPreviews(rawConnections);
      connectionPreviews = await _enrichConnectionPreviews(connectionPreviews);

      if (!mounted) return;

      setState(() {
        _user = meBody['data'] as Map<String, dynamic>?;
        _activity = statsBody['data'] as Map<String, dynamic>?;
        _connectionPreviews = connectionPreviews;
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

  int _photoLikesCount(Map<String, dynamic> image) {
    final likesCount = image['likesCount'] ?? image['likeCount'];
    if (likesCount is int) return likesCount;
    if (likesCount is double) return likesCount.round();
    if (likesCount is String) {
      return int.tryParse(likesCount.trim()) ?? 0;
    }

    final likes = image['likes'];
    if (likes is List) return likes.length;
    return 0;
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
      return raw
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList();
    }
    return <String>[];
  }

  List<_ProfilePhoto> get _photos {
    final photos = <_ProfilePhoto>[];
    final seenUrls = <String>{};
    final currentProfileImage = _text(_user?['profileImage']);

    final rawImages = _user?['images'];
    if (rawImages is List) {
      for (final item in rawImages.whereType<Map<String, dynamic>>()) {
        final url = _text(item['url']);
        if (url.isEmpty || !seenUrls.add(url)) continue;

        final imageId = _text(item['_id']).isNotEmpty
            ? _text(item['_id'])
            : _text(item['public_id']);
        final likesCount = _photoLikesCount(item);
        final isThumbnail = item['isThumbnail'] == true;
        final isProfile =
            isThumbnail ||
            (currentProfileImage.isNotEmpty && currentProfileImage == url);

        photos.add(
          _ProfilePhoto(
            id: imageId,
            url: url,
            likesCount: likesCount,
            deletable: imageId.isNotEmpty,
            isProfile: isProfile,
          ),
        );
      }
    }

    if (currentProfileImage.isNotEmpty && seenUrls.add(currentProfileImage)) {
      photos.insert(
        0,
        _ProfilePhoto(
          id: '',
          url: currentProfileImage,
          likesCount: 0,
          deletable: false,
          isProfile: true,
        ),
      );
    }

    final image = _text(_user?['image']);
    if (image.isNotEmpty && seenUrls.add(image)) {
      photos.add(
        _ProfilePhoto(
          id: '',
          url: image,
          likesCount: 0,
          deletable: false,
          isProfile: false,
        ),
      );
    }

    photos.sort((a, b) => (b.isProfile ? 1 : 0) - (a.isProfile ? 1 : 0));
    return photos;
  }

  List<_ConnectionPreview> _buildConnectionPreviews(
    List<dynamic> rawConnections,
  ) {
    return rawConnections.map((item) {
      final connection = item is Map<String, dynamic>
          ? item
          : <String, dynamic>{};
      final user = connection['user'] is Map<String, dynamic>
          ? connection['user'] as Map<String, dynamic>
          : <String, dynamic>{};

      final firstName = _text(user['firstname']);
      final lastName = _text(user['lastname']);
      final userId = _text(user['id']).isNotEmpty
          ? _text(user['id'])
          : (_text(user['_id']).isNotEmpty
                ? _text(user['_id'])
                : _text(user['uid']));

      final avatar = _text(user['avatar']).isNotEmpty
          ? _text(user['avatar'])
          : (_text(user['profileImage']).isNotEmpty
                ? _text(user['profileImage'])
                : _text(user['image']));

      return _ConnectionPreview(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        avatarUrl: avatar,
        status: _text(connection['status']),
      );
    }).toList();
  }

  Future<List<_ConnectionPreview>> _enrichConnectionPreviews(
    List<_ConnectionPreview> previews,
  ) async {
    final usecase = ref.read(getPublicUserProfileUsecaseProvider);

    return Future.wait(
      previews.map((preview) async {
        if (preview.userId.isEmpty && preview.avatarUrl.isNotEmpty) {
          return preview;
        }
        if (preview.userId.isEmpty) return preview;
        if (preview.avatarUrl.isNotEmpty &&
            preview.firstName.isNotEmpty &&
            preview.lastName.isNotEmpty) {
          return preview;
        }

        final result = await usecase(
          GetPublicUserProfileUsecaseParams(
            userId: preview.userId,
            trackView: false,
          ),
        );

        return result.fold(
          (_) => preview,
          (profile) => preview.copyWith(
            firstName: preview.firstName.isEmpty
                ? profile.firstname
                : preview.firstName,
            lastName: preview.lastName.isEmpty
                ? profile.lastname
                : preview.lastName,
            avatarUrl: preview.avatarUrl.isEmpty
                ? profile.primaryImageUrl
                : preview.avatarUrl,
          ),
        );
      }),
    );
  }

  Future<void> _openPublicProfile(String userId) async {
    final normalized = userId.trim();
    if (normalized.isEmpty) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PublicUserProfileScreen(userId: normalized),
      ),
    );
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

  Future<void> _showPhotoPreview(_ProfilePhoto photo) async {
    final imageUrl = photo.url;
    var isLiked = _likedPhotoUrls.contains(imageUrl);
    var isDeleting = false;
    var isSettingProfile = false;
    final l10n = context.l10n;

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (dialogContext) {
        final imageHeight = MediaQuery.of(dialogContext).size.height * 0.55;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 26,
              ),
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: SizedBox(
                              width: double.infinity,
                              height: imageHeight,
                              child: InteractiveViewer(
                                minScale: 1,
                                maxScale: 3,
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: const Color(0xFF1E1E1E),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.broken_image_outlined,
                                          color: Colors.white70,
                                        ),
                                      ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              const Icon(
                                Icons.favorite,
                                color: Colors.pinkAccent,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${photo.likesCount} ${l10n.tr('likes')}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      setDialogState(() => isLiked = !isLiked);
                                      setState(() {
                                        if (isLiked) {
                                          _likedPhotoUrls.add(imageUrl);
                                        } else {
                                          _likedPhotoUrls.remove(imageUrl);
                                        }
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isLiked
                                          ? Colors.pink
                                          : const Color(0xFF7F3DDB),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: Icon(
                                      isLiked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      isLiked ? 'Liked' : 'Like',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (photo.id.isNotEmpty) ...[
                                const SizedBox(width: 10),
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: ElevatedButton.icon(
                                      onPressed:
                                          isSettingProfile || photo.isProfile
                                          ? null
                                          : () async {
                                              final navigator = Navigator.of(
                                                dialogContext,
                                              );
                                              setDialogState(
                                                () => isSettingProfile = true,
                                              );
                                              final updated =
                                                  await _setPhotoAsProfile(
                                                    photo,
                                                  );
                                              if (!mounted) return;
                                              if (updated) {
                                                navigator.pop();
                                                return;
                                              }
                                              setDialogState(
                                                () => isSettingProfile = false,
                                              );
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: photo.isProfile
                                            ? Colors.green
                                            : const Color(0xFF3949AB),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      icon: isSettingProfile
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                          : Icon(
                                              photo.isProfile
                                                  ? Icons.verified
                                                  : Icons.person_pin_circle,
                                            ),
                                      label: Text(
                                        photo.isProfile
                                            ? l10n.tr('profile_photo')
                                            : l10n.tr('set_profile'),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              if (photo.deletable) ...[
                                const SizedBox(width: 10),
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: ElevatedButton.icon(
                                      onPressed: isDeleting
                                          ? null
                                          : () async {
                                              final navigator = Navigator.of(
                                                dialogContext,
                                              );
                                              setDialogState(
                                                () => isDeleting = true,
                                              );
                                              final deleted =
                                                  await _deletePhoto(photo);
                                              if (!mounted) return;
                                              if (deleted) {
                                                navigator.pop();
                                                return;
                                              }
                                              setDialogState(
                                                () => isDeleting = false,
                                              );
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      icon: isDeleting
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                          : const Icon(Icons.delete_outline),
                                      label: const Text(
                                        'Delete',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: IconButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                        splashRadius: 20,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _setPhotoAsProfile(_ProfilePhoto photo) async {
    if (photo.id.isEmpty || photo.isProfile) return false;

    try {
      final response = await _apiClient.patch(
        '/api/users/set-thumbnail/${Uri.encodeComponent(photo.id)}',
      );
      final body = response.data;
      if (body is Map<String, dynamic> && body['success'] == false) {
        if (!mounted) return false;
        showCustomErrorSnackBar(
          context,
          context.l10n.tr('unable_set_profile_photo'),
        );
        return false;
      }

      if (!mounted) return false;
      showCustomSuccessSnackBar(
        context,
        context.l10n.tr('profile_photo_updated'),
      );
      await _loadProfileData();
      return true;
    } catch (_) {
      if (!mounted) return false;
      showCustomErrorSnackBar(
        context,
        context.l10n.tr('unable_set_profile_photo'),
      );
      return false;
    }
  }

  Future<bool> _deletePhoto(_ProfilePhoto photo) async {
    if (!photo.deletable || photo.id.isEmpty) return false;
    if (_deletingPhotoIds.contains(photo.id)) return false;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete photo?'),
          content: const Text(
            'This photo will be removed from your profile gallery.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return false;

    setState(() => _deletingPhotoIds.add(photo.id));
    try {
      await _apiClient.delete(
        '/api/users/images/${Uri.encodeComponent(photo.id)}',
      );
      if (!mounted) return false;
      showCustomSuccessSnackBar(context, 'Photo deleted');
      await _loadProfileData();
      return true;
    } catch (_) {
      if (!mounted) return false;
      showCustomErrorSnackBar(context, 'Unable to delete photo');
      return false;
    } finally {
      if (mounted) {
        setState(() => _deletingPhotoIds.remove(photo.id));
      }
    }
  }

  void _showConnectionsDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Connections'),
          content: SizedBox(
            width: double.maxFinite,
            child: _connectionPreviews.isEmpty
                ? const Text('No connections yet.')
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total connections: ${_connectionPreviews.length}'),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 260,
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _connectionPreviews.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 12),
                          itemBuilder: (context, index) {
                            final preview = _connectionPreviews[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              onTap: preview.userId.isEmpty
                                  ? null
                                  : () {
                                      Navigator.pop(context);
                                      _openPublicProfile(preview.userId);
                                    },
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFFEDE9FE),
                                backgroundImage: preview.avatarUrl.isNotEmpty
                                    ? NetworkImage(preview.avatarUrl)
                                    : null,
                                child: preview.avatarUrl.isEmpty
                                    ? const Icon(
                                        Icons.person,
                                        color: Color(0xFF7F3DDB),
                                      )
                                    : null,
                              ),
                              title: Text(preview.displayName),
                              subtitle: preview.status.isEmpty
                                  ? null
                                  : Text(preview.status),
                              trailing: preview.userId.isEmpty
                                  ? null
                                  : const Icon(Icons.chevron_right),
                            );
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
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C2028) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF323843)
        : const Color(0xFFE9E9E9);
    final photos = _photos;
    final avatarUrl = photos.isNotEmpty ? photos.first.url : '';
    final views = (_activity?['views'] ?? 0).toString();
    final likes = (_activity?['likes'] ?? 0).toString();
    final matches = (_activity?['matches'] ?? 0).toString();
    final sectionHeight = _photosHeight(photos.length) > 130
        ? _photosHeight(photos.length)
        : 130.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          l10n.tr('profile'),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfileData,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                children: [
                  if (!_isProfileComplete)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2E2A1D)
                            : const Color(0xFFFFF8E7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF5E4B1F)
                              : const Color(0xFFFFD88A),
                        ),
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
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 18,
                                  color: isDark ? Colors.white70 : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _location,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15,
                                    ),
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
                        backgroundImage: avatarUrl.isNotEmpty
                            ? NetworkImage(avatarUrl)
                            : null,
                        child: avatarUrl.isEmpty
                            ? const Icon(
                                Icons.person,
                                color: Color(0xFF7F3DDB),
                                size: 36,
                              )
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'View Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
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
                        color: cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                l10n.tr('connections'),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_connectionPreviews.length} total connections',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tap to view connection profiles',
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
                      color: cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.tr('about_me'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(_bio),
                        const SizedBox(height: 12),
                        Text(
                          l10n.tr('interests'),
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _interests.isEmpty
                              ? [const Chip(label: Text('No interests added'))]
                              : _interests
                                    .map(
                                      (interest) => Chip(label: Text(interest)),
                                    )
                                    .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF252A33)
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SectionTabButton(
                            label: l10n.tr('photos'),
                            isSelected: _selectedSectionIndex == 0,
                            onTap: () => _openSectionPage(0),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _SectionTabButton(
                            label: l10n.tr('activity'),
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
                        if (photos.isEmpty)
                          Container(
                            height: 110,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: borderColor),
                            ),
                            child: const Text('No photos uploaded yet'),
                          )
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 6,
                                  crossAxisSpacing: 6,
                                  childAspectRatio: 1,
                                ),
                            itemCount: photos.length,
                            itemBuilder: (context, index) {
                              final photo = photos[index];
                              final image = photo.url;
                              return GestureDetector(
                                onTap: () => _showPhotoPreview(photo),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          image,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (
                                                context,
                                                error,
                                                stackTrace,
                                              ) => Container(
                                                color: const Color(0xFFF1F1F1),
                                                child: const Icon(
                                                  Icons.broken_image_outlined,
                                                ),
                                              ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 6,
                                      bottom: 6,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.58,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.favorite,
                                              color: Colors.white,
                                              size: 12,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              photo.likesCount.toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (photo.isProfile)
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF2E7D32,
                                            ).withValues(alpha: 0.9),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            l10n.tr('profile_photo'),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _StatTile(
                                  label: l10n.tr('views'),
                                  value: views,
                                ),
                              ),
                              Expanded(
                                child: _StatTile(
                                  label: l10n.tr('likes'),
                                  value: likes,
                                ),
                              ),
                              Expanded(
                                child: _StatTile(
                                  label: l10n.tr('matches'),
                                  value: matches,
                                ),
                              ),
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
                      label: Text(l10n.tr('logout')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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

class _ConnectionPreview {
  final String userId;
  final String firstName;
  final String lastName;
  final String avatarUrl;
  final String status;

  const _ConnectionPreview({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.avatarUrl,
    required this.status,
  });

  String get displayName {
    final full = '$firstName $lastName'.trim();
    return full.isEmpty ? 'User' : full;
  }

  _ConnectionPreview copyWith({
    String? userId,
    String? firstName,
    String? lastName,
    String? avatarUrl,
    String? status,
  }) {
    return _ConnectionPreview(
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
    );
  }
}

class _ProfilePhoto {
  final String id;
  final String url;
  final int likesCount;
  final bool deletable;
  final bool isProfile;

  const _ProfilePhoto({
    required this.id,
    required this.url,
    required this.likesCount,
    required this.deletable,
    required this.isProfile,
  });
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1C2028) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected
                ? const Color(0xFF7F3DDB)
                : (isDark ? Colors.white70 : Colors.grey[700]),
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
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white70
                : Colors.grey,
          ),
        ),
      ],
    );
  }
}
