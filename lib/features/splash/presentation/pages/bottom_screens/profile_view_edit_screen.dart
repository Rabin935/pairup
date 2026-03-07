import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pairup/core/api/api_client.dart';
import 'package:pairup/core/utils/snackbar_helper.dart';

class ProfileViewEditScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ProfileViewEditScreen({super.key, required this.userData});

  @override
  State<ProfileViewEditScreen> createState() => _ProfileViewEditScreenState();
}

class _ProfileViewEditScreenState extends State<ProfileViewEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiClient _apiClient = ApiClient();
  final ImagePicker _imagePicker = ImagePicker();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _ageController;
  late final TextEditingController _locationController;
  late final TextEditingController _bioController;
  late final TextEditingController _interestInputController;
  late final TextEditingController _phoneNumberController;

  String? _gender;
  String? _interestedIn;
  String _selectedCountryCode = '+977';
  XFile? _selectedImage;
  bool _removeProfileImage = false;
  List<String> _interests = [];
  bool _isSaving = false;

  final List<String> _countryCodes = const ['+977', '+91', '+1', '+44', '+86', '+61', '+81'];

  String _asText(dynamic value, [String fallback = '']) {
    final text = (value ?? '').toString().trim();
    return text.isEmpty ? fallback : text;
  }

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: _asText(widget.userData['firstname']));
    _lastNameController = TextEditingController(text: _asText(widget.userData['lastname']));
    _emailController = TextEditingController(text: _asText(widget.userData['email']));
    _ageController = TextEditingController(text: _asText(widget.userData['age']));
    _locationController = TextEditingController(text: _asText(widget.userData['location']));
    _bioController = TextEditingController(text: _asText(widget.userData['bio']));
    _interestInputController = TextEditingController();
    _phoneNumberController = TextEditingController();

    final rawInterests = widget.userData['interests'];
    if (rawInterests is List) {
      _interests = rawInterests.map((item) => item.toString().trim()).where((e) => e.isNotEmpty).toList();
    }

    final rawNumber = _asText(widget.userData['number']);
    if (rawNumber.isNotEmpty) {
      final matchedCode = _countryCodes.firstWhere(
        (code) => rawNumber.startsWith(code),
        orElse: () => '+977',
      );
      _selectedCountryCode = matchedCode;
      _phoneNumberController.text = rawNumber.substring(matchedCode.length);
    }

    final parsedGender = _asText(widget.userData['gender']).toLowerCase();
    _gender = ['male', 'female', 'other'].contains(parsedGender) ? parsedGender : null;

    final parsedInterestedIn = _asText(widget.userData['interestedIn']).toLowerCase();
    _interestedIn = ['male', 'female'].contains(parsedInterestedIn) ? parsedInterestedIn : null;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _interestInputController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  String get _currentImageUrl {
    final profileImage = _asText(widget.userData['profileImage']);
    if (profileImage.isNotEmpty) return profileImage;
    return _asText(widget.userData['image']);
  }

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image == null) return;

    setState(() {
      _selectedImage = image;
      _removeProfileImage = false;
    });
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _removeProfileImage = true;
    });
  }

  void _addInterest() {
    final value = _interestInputController.text.trim();
    if (value.isEmpty) return;
    if (_interests.any((item) => item.toLowerCase() == value.toLowerCase())) {
      _interestInputController.clear();
      return;
    }
    setState(() {
      _interests.add(value);
      _interestInputController.clear();
    });
  }

  void _removeInterest(String value) {
    setState(() {
      _interests.remove(value);
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final userId = _asText(widget.userData['_id']);
      if (userId.isEmpty) {
        showCustomErrorSnackBar(context, 'Unable to update profile: missing user id');
        setState(() => _isSaving = false);
        return;
      }

      final ageText = _ageController.text.trim();
      final age = ageText.isEmpty ? null : int.tryParse(ageText);
      if (ageText.isNotEmpty && age == null) {
        showCustomErrorSnackBar(context, 'Age must be a valid number');
        setState(() => _isSaving = false);
        return;
      }

      final normalizedPhone = '$_selectedCountryCode${_phoneNumberController.text.trim()}';

      final payload = <String, dynamic>{
        'location': _locationController.text.trim(),
        'bio': _bioController.text.trim(),
        'interests': _interests,
      };

      if (age != null) payload['age'] = age;
      if (_gender != null && _gender!.isNotEmpty) payload['gender'] = _gender;
      if (_interestedIn != null && _interestedIn!.isNotEmpty) {
        payload['interestedIn'] = _interestedIn;
      }

      final completeResponse = await _apiClient.put('/api/users/update-profile', data: payload);
      final completeBody = completeResponse.data as Map<String, dynamic>;

      if (completeBody['success'] != true) {
        if (!mounted) return;
        showCustomErrorSnackBar(context, _asText(completeBody['message'], 'Update failed'));
        setState(() => _isSaving = false);
        return;
      }

      final profilePayload = <String, dynamic>{'number': normalizedPhone};

      if (_selectedImage != null) {
        profilePayload['image'] = await MultipartFile.fromFile(
          _selectedImage!.path,
          filename: _selectedImage!.name,
        );
      }

      if (_removeProfileImage) {
        profilePayload['image'] = '';
        profilePayload['profileImage'] = '';
        profilePayload['profileImagePublicId'] = '';
      }

      final authResponse = await _apiClient.put(
        '/api/auth/$userId',
        data: FormData.fromMap(profilePayload),
      );
      final body = authResponse.data as Map<String, dynamic>;

      if (!mounted) return;

      if (body['success'] == true) {
        showCustomSuccessSnackBar(context, 'Profile updated');
        Navigator.pop(context, true);
      } else {
        showCustomErrorSnackBar(context, _asText(body['message']).isEmpty ? 'Update failed' : _asText(body['message']));
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        showCustomErrorSnackBar(context, _asText(data['message'], 'Unable to update profile'));
      } else {
        showCustomErrorSnackBar(context, 'Unable to update profile');
      }
    } catch (e) {
      if (!mounted) return;
      showCustomErrorSnackBar(context, 'Unable to update profile');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View & Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: const Color(0xFFEDE9FE),
                      backgroundImage: _selectedImage != null
                          ? FileImage(File(_selectedImage!.path))
                          : (_removeProfileImage
                                ? null
                                : (_currentImageUrl.isNotEmpty ? NetworkImage(_currentImageUrl) : null)),
                      child: (_selectedImage == null && (_removeProfileImage || _currentImageUrl.isEmpty))
                          ? const Icon(Icons.person, size: 42, color: Color(0xFF7F3DDB))
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Add / Change Image'),
                        ),
                        TextButton.icon(
                          onPressed: _removeImage,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Remove'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _firstNameController,
                enabled: false,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastNameController,
                enabled: false,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                enabled: false,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(
                    width: 110,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedCountryCode,
                      decoration: const InputDecoration(labelText: 'Code'),
                      items: _countryCodes
                          .map((code) => DropdownMenuItem(value: code, child: Text(code)))
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedCountryCode = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Phone Number'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Age'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Male')),
                  DropdownMenuItem(value: 'female', child: Text('Female')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (value) {
                  setState(() => _gender = value);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _interestedIn,
                decoration: const InputDecoration(labelText: 'Interested In'),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Male')),
                  DropdownMenuItem(value: 'female', child: Text('Female')),
                ],
                onChanged: (value) {
                  setState(() => _interestedIn = value);
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _interestInputController,
                      decoration: const InputDecoration(
                        labelText: 'Add Interest',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addInterest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7F3DDB),
                    ),
                    child: const Text('Add', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _interests
                    .map(
                      (interest) => Chip(
                        label: Text(interest),
                        onDeleted: () => _removeInterest(interest),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bioController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Bio'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7F3DDB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
