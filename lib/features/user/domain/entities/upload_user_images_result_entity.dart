import 'package:equatable/equatable.dart';

class UploadUserImagesResultEntity extends Equatable {
  final List<String> imageUrls;

  const UploadUserImagesResultEntity({required this.imageUrls});

  @override
  List<Object?> get props => [imageUrls];
}
