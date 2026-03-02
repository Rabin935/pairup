import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/utils/snackbar_helper.dart';
import 'package:pairup/features/auth/presentation/pages/login_screen.dart';
import 'package:pairup/features/auth/presentation/state/auth_state.dart';
import 'package:pairup/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:pairup/features/auth/presentation/widgets/auth_form_widgets.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreedToTerms = false;
  bool _isSubmitting = false;

  final String _selectedCountryCode = '+977';
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

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
    if (_isSubmitting) return;

    final firstname = _firstnameController.text.trim();
    final lastname = _lastnameController.text.trim();
    final email = _emailController.text.trim();
    final phone = '$_selectedCountryCode${_phoneController.text.trim()}';
    final password = _passController.text.trim();

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref
          .read(authViewModelProvider.notifier)
          .register(
            firstname: firstname,
            lastname: lastname,
            email: email,
            password: password,
            phoneNumber: phone,
          );

      final currentState = ref.read(authViewModelProvider);

      if (!mounted) return;

      if (currentState.status == AuthStatus.registered) {
        showCustomSuccessSnackBar(context, 'Account created successfully!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        showCustomErrorSnackBar(
          context,
          currentState.errorMessage ?? 'Registration failed',
        );
      }
    } catch (_) {
      if (!mounted) return;
      showCustomErrorSnackBar(
        context,
        'Registration failed. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String? _validateName(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    if (value.trim().length < 2) {
      return '$label is too short';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final email = value.trim();
    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.[A-Za-z]{2,}$').hasMatch(email)) {
      return 'Enter a valid email';
    }

    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone Number is required';
    }

    final phone = value.trim();
    if (!RegExp(r'^\d{7,15}$').hasMatch(phone)) {
      return 'Enter a valid phone number';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirmation is required';
    }
    if (value != _passController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageBackground(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (Navigator.of(context).canPop())
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
            ),
          const AuthHeader(
            title: 'Join Us Today',
            subtitle:
                'Create your account and start discovering meaningful matches.',
          ),
          const SizedBox(height: 22),
          AuthCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstnameController,
                          textInputAction: TextInputAction.next,
                          decoration: authInputDecoration(
                            labelText: 'First Name',
                            hintText: 'Rabin',
                            icon: Icons.person_outline,
                          ),
                          validator: (value) =>
                              _validateName(value, 'First Name'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _lastnameController,
                          textInputAction: TextInputAction.next,
                          decoration: authInputDecoration(
                            labelText: 'Last Name',
                            hintText: 'Sharma',
                            icon: Icons.person_outline,
                          ),
                          validator: (value) =>
                              _validateName(value, 'Last Name'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('email'),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: authInputDecoration(
                      labelText: 'Email',
                      hintText: 'you@example.com',
                      icon: Icons.email_outlined,
                    ),
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AuthPalette.primaryLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AuthPalette.primary.withValues(alpha: 0.24),
                          ),
                        ),
                        child: Text(
                          _selectedCountryCode,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AuthPalette.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          decoration: authInputDecoration(
                            labelText: 'Phone Number',
                            hintText: '98XXXXXXXX',
                            icon: Icons.phone_outlined,
                          ),
                          validator: _validatePhone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('password'),
                    controller: _passController,
                    obscureText: !_isPasswordVisible,
                    textInputAction: TextInputAction.next,
                    decoration: authInputDecoration(
                      labelText: 'Password',
                      hintText: 'Create a strong password',
                      icon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmPassController,
                    obscureText: !_isConfirmPasswordVisible,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleSignup(),
                    decoration: authInputDecoration(
                      labelText: 'Confirm Passcode',
                      hintText: 'Re-enter your passcode',
                      icon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: _validateConfirmPassword,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _agreedToTerms,
                        activeColor: AuthPalette.primary,
                        onChanged: (val) {
                          setState(() {
                            _agreedToTerms = val ?? false;
                          });
                        },
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 11),
                          child: Text.rich(
                            TextSpan(
                              text: 'I agree to the ',
                              style: TextStyle(fontSize: 12),
                              children: [
                                TextSpan(
                                  text: 'Terms & Conditions ',
                                  style: TextStyle(
                                    color: AuthPalette.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(text: 'and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: AuthPalette.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AuthPrimaryButton(
                    label: 'Create Account',
                    onPressed: _handleSignup,
                    isLoading: _isSubmitting,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Already have an account? '),
              GestureDetector(
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    color: AuthPalette.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
