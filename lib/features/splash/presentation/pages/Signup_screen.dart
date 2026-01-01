import 'package:flutter/material.dart';
import 'package:pairup/features/splash/presentation/pages/get_start_screen.dart';
import 'package:pairup/features/splash/presentation/pages/login_screen.dart';
import 'package:pairup/core/utils/navigation_help.dart'; // Assuming these paths are correct
import 'package:pairup/core/utils/snackbar_helper.dart'; // Assuming these paths are correct


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
 
  State<SignupScreen> createState() => _SignupScreenState();
}


class _SignupScreenState extends State<SignupScreen> {
  
  bool _isPasswordVisible = false;


  final _formkey = GlobalKey<FormState>();

  // Define the consistent color
  static const Color primaryPurple = Color(0xFF8A2BE2);

 
  void _handleSignup() {
    if (_formkey.currentState!.validate()) {
      
      navigateToHomeReplacement(context);
    } else {
      
      showCustomErrorSnackBar(
        context,
        'Sign up failed. Please correct the highlighted errors.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    

    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 600 ? screenWidth * 0.2 : 32.0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GetStartScreen()),
            );
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 24.0,
          ),
          // 4. Wrap the entire input section with the Form widget and assign the key
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Sign up to PairUp',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 32.0),

                // Logo Placeholder
                const Center(
                  child: Icon(
                    Icons.favorite_rounded,
                    size: 64,
                    color: primaryPurple, // Use primary color for logo
                  ),
                ),

                const SizedBox(height: 48.0),

                // Email Input Field
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Enter your email",
                    hintText: "example@email.com",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18.0,
                      horizontal: 16.0,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email.';
                    }
                    // Basic email format check (corrected logic)
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16.0),

                // Password Input Field
                TextFormField(
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "********",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18.0,
                      horizontal: 16.0,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
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
                      return 'Please enter your password.';
                    }

                    if (value.length < 8) {
                      return 'Password must be at least 8 characters long.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 8.0),

                // Forgot Password Button
                const SizedBox(height: 24.0),

                // 5. Sign Up Button (Fixed: linked to logic, corrected text and color)
                ElevatedButton(
                  onPressed: _handleSignup, // The fix: call the logic method
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor:
                        primaryPurple, // Use primary color for Sign Up
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Sign Up', // Corrected text
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 10.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    Align(
                      child: TextButton(
                        onPressed: () {
                          // Navigate to Login screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: primaryPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 200.0),

                // Legal Text Footer
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0, right: 8.0),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        size: 18,
                        color: Colors.black54,
                      ),
                    ),

                    Flexible(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 13.0,
                            color: Colors.black,
                            height: 1.5,
                          ),
                          children: <TextSpan>[
                            const TextSpan(
                              text:
                                  'By creating an account, you confirm you are at least 18 years old and agree to our ',
                            ),
                            TextSpan(
                              text: 'Terms',
                              style: TextStyle(
                                color: primaryPurple,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy.',
                              style: TextStyle(
                                color: primaryPurple,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
