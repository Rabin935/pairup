import 'package:flutter/material.dart';
import 'package:pairup/features/splash/presentation/pages/onboarding_screen.dart';
// Assuming OnboardingScreen is a StatelessWidget or StatefulWidget without required parameters

class GetStartScreen extends StatelessWidget {
  // Changed to StatelessWidget
  const GetStartScreen({super.key});

  // Define the gradient colors based on the design
  static const Color startColor = Color(0xFF6A5ACD); // Example Blue-Purple
  static const Color endColor = Color(0xFF8A2BE2); // Example Violet-Purple
  static const Color buttonTextColor = Color(
    0xFF000000,
  ); 

 
  void _navigateToOnboarding(BuildContext context) {
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        
        builder: (context) => OnboardingScreen(onComplete: () {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold background is transparent as the Container handles the gradient
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            // Use slightly adjusted colors for a closer match to the design's blend
            colors: [startColor, endColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Column(
          children: [
            const Spacer(flex: 4),

            // Logo and Title Section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image asset path from your existing code
                Image.asset(
                  'assets/images/pairuplogo.png',
                  height: 130, // Good height
                  color:
                      Colors.white, // Assumes logo icon is white as per design
                ),

                const SizedBox(width: 15),
                const Text(
                  "PairUp",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            const Spacer(flex: 3), // Pushes the content down
            // "Get Started" Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      _navigateToOnboarding(context), // Use the helper function

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation:
                        0, // Remove shadow for a flat look as in the design
                  ),

                  child: const Text(
                    "Get Started",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: buttonTextColor, // Using defined black color
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Terms and Privacy Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ), // Slightly smaller font for legal text
                  children: [
                    TextSpan(text: 'By signing, you agree to our '),
                    TextSpan(
                      text: "Terms.",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    TextSpan(text: "\nSee how we use your data in our "),
                    TextSpan(
                      text: "Privacy Policy.",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
