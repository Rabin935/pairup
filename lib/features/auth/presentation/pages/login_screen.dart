import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/utils/navigation_help.dart';
import 'package:pairup/core/utils/snackbar_helper.dart';
import 'package:pairup/features/auth/presentation/pages/signup_screen.dart';
import 'package:pairup/features/auth/presentation/state/auth_state.dart';
import 'package:pairup/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:pairup/features/auth/presentation/widgets/auth_form_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isPasswordVisible = false;
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authState = ref.read(authViewModelProvider.notifier);
      await authState.login(email, password);

      final currentState = ref.read(authViewModelProvider);

      if (!mounted) return;

      if (currentState.status == AuthStatus.authenticated) {
        navigateToHomeReplacement(context);
      } else {
        showCustomErrorSnackBar(
          context,
          currentState.errorMessage ?? 'Unable to login. Please try again.',
        );
      }
    } catch (_) {
      if (!mounted) return;
      showCustomErrorSnackBar(
        context,
        'Unable to login right now. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _navigateToRegistration() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SignupScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageBackground(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 14),
            const AuthHeader(
              title: 'Login to PairUp',
              subtitle:
                  'Welcome back. Continue matching and chatting with your circle.',
            ),
            const SizedBox(height: 26),
            AuthCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: authInputDecoration(
                      labelText: 'Email',
                      hintText: 'example@gmail.com',
                      icon: Icons.mail_outline,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }

                      final email = value.trim();
                      if (!RegExp(
                        r'^[\w\.-]+@[\w\.-]+\.[A-Za-z]{2,}$',
                      ).hasMatch(email)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleLogin(),
                    decoration: authInputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  AuthPrimaryButton(
                    label: 'Login',
                    onPressed: _handleLogin,
                    isLoading: _isSubmitting,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Not a member yet?'),
                TextButton(
                  onPressed: _navigateToRegistration,
                  child: const Text(
                    'Join now',
                    style: TextStyle(
                      color: AuthPalette.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
