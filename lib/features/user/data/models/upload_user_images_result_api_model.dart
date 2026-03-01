import 'package:pairup/features/user/domain/entities/upload_user_images_result_entity.dart';

class UploadUserImagesResultApiModel {
  final List<String> imageUrls;

  const UploadUserImagesResultApiModel({required this.imageUrls});

  factory UploadUserImagesResultApiModel.fromResponse(
    Map<String, dynamic> body,
  ) {
    final directUrls = body['images'] is List
        ? (body['images'] as List<dynamic>)
              .map((item) => item.toString().trim())
              .where((item) => item.isNotEmpty)
              .toList()
        : <String>[];

    if (directUrls.isNotEmpty) {
      return UploadUserImagesResultApiModel(imageUrls: directUrls);
    }

    final data = body['data'] is Map<String, dynamic>
        ? body['data'] as Map<String, dynamic>
        : <String, dynamic>{};

    final images = data['images'] is List
        ? (data['images'] as List<dynamic>).whereType<Map>().toList()
        : <Map<dynamic, dynamic>>[];

    final mapped = images
        .map((image) {
          final url = image['url']?.toString().trim() ?? '';
          return url;
        })
        .where((url) => url.isNotEmpty)
        .toList();

    return UploadUserImagesResultApiModel(imageUrls: mapped);
  }

  UploadUserImagesResultEntity toEntity() {
    return UploadUserImagesResultEntity(imageUrls: imageUrls);
  }
}
