import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pairup/core/api/api_client.dart';
import 'package:pairup/core/localization/app_localizations.dart';
import 'package:pairup/features/user/presentation/pages/public_user_profile_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  static const _fallbackImage =
      'https://images.unsplash.com/photo-1544723795-3fb6469f5b39?w=800&auto=format&fit=crop';
  static const _primaryColor = Color(0xFF673AB7);
  static const _accentColor = Color(0xFFEE6C4D);

  final ApiClient _apiClient = ApiClient();
  final TextEditingController _searchController = TextEditingController();

  final List<_ExploreProfile> _profiles = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _searchTerm = '';
  RangeValues _ageRange = const RangeValues(18, 50);
  double _maxDistance = 50;
  Set<String> _selectedInterests = {};

  @override
  void initState() {
    super.initState();
    _fetchProfiles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfiles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    List<_ExploreProfile> mapped = [];
    Object? lastError;

    try {
      final response = await _apiClient.get(
        '/api/users',
        queryParameters: {'excludeSelf': true},
      );
      mapped = _mapProfiles(response.data);
    } catch (error) {
      lastError = error;
    }

    if (!mounted) return;

    setState(() {
      _profiles
        ..clear()
        ..addAll(mapped);
      _isLoading = false;
      if (mapped.isEmpty) {
        if (lastError is DioException) {
          _errorMessage = lastError.message ?? 'Unable to load explore users.';
        } else {
          _errorMessage = 'Unable to load explore users.';
        }
      } else {
        _errorMessage = null;
      }
    });
  }

  List<_ExploreProfile> _mapProfiles(dynamic payload) {
    final collection = _extractCollection(payload);
    return collection
        .asMap()
        .entries
        .map((entry) => _mapProfile(entry.value, entry.key))
        .whereType<_ExploreProfile>()
        .toList();
  }

  List<dynamic> _extractCollection(dynamic payload) {
    if (payload is List) return payload;
    if (payload is! Map) return const [];

    final keys = ['users', 'data', 'results', 'list', 'items', 'profiles'];
    for (final key in keys) {
      final value = payload[key];
      if (value is List) return value;
      if (value is Map) {
        final nested = _extractCollection(value);
        if (nested.isNotEmpty) return nested;
      }
    }
    return const [];
  }

  _ExploreProfile? _mapProfile(dynamic item, int index) {
    if (item is! Map) return null;

    final userId =
        _asString(item['_id']) ??
        _asString(item['id']) ??
        _asString(item['uid']) ??
        '';
    if (userId.isEmpty) return null;
    final id = userId;

    final firstName =
        _asString(item['firstname']) ?? _asString(item['firstName']);
    final lastName = _asString(item['lastname']) ?? _asString(item['lastName']);
    final fullName = [firstName, lastName]
        .where((value) => value != null && value.isNotEmpty)
        .cast<String>()
        .join(' ')
        .trim();

    final name = fullName.isNotEmpty
        ? fullName
        : (_asString(item['name']) ?? 'PairUp member');

    final image = _pickImageUrl(item) ?? _fallbackImage;
    final age = _asInt(item['age']);
    final location = _asString(item['location']) ?? '';
    final distance = _asDouble(item['distance']);
    final interests = _parseInterests(item['interests']);
    final matchPercentage =
        _asInt(item['matchPercentage']) ?? _asInt(item['compatibility']);
    final normalizedMatchPercentage = matchPercentage?.clamp(1, 99).toInt();
    final isOnline =
        _asBool(item['isOnline']) ??
        _asBool(item['online']) ??
        (_asString(item['status'])?.toLowerCase() == 'online');
    final isVerified =
        _asBool(item['isVerified']) ??
        _asBool(item['verified']) ??
        _asBool(item['isProfileComplete']) ??
        false;

    return _ExploreProfile(
      id: id,
      userId: userId,
      name: name,
      age: age,
      image: image,
      location: location,
      distance: distance,
      interests: interests,
      matchPercentage: normalizedMatchPercentage,
      isOnline: isOnline,
      isVerified: isVerified,
    );
  }

  String? _pickImageUrl(Map item) {
    final images = item['images'];
    if (images is List) {
      for (final image in images) {
        if (image is Map) {
          final url =
              _asString(image['url']) ??
              _asString(image['secure_url']) ??
              _asString(image['path']);
          if (url != null && url.isNotEmpty) return url;
        }
      }
    }

    return _asString(item['avatar']) ??
        _asString(item['profileImage']) ??
        _asString(item['image']) ??
        _asString(item['photo']);
  }

  List<String> _parseInterests(dynamic value) {
    if (value is List) {
      return value
          .map((item) => _asString(item))
          .whereType<String>()
          .where((item) => item.isNotEmpty)
          .toList();
    }

    final source = _asString(value);
    if (source == null || source.isEmpty) return const [];

    return source
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  String? _asString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  double? _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  bool? _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final text = value.trim().toLowerCase();
      if (text == 'true' || text == '1' || text == 'yes' || text == 'online') {
        return true;
      }
      if (text == 'false' || text == '0' || text == 'no' || text == 'offline') {
        return false;
      }
    }
    return null;
  }

  List<String> get _allInterests {
    final unique = <String>{};
    for (final profile in _profiles) {
      unique.addAll(profile.interests);
    }
    if (unique.isEmpty) {
      return const ['Travel', 'Music', 'Fitness', 'Art'];
    }
    return unique.take(24).toList();
  }

  List<_ExploreProfile> get _filteredProfiles {
    return _profiles.where((profile) {
      final searchOk = profile.name.toLowerCase().contains(
        _searchTerm.toLowerCase(),
      );
      final ageOk =
          profile.age == null ||
          (profile.age! >= _ageRange.start.round() &&
              profile.age! <= _ageRange.end.round());
      final distanceOk =
          profile.distance == null || profile.distance! <= _maxDistance;
      final interestOk =
          _selectedInterests.isEmpty ||
          profile.interests.any(
            (interest) => _selectedInterests.contains(interest),
          );

      return searchOk && ageOk && distanceOk && interestOk;
    }).toList();
  }

  void _resetFilters() {
    setState(() {
      _ageRange = const RangeValues(18, 50);
      _maxDistance = 50;
      _selectedInterests = {};
      _searchTerm = '';
      _searchController.clear();
    });
  }

  Future<void> _showFilters() async {
    RangeValues tempAgeRange = _ageRange;
    double tempMaxDistance = _maxDistance;
    Set<String> tempInterests = {..._selectedInterests};

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final l10n = context.l10n;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Filters',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Age Range: ${tempAgeRange.start.round()} - ${tempAgeRange.end.round()}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      RangeSlider(
                        values: tempAgeRange,
                        min: 18,
                        max: 60,
                        divisions: 42,
                        labels: RangeLabels(
                          tempAgeRange.start.round().toString(),
                          tempAgeRange.end.round().toString(),
                        ),
                        onChanged: (value) {
                          setModalState(() => tempAgeRange = value);
                        },
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Maximum Distance: ${tempMaxDistance.round()} km',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Slider(
                        value: tempMaxDistance,
                        min: 1,
                        max: 100,
                        divisions: 99,
                        label: '${tempMaxDistance.round()} km',
                        onChanged: (value) {
                          setModalState(() => tempMaxDistance = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Interests',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _allInterests.map((interest) {
                          final isSelected = tempInterests.contains(interest);
                          return FilterChip(
                            label: Text(interest),
                            selected: isSelected,
                            onSelected: (_) {
                              setModalState(() {
                                if (isSelected) {
                                  tempInterests.remove(interest);
                                } else {
                                  tempInterests.add(interest);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setModalState(() {
                                  tempAgeRange = const RangeValues(18, 50);
                                  tempMaxDistance = 50;
                                  tempInterests.clear();
                                });
                              },
                              child: Text(l10n.tr('reset_filters')),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _ageRange = tempAgeRange;
                                  _maxDistance = tempMaxDistance;
                                  _selectedInterests = tempInterests;
                                });
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryColor,
                              ),
                              child: const Text(
                                'Apply',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
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
    );
  }

  Widget _buildSearchBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242932) : const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() => _searchTerm = value.trim());
        },
        decoration: InputDecoration(
          hintText: context.l10n.tr('search_by_name'),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchTerm.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchTerm = '');
                  },
                  icon: const Icon(Icons.close),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF673AB7), Color(0xFF673AB7)],
            ),
          ),
          child: const Icon(Icons.explore, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PairUp',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: _primaryColor,
                ),
              ),
              Text(
                'Explore your perfect match',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _fetchProfiles,
          icon: const Icon(Icons.refresh_rounded),
        ),
        IconButton(
          onPressed: _showFilters,
          icon: const Icon(Icons.tune_rounded),
        ),
      ],
    );
  }

  Widget _buildError() {
    if (_errorMessage == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF3A2020)
            : const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF8A4A4A)
              : const Color(0xFFFFD2D2),
        ),
      ),
      child: Text(
        _errorMessage!,
        style: const TextStyle(
          color: Color(0xFFB23434),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildProfileCard(_ExploreProfile profile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _openPublicProfile(profile.userId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C2028) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? const Color(0xFF2E3340) : const Color(0xFFEFE8FF),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  profile.image,
                  width: 98,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 98,
                      height: 120,
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const Icon(Icons.person, size: 40),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            profile.age == null
                                ? profile.name
                                : '${profile.name}, ${profile.age}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (profile.isOnline)
                          _tag('Online', const Color(0xFF1D9A64)),
                      ],
                    ),
                    if (profile.isVerified)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: _tag('Verified', _primaryColor),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            [
                                  if (profile.location.isNotEmpty)
                                    profile.location,
                                  if (profile.distance != null)
                                    '${profile.distance!.toStringAsFixed(0)} km',
                                ].join(' - ').isEmpty
                                ? 'Location not available'
                                : [
                                    if (profile.location.isNotEmpty)
                                      profile.location,
                                    if (profile.distance != null)
                                      '${profile.distance!.toStringAsFixed(0)} km',
                                  ].join(' - '),
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (profile.matchPercentage != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            size: 16,
                            color: _accentColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${profile.matchPercentage}% match',
                            style: const TextStyle(
                              color: _accentColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Icon(Icons.chevron_right, color: Colors.grey),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: profile.interests.take(3).map((interest) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF24333B)
                                : const Color(0xFFE6F7F8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            interest,
                            style: const TextStyle(
                              color: _primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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

  Widget _tag(String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color.withValues(alpha: 0.12),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProfiles;
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildSearchBar(),
              _buildError(),
              const SizedBox(height: 8),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.travel_explore,
                              size: 50,
                              color: Color(0xFFB9B2C8),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.tr('no_profiles_found'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l10n.tr('try_adjust_search'),
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: _resetFilters,
                              child: Text(l10n.tr('reset_filters')),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchProfiles,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(top: 10, bottom: 20),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            return _buildProfileCard(filtered[index]);
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExploreProfile {
  final String id;
  final String userId;
  final String name;
  final int? age;
  final String image;
  final String location;
  final double? distance;
  final List<String> interests;
  final int? matchPercentage;
  final bool isOnline;
  final bool isVerified;

  const _ExploreProfile({
    required this.id,
    required this.userId,
    required this.name,
    required this.age,
    required this.image,
    required this.location,
    required this.distance,
    required this.interests,
    required this.matchPercentage,
    required this.isOnline,
    required this.isVerified,
  });
}
