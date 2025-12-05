import 'package:flutter/material.dart';
import 'package:pairup/screens/get_start_screen.dart';
// Import your OnboardingScreen from the previous code


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start the loading process when the screen initializes
    _startAppLoading();
  }

  // --- Logic to handle the delay and navigation ---
  void _startAppLoading() async {
    // 1. Define the delay duration (e.g., 3 seconds)
    await Future.delayed(const Duration(seconds: 3));

    // 2. Navigate to the OnboardingScreen after the delay
    // Use pushReplacement to prevent the user from navigating back to the splash screen
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const GetStartScreen()),
      );
    }
  }

  // --- UI Implementation ---
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // Set the background color (e.g., white or your app's main color)
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 1. Placeholder for your App Logo/Image 🖼️
            // Replace this with your actual Image.asset('assets/logo.png')
            FlutterLogo(size: 150),

            SizedBox(height: 50),

            // 2. Loading Indicator 🔄️
            // The CircularProgressIndicator gives the user feedback that something is loading
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xFF673AB7),
              ), // Use your app's purple color
            ),
          ],
        ),
      ),
    );
  }
}
