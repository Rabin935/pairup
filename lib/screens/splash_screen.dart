import 'package:flutter/material.dart';
import 'package:pairup/screens/get_start_screen.dart';
// Note: Ensure the path above is correct for your project structure

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start the navigation process when the screen initializes
    _startAppLoading();
  }

  // --- Logic to handle the delay and navigation ---
  void _startAppLoading() async {
    // Wait for 3 seconds
    await Future.delayed(const Duration(seconds: 3));

    // Navigate to the GetStartScreen after the delay, replacing the current screen
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const GetStartScreen()),
      );
    }
  }

  // --- UI Implementation ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 1. CUSTOM LOGO: Uses the asset path you specified previously
            Image.asset(
              'assets/images/pairup.png', // **Make sure this path is correct!**
              height: 600,
            ),

            const SizedBox(height: 50),

            // 2. Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xFF673AB7), // Purple color indicator
              ),
            ),
          ],
        ),
      ),
    );
  }
}
