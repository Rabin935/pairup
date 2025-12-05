import 'package:flutter/material.dart';
import 'package:pairup/screens/home_screen.dart';
import 'package:pairup/screens/get_start_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<SignupScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PairUp Sign Up',
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const SignUpScreen(),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // State to manage password visibility
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    // Determine the screen width for responsive padding
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 600 ? screenWidth * 0.2 : 32.0;

    return Scaffold(
      // 1. AppBar with Back Button
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigator.pop(context) or similar action
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GetStartScreen()),
            );
          },
        ),
        // Set background color to white and elevation to 0 to match the image
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      // Use SingleChildScrollView to prevent overflow on small devices or when keyboard appears
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 24.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // 2. Title Text
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

              // 3. Logo (Using a placeholder Icon)
              const Center(
                child: Icon(
                  // Using a heart/people icon placeholder
                  Icons.favorite_rounded,
                  size: 64,
                  color:
                      Colors.black, // Assuming the logo is black in the image
                ),
              ),

              const SizedBox(height: 48.0),

              // 4. Email Input Field
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Enter your email',
                  contentPadding: EdgeInsets.all(16.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),

              const SizedBox(height: 16.0),

              // 5. Password Input Field
              TextFormField(
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'Password',
                  contentPadding: const EdgeInsets.all(16.0),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  // Eye icon for password visibility toggle
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
              ),

              const SizedBox(height: 8.0),

              // 6. Forgot Password Button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Handle navigation to forgot password screen
                  },
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: Colors.blue, // A clear blue link color
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24.0),

              // 7. Sign In Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                  // Handle sign in logic
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor:
                      Colors.grey[600], // Darker grey for the button background
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Sign in',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 32.0),

              // 8. Legal Text Footer
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4.0, right: 8.0),
                    // Lock icon for security/legal context
                    child: Icon(
                      Icons.lock_outline_rounded,
                      size: 18,
                      color: Colors.black54,
                    ),
                  ),

                  // Use Flexible/Expanded to wrap the text nicely
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
                                'By creating an account, you confirm you are atleast 18 years old and agree to out ',
                          ),
                          TextSpan(
                            text: 'Terms',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              decoration: TextDecoration.underline,
                            ),
                            // In a real app, this would use a recognizer to handle tap
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy.',
                            style: TextStyle(
                              color: Colors.blue.shade700,
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
    );
  }
}
