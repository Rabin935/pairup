import 'package:pairup/features/user/domain/entities/user_image_like_result_entity.dart';

class UserImageLikeResultApiModel {
  final String userId;
  final String imageId;
  final bool liked;
  final int likesCount;

  const UserImageLikeResultApiModel({
    required this.userId,
    required this.imageId,
    required this.liked,
    required this.likesCount,
  });

  factory UserImageLikeResultApiModel.fromJson(Map<String, dynamic> json) {
    return UserImageLikeResultApiModel(
      userId: _asText(json['userId']),
      imageId: _asText(json['imageId']),
      liked: _asBool(json['liked']),
      likesCount: _asInt(json['likesCount']),
    );
  }

  UserImageLikeResultEntity toEntity() {
    return UserImageLikeResultEntity(
      userId: userId,
      imageId: imageId,
      liked: liked,
      likesCount: likesCount,
    );
  }
}

String _asText(dynamic value) {
  if (value == null) return '';
  return value.toString().trim();
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
  return false;
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return int.tryParse(value.trim()) ?? 0;
  return 0;
}
