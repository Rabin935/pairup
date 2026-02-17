import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/utils/navigation_help.dart';
import 'package:pairup/core/utils/snackbar_helper.dart';
import 'package:pairup/features/auth/presentation/pages/signup_screen.dart';
import 'package:pairup/features/auth/presentation/state/auth_state.dart';
import 'package:pairup/features/auth/presentation/view_model/auth_viewmodel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isPasswordVisible = false;
  bool _isSubmitting = false;
  final _formkey = GlobalKey<FormState>();

  // ✅ Controllers (REQUIRED)
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleLogin() async {
    if (!_formkey.currentState!.validate()) return;
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

  static const Color primaryPurple = Color(0xFF8A2BE2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
        child: Form(
          key: _formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Login to PairUp",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),
              Image.asset('assets/images/pairuplogo.png', height: 90),
              const SizedBox(height: 60),

              // ✅ Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  hintText: "example@gmail.com",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!value.contains('@')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ✅ Password
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
                    return 'Password too short';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ✅ Login Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPurple,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Login',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Not a member yet?"),
                  TextButton(
                    onPressed: _navigateToRegistration,
                    child: const Text(
                      "Join now",
                      style: TextStyle(
                        color: primaryPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
