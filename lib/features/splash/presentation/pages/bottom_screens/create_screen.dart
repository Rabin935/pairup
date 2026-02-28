import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pairup/core/services/permission/permission_service.dart';
import 'package:pairup/core/utils/snackbar_helper.dart';
import 'package:pairup/features/user/domain/usecases/upload_user_images_usecase.dart';
import 'package:permission_handler/permission_handler.dart';

class CreateScreen extends ConsumerStatefulWidget {
  const CreateScreen({super.key});

  @override
  ConsumerState<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends ConsumerState<CreateScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  List<XFile> _selectedImages = [];
  List<String> _uploadedImages = [];
  bool _isUploading = false;

  Future<void> _pickImagesFromGallery() async {
    final images = await _imagePicker.pickMultiImage(imageQuality: 82);
    if (images.isEmpty) return;
    setState(() {
      _selectedImages = [..._selectedImages, ...images];
    });
  }

  Future<void> _pickImageFromCamera() async {
    final permissionService = ref.read(permissionServiceProvider);
    final status = await permissionService.requestPermissionWithDialog(
      context: context,
      permission: Permission.camera,
      title: 'Camera Permission Required',
      message:
          'PairUp needs camera access so you can take photos and upload them instantly.',
    );

    if (!status.isGranted) return;

    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 82,
    );
    if (image == null) return;

    setState(() {
      _selectedImages = [..._selectedImages, image];
    });
  }

  Future<void> _showImageSourcePicker() async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _pickImagesFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Use camera'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _pickImageFromCamera();
                },
              ),
              const SizedBox(height: 4),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadImages() async {
    if (_selectedImages.isEmpty || _isUploading) {
      if (_selectedImages.isEmpty) {
        showCustomErrorSnackBar(context, 'Please select at least one image');
      }
      return;
    }

    setState(() => _isUploading = true);

    final usecase = ref.read(uploadUserImagesUsecaseProvider);
    final result = await usecase(
      UploadUserImagesUsecaseParams(
        imageFilePaths: _selectedImages.map((image) => image.path).toList(),
      ),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        showCustomErrorSnackBar(context, failure.message);
      },
      (uploaded) {
        setState(() {
          _uploadedImages = uploaded.imageUrls;
          _selectedImages = [];
        });
        showCustomSuccessSnackBar(context, 'Images uploaded successfully');
      },
    );

    if (mounted) {
      setState(() => _isUploading = false);
    }
  }

  Widget _sectionCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7E1F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFAFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBFAFF),
        elevation: 0,
        title: const Text(
          'Create',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        children: [
          _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upload photos',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Add new images to your profile gallery.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: _showImageSourcePicker,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFD8CCF3),
                        style: BorderStyle.solid,
                      ),
                      color: const Color(0xFFF7F2FF),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 34,
                          color: Color(0xFF673AB7),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Select Images (Gallery / Camera)',
                          style: TextStyle(
                            color: Color(0xFF673AB7),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_selectedImages.isNotEmpty)
            _sectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preview (${_selectedImages.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      final image = _selectedImages[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(File(image.path), fit: BoxFit.cover),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _uploadImages,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF673AB7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isUploading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Upload Images',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          if (_uploadedImages.isNotEmpty)
            _sectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Uploaded gallery',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                    itemCount: _uploadedImages.length,
                    itemBuilder: (context, index) {
                      final image = _uploadedImages[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (
                                BuildContext context,
                                Object error,
                                StackTrace? stackTrace,
                              ) => Container(
                                color: const Color(0xFFF1F1F1),
                                child: const Icon(Icons.broken_image_outlined),
                              ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
