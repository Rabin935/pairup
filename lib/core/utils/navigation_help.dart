import 'package:flutter/material.dart';

import 'package:pairup/features/splash/presentation/pages/navigation_botton_screen.dart';

// Import other common destinations like LoginScreen if needed

void navigateToHomeReplacement(BuildContext context) {
  // Use pushReplacement to clear the stack (useful after Login/Signup)
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => const NavigationBottonScreen()),
  );
}
