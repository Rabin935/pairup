import 'package:flutter/material.dart';

class AuthPalette {
  const AuthPalette._();

  static const Color primary = Color(0xFF7F3DDB);
  static const Color primaryLight = Color(0xFFEFE5FF);
  static const Color pageBackground = Color(0xFFF7F3FF);
  static const Color textSecondary = Color(0xFF6A6F79);
}

class AuthPageBackground extends StatelessWidget {
  const AuthPageBackground({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthPalette.pageBackground,
      body: Stack(
        children: [
          Positioned(
            left: -80,
            top: -120,
            child: _blob(
              const Size(240, 240),
              AuthPalette.primary.withValues(alpha: 0.13),
            ),
          ),
          Positioned(
            right: -70,
            top: 70,
            child: _blob(
              const Size(190, 190),
              AuthPalette.primary.withValues(alpha: 0.10),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(padding: padding, child: child),
          ),
        ],
      ),
    );
  }

  Widget _blob(Size size, Color color) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AuthPalette.primary.withValues(alpha: 0.20),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Image.asset('assets/images/pairuplogo.png'),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: AuthPalette.textSecondary,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class AuthCard extends StatelessWidget {
  const AuthCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AuthPalette.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AuthPalette.primary.withValues(alpha: 0.65),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

InputDecoration authInputDecoration({
  required String labelText,
  required String hintText,
  required IconData icon,
  Widget? suffixIcon,
}) {
  OutlineInputBorder border(Color color, [double width = 1.0]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    prefixIcon: Icon(icon, color: AuthPalette.textSecondary),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: const Color(0xFFF9F7FF),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: border(const Color(0xFFD8DCE8)),
    enabledBorder: border(const Color(0xFFD8DCE8)),
    focusedBorder: border(AuthPalette.primary, 1.6),
    errorBorder: border(Colors.red.shade300),
    focusedErrorBorder: border(Colors.red.shade400, 1.4),
  );
}
