import 'package:flutter/material.dart';
import 'package:pairup/features/splash/presentation/models/onboarding_model.dart';
import 'package:pairup/features/auth/presentation/pages/signup_screen.dart';

// --- Data Model for Onboarding Pages ---


// --- List of Onboarding Pages (Matching your image) ---
final List<OnboardingPageModel> onboardingPages = [
  OnboardingPageModel(
    imageUrl:
        'assets/images/onboardimage1.jpg', // Replace with your actual asset path
    title: 'Chat with strangers and make them your partners.', 
    description:
        'Chat with strangers to know each other better and have a nice compatibility.',
        
  ),
  OnboardingPageModel(
    imageUrl:
        'assets/images/onboardimage2.jpg', // Replace with your actual asset path
    title: 'Make friends by connecting with world',
    description:
        'You can connect with people around the world for doing messages with people and make connection with them',
  ),
  OnboardingPageModel(
    imageUrl:
        'assets/images/onboardimage3.jpg', // Replace with your actual asset path
    title: 'Choose your partner from same internet',
    description:
        'Chat with strangers by seeing the common interests to get connected with each other in better way',
  ),
];

// --- Main Onboarding Screen Widget ---
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required Null Function() onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Function to navigate to the SignUpPage
  void _navigateToSignUp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. PageView for Swiping Onboarding Content
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingPages.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return OnboardingPage(page: onboardingPages[index]);
            },
          ),
          // 2. Bottom Navigation/Controls
          Positioned(
            bottom: 40.0,
            left: 20.0,
            right: 20.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Page Indicator Dots
                Row(
                  children: List.generate(
                    onboardingPages.length,
                    (index) => buildDot(index, context),
                  ),
                ),
                // Forward/Next/Finish Button
                FloatingActionButton(
                  onPressed: () {
                    if (_currentPage < onboardingPages.length - 1) {
                      // Navigate to the next page
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeIn,
                      );
                    } else {
                      // **Final Screen: Navigate to SignUpPage**
                      _navigateToSignUp();
                    }
                  },
                  backgroundColor: const Color(
                    0xFF673AB7,
                  ), // Example color for the purple button
                  shape: const CircleBorder(),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget for the Page Indicator Dots
  AnimatedContainer buildDot(int index, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 6,
      width: _currentPage == index ? 20 : 6,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? const Color(0xFF673AB7) // Active dot color
            : Colors.grey.shade300, // Inactive dot color
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

// --- Single Onboarding Page Content Widget ---
class OnboardingPage extends StatelessWidget {
  final OnboardingPageModel page;

  const OnboardingPage({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(
              80.0,
            ), // Set your desired radius here
          ),

          // Placeholder for the illustration/image
          // Use Image.asset(page.imageUrl) when you have the actual assets
          Image.asset(page.imageUrl, height: 300),
          const SizedBox(height: 50.0),
          // Title
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 15.0),
          // Description
          Text(
            page.description,
            style: TextStyle(fontSize: 16.0, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
