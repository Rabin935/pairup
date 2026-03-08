import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/features/user/domain/entities/public_user_profile_entity.dart';
import 'package:pairup/features/user/domain/usecases/get_public_user_profile_usecase.dart';
import 'package:pairup/features/user/domain/usecases/toggle_user_image_like_usecase.dart';

class PublicUserProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const PublicUserProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<PublicUserProfileScreen> createState() =>
      _PublicUserProfileScreenState();
}

class _PublicUserProfileScreenState
    extends ConsumerState<PublicUserProfileScreen> {
  static const _fallbackImage =
      'https://images.unsplash.com/photo-1544723795-3fb6469f5b39?w=800&auto=format&fit=crop';
  static const _statsRefreshInterval = Duration(seconds: 8);

  PublicUserProfileEntity? _profile;
  bool _isLoading = true;
  String? _errorMessage;
  String? _likingImageId;
  Timer? _statsRefreshTimer;

  @override
  void initState() {
    super.initState();
    _loadProfile(trackView: true);
  }

  @override
  void dispose() {
    _statsRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadProfile({
    bool showLoader = true,
    bool trackView = false,
  }) async {
    if (showLoader) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final usecase = ref.read(getPublicUserProfileUsecaseProvider);
    final result = await usecase(
      GetPublicUserProfileUsecaseParams(
        userId: widget.userId,
        trackView: trackView,
      ),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        if (!showLoader && _profile != null) {
          return;
        }
        setState(() {
          _isLoading = false;
          _errorMessage = failure.message;
        });
      },
      (profile) {
        if (profile.isOwnProfile) {
          Navigator.pop(context);
          return;
        }
        setState(() {
          _isLoading = false;
          _errorMessage = null;
          _profile = profile;
        });
        _startRealtimeStatsSync();
      },
    );
  }

  void _startRealtimeStatsSync() {
    _statsRefreshTimer?.cancel();
    _statsRefreshTimer = Timer.periodic(_statsRefreshInterval, (_) {
      if (!mounted) return;
      _loadProfile(showLoader: false, trackView: false);
    });
  }

  Future<_ImageLikeUpdate?> _toggleImageLike(
    PublicUserImageEntity image,
  ) async {
    if (_likingImageId != null) return null;

    setState(() => _likingImageId = image.id);

    final result = await ref.read(toggleUserImageLikeUsecaseProvider)(
      ToggleUserImageLikeUsecaseParams(
        userId: widget.userId,
        imageId: image.id,
      ),
    );

    if (!mounted) return null;

    _ImageLikeUpdate? update;
    result.fold(
      (failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (likeResult) {
        final currentProfile = _profile;
        if (currentProfile == null) return;

        final updatedImages = currentProfile.images.map((entry) {
          if (entry.id == image.id) {
            return entry.copyWith(
              likedByMe: likeResult.liked,
              likesCount: likeResult.likesCount,
            );
          }
          return entry;
        }).toList();

        final totalLikes = updatedImages.fold<int>(
          0,
          (sum, entry) => sum + entry.likesCount,
        );

        setState(() {
          _profile = currentProfile.copyWith(
            images: updatedImages,
            likes: totalLikes,
          );
        });

        update = _ImageLikeUpdate(
          liked: likeResult.liked,
          likesCount: likeResult.likesCount,
        );
      },
    );

    if (mounted) {
      setState(() => _likingImageId = null);
    }

    return update;
  }

  Future<void> _showInstagramImageViewer(PublicUserImageEntity image) async {
    var likedByMe = image.likedByMe;
    var likesCount = image.likesCount;
    var isUpdating = false;

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: InteractiveViewer(
                        minScale: 1,
                        maxScale: 3,
                        child: Image.network(
                          image.url.isEmpty ? _fallbackImage : image.url,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.broken_image_outlined,
                                  color: Colors.white70,
                                  size: 44,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 8,
                      child: IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(Icons.close, color: Colors.white),
                        splashRadius: 20,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0),
                              Colors.black.withValues(alpha: 0.78),
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  likedByMe
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: likedByMe
                                      ? Colors.pinkAccent
                                      : Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$likesCount likes',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            SizedBox(
                              height: 44,
                              child: ElevatedButton.icon(
                                onPressed: isUpdating
                                    ? null
                                    : () async {
                                        setDialogState(() => isUpdating = true);
                                        final update = await _toggleImageLike(
                                          image,
                                        );
                                        if (!mounted) return;
                                        setDialogState(() {
                                          if (update != null) {
                                            likedByMe = update.liked;
                                            likesCount = update.likesCount;
                                          }
                                          isUpdating = false;
                                        });
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: likedByMe
                                      ? const Color(0xFFE5487E)
                                      : Colors.white,
                                  foregroundColor: likedByMe
                                      ? Colors.white
                                      : Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                icon: isUpdating
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
                                    : Icon(
                                        likedByMe
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                      ),
                                label: Text(likedByMe ? 'Liked' : 'Like'),
                              ),
                            ),
                          ],
                        ),
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

  Widget _statsTile({required String label, required int value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFF5F1FF),
          border: Border.all(color: const Color(0xFFE7DBFF)),
        ),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAE2FF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  String _avatarInitials(String fullName) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'P';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F4FF),
        elevation: 0,
        title: Text(
          profile?.fullName ?? 'Profile',
          style: const TextStyle(
            color: Color(0xFF24103D),
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF24103D)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          _loadProfile(showLoader: true, trackView: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7F3DDB),
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : profile == null
          ? const Center(child: Text('Profile not found'))
          : RefreshIndicator(
              onRefresh: () =>
                  _loadProfile(showLoader: false, trackView: false),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6D37D7), Color(0xFF8E57FF)],
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white.withValues(alpha: 0.22),
                          backgroundImage: NetworkImage(
                            profile.primaryImageUrl.isEmpty
                                ? _fallbackImage
                                : profile.primaryImageUrl,
                          ),
                          onBackgroundImageError:
                              (Object exception, StackTrace? stackTrace) {},
                          child: profile.primaryImageUrl.isEmpty
                              ? Text(
                                  _avatarInitials(profile.fullName),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          profile.age == null
                              ? profile.fullName
                              : '${profile.fullName}, ${profile.age}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              profile.location.isEmpty
                                  ? 'Nearby'
                                  : profile.location,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        if (profile.bio.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            profile.bio,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _sectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Activity',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8FFF4),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: Color(0xFF19A464),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Live',
                                    style: TextStyle(
                                      color: Color(0xFF157A4B),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _statsTile(label: 'Views', value: profile.views),
                            const SizedBox(width: 8),
                            _statsTile(label: 'Likes', value: profile.likes),
                            const SizedBox(width: 8),
                            _statsTile(
                              label: 'Matches',
                              value: profile.matches,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _sectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Interests',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: profile.interests.isEmpty
                              ? [
                                  const Chip(
                                    label: Text('No interests available'),
                                  ),
                                ]
                              : profile.interests
                                    .map(
                                      (interest) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 7,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF2ECFF),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: Text(
                                          interest,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF5F3AB4),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                        ),
                      ],
                    ),
                  ),
                  _sectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Photos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        profile.images.isEmpty
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 22,
                                ),
                                width: double.infinity,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFE6E6E6),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text('No photos available'),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                      childAspectRatio: 1,
                                    ),
                                itemCount: profile.images.length,
                                itemBuilder: (context, index) {
                                  final image = profile.images[index];
                                  return InkWell(
                                    onTap: () =>
                                        _showInstagramImageViewer(image),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.network(
                                              image.url.isEmpty
                                                  ? _fallbackImage
                                                  : image.url,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Container(
                                                      color: const Color(
                                                        0xFFF1F1F1,
                                                      ),
                                                      alignment:
                                                          Alignment.center,
                                                      child: const Icon(
                                                        Icons
                                                            .broken_image_outlined,
                                                        color: Colors.grey,
                                                      ),
                                                    );
                                                  },
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 6,
                                          right: 6,
                                          bottom: 6,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: Colors.black.withValues(
                                                alpha: 0.58,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  image.likedByMe
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color: image.likedByMe
                                                      ? Colors.pinkAccent
                                                      : Colors.white,
                                                  size: 13,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  image.likesCount.toString(),
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
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ImageLikeUpdate {
  final bool liked;
  final int likesCount;

  const _ImageLikeUpdate({required this.liked, required this.likesCount});
}
