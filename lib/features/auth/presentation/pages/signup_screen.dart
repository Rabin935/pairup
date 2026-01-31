import 'package:flutter/material.dart';
import 'package:pairup/core/api/api_client.dart';
import 'package:pairup/core/api/api_endpoint.dart';
import 'package:pairup/features/auth/presentation/pages/login_screen.dart';
import 'package:pairup/core/utils/snackbar_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  // State variables
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreedToTerms = false; // Default value
  final _selectedCountryCode = '+977';

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  // String _selectedGender = 'Male';

  // Consistent Theme Color
  static const Color primaryPurple = Color(0xFF6C63FF);

  // final List<Map<String, String>> _countryCodes = [
  //   {'code': '+977', 'name': 'Nepal', 'flag': '🇳🇵'},
  //   {'code': '+91', 'name': 'India', 'flag': '🇮🇳'},
  //   {'code': '+1', 'name': 'USA', 'flag': '🇺🇸'},
  //   {'code': '+44', 'name': 'UK', 'flag': '🇬🇧'},
  //   {'code': '+86', 'name': 'China', 'flag': '🇨🇳'},
  // ];

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_agreedToTerms) {
      showCustomErrorSnackBar(
        context,
        'Please agree to the Terms & Conditions',
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final firstname = _firstnameController.text.trim();
    final lastname = _lastnameController.text.trim();
    final email = _emailController.text.trim();
    final phone = '$_selectedCountryCode${_phoneController.text.trim()}';
    final password = _passController.text.trim();
    final confirmPassword = _confirmPassController.text.trim();

    try {
      // Call your backend API
      final apiClient = ApiClient();
      final response = await apiClient.post(
        ApiEndpoints.userRegister,
        data: {
          'firstname': firstname,
          'lastname': lastname,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
          'number': phone,
          'authProvider': 'local',
        },
      );

      if (response.data['success'] == true) {
        if (!mounted) return;
        showCustomSuccessSnackBar(context, 'Account created successfully!');

        // Navigate to login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        showCustomErrorSnackBar(
          context,
          response.data['message'] ?? 'Registration failed',
        );
      }
    } catch (e) {
      showCustomErrorSnackBar(context, 'Registration failed: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Updated Logo (Purple rounded box with user-add icon)
              Image.asset('assets/images/pairuplogo.png', height: 90),

              const SizedBox(height: 24),

              // 2. Headings
              const Text(
                'Join Us Today',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create your account to get started',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // 3. Full Name Field
              _buildTextField(
                hint: "First Name",
                icon: Icons.person_outline,
                controller: _firstnameController,
              ),

              _buildTextField(
                hint: "last Name",
                icon: Icons.person_outline,
                controller: _lastnameController,
              ),

              // 4. Email Field
              _buildTextField(
                hint: "Email Address",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
              ),

              // 5. Phone Number Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          "🇳🇵",
                          style: TextStyle(fontSize: 18),
                        ), // Flag icon
                        SizedBox(width: 8),
                        Text(
                          "+977",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      hint: "Phone Number",
                      icon: Icons.phone_outlined,
                      controller: _phoneController,
                    ),
                  ),
                ],
              ),

              // 7. Password Field
              TextFormField(
                controller: _passController,
                obscureText: !_isPasswordVisible,
                decoration:
                    _inputDecoration(
                      "Create a strong password",
                      Icons.lock_outline,
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        ),
                      ),
                    ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "password is required";
                  }
                  if (value != _passController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 8. Confirm Password
              TextFormField(
                controller: _confirmPassController,
                obscureText: !_isConfirmPasswordVisible,
                decoration:
                    _inputDecoration(
                      "Confirm Password",
                      Icons.lock_outline,
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () => setState(
                          () => _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible,
                        ),
                      ),
                    ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Confirm password is required";
                  }
                  if (value != _passController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 80),

              // 9. Terms & Conditions Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    activeColor: primaryPurple,
                    onChanged: (val) => setState(() => _agreedToTerms = val!),
                  ),
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: "I agree to the ",
                        style: TextStyle(fontSize: 12),
                        children: [
                          TextSpan(
                            text: "Terms & Conditions ",
                            style: TextStyle(
                              color: primaryPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(text: "and "),
                          TextSpan(
                            text: "Privacy Policy",
                            style: TextStyle(
                              color: primaryPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 10. Create Account Button
              ElevatedButton(
                onPressed: _handleSignup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPurple,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Create Account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // 11. Footer Login Link
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: primaryPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  // --- UI Helpers ---

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.grey),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryPurple, width: 2),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: _inputDecoration(hint, icon),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          if (hint.contains('Email') && !value.contains('@')) {
            return 'Enter a valid email';
          }
          return null;
        },
      ),
    );
  }
}
