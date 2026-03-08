import 'package:flutter/material.dart';
import 'package:pairup/features/auth/presentation/pages/signup_screen.dart';
import 'package:pairup/features/splash/presentation/models/onboarding_model.dart';

final List<OnboardingPageModel> onboardingPages = [
  OnboardingPageModel(
    imageUrl: 'assets/images/onboardimage1.jpg',
    title: 'Meet New People With Real Intentions',
    description:
        'Discover meaningful profiles, chat naturally, and build genuine connections.',
  ),
  OnboardingPageModel(
    imageUrl: 'assets/images/onboardimage2.jpg',
    title: 'Match Beyond Just Photos',
    description:
        'Find users by interests, lifestyle, and compatibility so every match feels relevant.',
  ),
  OnboardingPageModel(
    imageUrl: 'assets/images/onboardimage3.jpg',
    title: 'Start Your Next Story On PairUp',
    description:
        'Your next close connection can begin with a single swipe and a simple hello.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const OnboardingScreen({super.key, this.onComplete});

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

  void _navigateToSignUp() {
    widget.onComplete?.call();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const SignupScreen()));
  }

  void _next() {
    if (_currentPage < onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    _navigateToSignUp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAFD),
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: onboardingPages.length,
              onPageChanged: (page) => setState(() => _currentPage = page),
              itemBuilder: (context, index) {
                return _OnboardingPage(page: onboardingPages[index]);
              },
            ),
            Positioned(
              top: 10,
              right: 16,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF005F73),
                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                onPressed: _navigateToSignUp,
                child: const Text(
                  'Skip',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 26,
              child: Row(
                children: [
                  Row(
                    children: List.generate(
                      onboardingPages.length,
                      (index) => _buildDot(index),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 56,
                    width: 56,
                    child: FloatingActionButton(
                      elevation: 0,
                      onPressed: _next,
                      backgroundColor: const Color(0xFFEE6C4D),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    final active = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(right: 6),
      height: 8,
      width: active ? 24 : 8,
      decoration: BoxDecoration(
        color: active ? const Color(0xFFEE6C4D) : const Color(0xFFD4E5EB),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingPageModel page;

  const _OnboardingPage({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 110),
      child: Column(
        children: [
          Expanded(
            flex: 6,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.asset(
                  page.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE3EDF1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    page.title,
                    style: const TextStyle(
                      fontSize: 26,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0B3C49),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    page.description,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF4E6A73),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
