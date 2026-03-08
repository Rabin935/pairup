import 'package:pairup/features/user/domain/entities/public_user_profile_entity.dart';

class PublicUserImageApiModel {
  final String id;
  final String url;
  final bool isThumbnail;
  final int likesCount;
  final bool likedByMe;

  const PublicUserImageApiModel({
    required this.id,
    required this.url,
    required this.isThumbnail,
    required this.likesCount,
    required this.likedByMe,
  });

  factory PublicUserImageApiModel.fromJson(Map<String, dynamic> json) {
    return PublicUserImageApiModel(
      id: _asString(json['id']),
      url: _asString(json['url']),
      isThumbnail: _asBool(json['isThumbnail']),
      likesCount: _asInt(json['likesCount']),
      likedByMe: _asBool(json['likedByMe']),
    );
  }

  PublicUserImageEntity toEntity() {
    return PublicUserImageEntity(
      id: id,
      url: url,
      isThumbnail: isThumbnail,
      likesCount: likesCount,
      likedByMe: likedByMe,
    );
  }
}

class PublicUserProfileApiModel {
  final String id;
  final String uid;
  final String firstname;
  final String lastname;
  final int? age;
  final String location;
  final String bio;
  final List<String> interests;
  final String profileImage;
  final List<PublicUserImageApiModel> images;
  final bool isOwnProfile;
  final String? lastSeen;
  final int views;
  final int likes;
  final int matches;

  const PublicUserProfileApiModel({
    required this.id,
    required this.uid,
    required this.firstname,
    required this.lastname,
    required this.age,
    required this.location,
    required this.bio,
    required this.interests,
    required this.profileImage,
    required this.images,
    required this.isOwnProfile,
    required this.lastSeen,
    required this.views,
    required this.likes,
    required this.matches,
  });

  factory PublicUserProfileApiModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    final images = rawImages is List
        ? rawImages
              .whereType<Map<String, dynamic>>()
              .map(PublicUserImageApiModel.fromJson)
              .toList()
        : <PublicUserImageApiModel>[];

    final rawInterests = json['interests'];
    final interests = rawInterests is List
        ? rawInterests.map((item) => item.toString().trim()).toList()
        : <String>[];

    final stats = json['stats'] is Map<String, dynamic>
        ? json['stats'] as Map<String, dynamic>
        : <String, dynamic>{};

    return PublicUserProfileApiModel(
      id: _asString(json['id']),
      uid: _asString(json['uid']),
      firstname: _asString(json['firstname']),
      lastname: _asString(json['lastname']),
      age: _asNullableInt(json['age']),
      location: _asString(json['location']),
      bio: _asString(json['bio']),
      interests: interests.where((item) => item.isNotEmpty).toList(),
      profileImage: _asString(json['profileImage']),
      images: images.where((image) => image.url.trim().isNotEmpty).toList(),
      isOwnProfile: _asBool(json['isOwnProfile']),
      lastSeen: _asNullableString(json['lastSeen']),
      views: _asInt(stats['views']),
      likes: _asInt(stats['likes']),
      matches: _asInt(stats['matches']),
    );
  }

  PublicUserProfileEntity toEntity() {
    return PublicUserProfileEntity(
      id: id,
      uid: uid,
      firstname: firstname,
      lastname: lastname,
      age: age,
      location: location,
      bio: bio,
      interests: interests,
      profileImage: profileImage,
      images: images.map((image) => image.toEntity()).toList(),
      isOwnProfile: isOwnProfile,
      lastSeen: lastSeen,
      views: views,
      likes: likes,
      matches: matches,
    );
  }
}

String _asString(dynamic value) {
  if (value == null) return '';
  final text = value.toString().trim();
  return text;
}

String? _asNullableString(dynamic value) {
  final text = _asString(value);
  return text.isEmpty ? null : text;
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) {
    return int.tryParse(value.trim()) ?? 0;
  }
  return 0;
}

int? _asNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) {
    return int.tryParse(value.trim());
  }
  return null;
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is String) {
    final text = value.trim().toLowerCase();
    return text == 'true' || text == '1' || text == 'yes';
  }
  return false;
}
