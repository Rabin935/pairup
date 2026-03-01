import 'package:equatable/equatable.dart';

class UserImageLikeResultEntity extends Equatable {
  final String userId;
  final String imageId;
  final bool liked;
  final int likesCount;

  const UserImageLikeResultEntity({
    required this.userId,
    required this.imageId,
    required this.liked,
    required this.likesCount,
  });

  @override
  List<Object?> get props => [userId, imageId, liked, likesCount];
}
