import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/widgets/profileitemmenu_widget.dart';
import 'package:pairup/features/auth/presentation/pages/login_screen.dart';

final accNameProvider = Provider<String>((ref) {
  return "Rabin";
});

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Account',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    'https://res.cloudinary.com/dtndr0wru/image/upload/v1764936474/curly_bra96e.jpg',
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rabin',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.verified,
                          color: Colors.blue.shade600,
                          size: 20,
                        ),
                      ],
                    ),
                    const Text(
                      'Kathmandu, Nepal',
                      style: TextStyle(color: Color(0xFF505050), fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF7F3DDB,
                  ), // Purple color from image
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                // backgroundColor: ,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Create Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // --- Menu Items ---
            ProfileMenuItem(
              icon: Icons.block_flipped,
              title: "Blocked",
              onTap: () {},
            ),
            ProfileMenuItem(
              icon: Icons.mail_outline,
              title: "Email Address",
              trailing: "l******5@gmail.com",
              onTap: () {},
            ),
            ProfileMenuItem(
              icon: Icons.qr_code_scanner,
              title: "Redeem code",
              onTap: () {},
            ),
            ProfileMenuItem(
              icon: Icons.verified_outlined,
              title: "Upgrade to Premium",
              onTap: () {},
            ),
            ProfileMenuItem(
              icon: Icons.settings_outlined,
              title: "Settings",
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
