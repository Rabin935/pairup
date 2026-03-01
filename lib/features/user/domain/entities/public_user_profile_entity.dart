import 'package:equatable/equatable.dart';

class PublicUserImageEntity extends Equatable {
  final String id;
  final String url;
  final bool isThumbnail;
  final int likesCount;
  final bool likedByMe;

  const PublicUserImageEntity({
    required this.id,
    required this.url,
    required this.isThumbnail,
    required this.likesCount,
    required this.likedByMe,
  });

  PublicUserImageEntity copyWith({
    String? id,
    String? url,
    bool? isThumbnail,
    int? likesCount,
    bool? likedByMe,
  }) {
    return PublicUserImageEntity(
      id: id ?? this.id,
      url: url ?? this.url,
      isThumbnail: isThumbnail ?? this.isThumbnail,
      likesCount: likesCount ?? this.likesCount,
      likedByMe: likedByMe ?? this.likedByMe,
    );
  }

  @override
  List<Object?> get props => [id, url, isThumbnail, likesCount, likedByMe];
}

class PublicUserProfileEntity extends Equatable {
  final String id;
  final String uid;
  final String firstname;
  final String lastname;
  final int? age;
  final String location;
  final String bio;
  final List<String> interests;
  final String profileImage;
  final List<PublicUserImageEntity> images;
  final bool isOwnProfile;
  final String? lastSeen;
  final int views;
  final int likes;
  final int matches;

  const PublicUserProfileEntity({
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

  PublicUserProfileEntity copyWith({
    String? id,
    String? uid,
    String? firstname,
    String? lastname,
    int? age,
    String? location,
    String? bio,
    List<String>? interests,
    String? profileImage,
    List<PublicUserImageEntity>? images,
    bool? isOwnProfile,
    String? lastSeen,
    int? views,
    int? likes,
    int? matches,
  }) {
    return PublicUserProfileEntity(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      age: age ?? this.age,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      profileImage: profileImage ?? this.profileImage,
      images: images ?? this.images,
      isOwnProfile: isOwnProfile ?? this.isOwnProfile,
      lastSeen: lastSeen ?? this.lastSeen,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      matches: matches ?? this.matches,
    );
  }

  String get fullName {
    final full = '$firstname $lastname'.trim();
    return full.isNotEmpty ? full : 'PairUp user';
  }

  String get primaryImageUrl {
    if (profileImage.trim().isNotEmpty) return profileImage.trim();
    if (images.isNotEmpty && images.first.url.trim().isNotEmpty) {
      return images.first.url.trim();
    }
    return '';
  }

  @override
  List<Object?> get props => [
    id,
    uid,
    firstname,
    lastname,
    age,
    location,
    bio,
    interests,
    profileImage,
    images,
    isOwnProfile,
    lastSeen,
    views,
    likes,
    matches,
  ];
}
