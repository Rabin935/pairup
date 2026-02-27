import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pairup/core/api/api_client.dart';
import 'package:pairup/core/utils/snackbar_helper.dart';
import 'package:pairup/features/splash/presentation/pages/bottom_screens/profile_view_edit_screen.dart';

class DiscoverCard extends StatefulWidget {
  const DiscoverCard({super.key});

  @override
  State<DiscoverCard> createState() => DiscoverCardState();
}

class DiscoverCardState extends State<DiscoverCard> {
  final ApiClient _apiClient = ApiClient();
  final List<Map<String, dynamic>> _users = [];

  Offset _cardOffset = Offset.zero;
  double _cardRotation = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _needsProfileCompletion = false;
  Map<String, dynamic>? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> refreshDeck() async {
    await _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get('/api/users/discover');
      final body = response.data as Map<String, dynamic>;
      final list = (body['data'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();

      if (!mounted) return;
      setState(() {
        _users
          ..clear()
          ..addAll(list);
        _needsProfileCompletion = false;
        _isLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      final errorBody = e.response?.data;
      final code = errorBody is Map<String, dynamic>
          ? (errorBody['code']?.toString() ?? '')
          : '';

      if (e.response?.statusCode == 403 && code == 'PROFILE_INCOMPLETE') {
        try {
          final meResponse = await _apiClient.get('/api/users/me');
          final meBody = meResponse.data as Map<String, dynamic>;
          setState(() {
            _currentUser = meBody['data'] as Map<String, dynamic>?;
            _needsProfileCompletion = true;
            _isLoading = false;
          });
        } catch (_) {
          setState(() {
            _needsProfileCompletion = true;
            _isLoading = false;
          });
        }
      } else {
        setState(() => _isLoading = false);
        showCustomErrorSnackBar(context, 'Unable to load discover users');
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showCustomErrorSnackBar(context, 'Unable to load discover users');
    }
  }

  Future<void> _openCompleteProfile() async {
    Map<String, dynamic>? userData = _currentUser;
    if (userData == null) {
      try {
        final meResponse = await _apiClient.get('/api/users/me');
        final meBody = meResponse.data as Map<String, dynamic>;
        userData = meBody['data'] as Map<String, dynamic>?;
      } catch (_) {}
    }

    if (userData == null || !mounted) {
      if (!mounted) return;
      showCustomErrorSnackBar(context, 'Unable to open profile completion');
      return;
    }

    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileViewEditScreen(userData: userData!),
      ),
    );

    if (updated == true && mounted) {
      await _loadUsers();
    }
  }

  String _text(dynamic value, [String fallback = '']) {
    final t = (value ?? '').toString().trim();
    return t.isEmpty ? fallback : t;
  }

  Map<String, dynamic>? get _topUser => _users.isNotEmpty ? _users.first : null;

  Future<void> _submitSwipe(String action) async {
    final user = _topUser;
    if (user == null || _isSubmitting) return;
    final userId = _text(user['_id']);
    if (userId.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      await _apiClient.post(
        '/api/swipes',
        data: {'swipedUserId': userId, 'action': action},
      );

      if (!mounted) return;
      setState(() {
        _users.removeAt(0);
        _cardOffset = Offset.zero;
        _cardRotation = 0;
        _isSubmitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cardOffset = Offset.zero;
        _cardRotation = 0;
        _isSubmitting = false;
      });
      showCustomErrorSnackBar(context, 'Unable to submit swipe');
    }
  }

  void _showDetails() {
    final user = _topUser;
    if (user == null) return;

    final images = (user['images'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final interests = (user['interests'] as List<dynamic>? ?? [])
        .map((item) => item.toString())
        .where((item) => item.trim().isNotEmpty)
        .toList();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.78,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                height: 5,
                width: 60,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              Text(
                _text(user['name'], 'User'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _text(user['location'], 'Location not available'),
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Text(
                _text(user['bio'], 'No bio available'),
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 14),
              const Text(
                'Interests',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: interests.isEmpty
                    ? [const Chip(label: Text('No interests'))]
                    : interests.map((e) => Chip(label: Text(e))).toList(),
              ),
              const SizedBox(height: 14),
              const Text(
                'Photos',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  childAspectRatio: 1,
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final url = _text(images[index]['url']);
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: url.isEmpty
                        ? Container(
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.image_not_supported_outlined,
                            ),
                          )
                        : Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.broken_image_outlined),
                              );
                            },
                          ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> triggerLike() async {
    if (_needsProfileCompletion) return;
    await _submitSwipe('like');
  }

  Future<void> triggerPass() async {
    if (_needsProfileCompletion) return;
    await _submitSwipe('dislike');
  }

  void triggerDetails() {
    if (_needsProfileCompletion) return;
    _showDetails();
  }

  Widget _buildCard(Map<String, dynamic> user, {bool isTop = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = _text(user['name'], 'User');
    final age = _text(user['age']);
    final location = _text(user['location'], 'Unknown location');
    final bio = _text(user['bio'], '');

    final images = (user['images'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final imageUrl = images.isNotEmpty ? _text(images.first['url']) : '';

    final card = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? const Color(0xFF1C2028) : Colors.grey.shade100,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            imageUrl.isEmpty
                ? Container(
                    color: isDark
                        ? const Color(0xFF303542)
                        : Colors.grey.shade300,
                    child: const Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.white,
                    ),
                  )
                : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: isDark
                            ? const Color(0xFF303542)
                            : Colors.grey.shade300,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          size: 50,
                        ),
                      );
                    },
                  ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xCC000000), Color(0x00000000)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      age.isEmpty ? name : '$name, $age',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    if (bio.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        bio,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                    if (isTop)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Swipe right to like, left to pass, up for details',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
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

    if (!isTop) {
      return card;
    }

    final likeOpacity = (_cardOffset.dx / 120).clamp(0.0, 1.0);
    final passOpacity = (-_cardOffset.dx / 120).clamp(0.0, 1.0);

    return Transform.translate(
      offset: _cardOffset,
      child: Transform.rotate(
        angle: _cardRotation,
        child: GestureDetector(
          onPanUpdate: (details) {
            if (_isSubmitting) return;
            setState(() {
              _cardOffset += details.delta;
              _cardRotation = _cardOffset.dx / 500;
            });
          },
          onPanEnd: (details) async {
            if (_isSubmitting) return;

            final dx = _cardOffset.dx;
            final dy = _cardOffset.dy;

            if (dx > 120) {
              await _submitSwipe('like');
              return;
            }

            if (dx < -120) {
              await _submitSwipe('dislike');
              return;
            }

            if (dy < -120 && dx.abs() < 80) {
              setState(() {
                _cardOffset = Offset.zero;
                _cardRotation = 0;
              });
              _showDetails();
              return;
            }

            setState(() {
              _cardOffset = Offset.zero;
              _cardRotation = 0;
            });
          },
          child: Stack(
            children: [
              card,
              Positioned(
                top: 24,
                left: 20,
                child: Opacity(
                  opacity: likeOpacity,
                  child: _SwipeTag(text: 'LIKE', color: Colors.green),
                ),
              ),
              Positioned(
                top: 24,
                right: 20,
                child: Opacity(
                  opacity: passOpacity,
                  child: _SwipeTag(text: 'PASS', color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_needsProfileCompletion) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF323843) : const Color(0xFFE9E9E9),
            ),
            color: isDark ? const Color(0xFF1C2028) : Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.assignment_turned_in_outlined,
                size: 42,
                color: Color(0xFF7F3DDB),
              ),
              const SizedBox(height: 10),
              const Text(
                'Complete your profile to discover users',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _openCompleteProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7F3DDB),
                ),
                child: const Text(
                  'Complete Profile',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_users.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No users to discover right now'),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _loadUsers, child: const Text('Refresh')),
          ],
        ),
      );
    }

    final top = _users[0];
    final second = _users.length > 1 ? _users[1] : null;

    const cardInset = EdgeInsets.fromLTRB(6, 6, 6, 16);
    const backCardInset = EdgeInsets.fromLTRB(14, 16, 14, 24);

    return Stack(
      children: [
        if (second != null)
          Positioned.fill(
            child: Padding(
              padding: backCardInset,
              child: Opacity(opacity: 0.7, child: _buildCard(second)),
            ),
          ),
        Positioned.fill(
          child: Padding(
            padding: cardInset,
            child: _buildCard(top, isTop: true),
          ),
        ),
      ],
    );
  }
}

class _SwipeTag extends StatelessWidget {
  final String text;
  final Color color;

  const _SwipeTag({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
