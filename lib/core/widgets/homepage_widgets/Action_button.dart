import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final VoidCallback? onPass;
  final VoidCallback? onLike;
  final VoidCallback? onDetails;

  const ActionButton({super.key, this.onPass, this.onLike, this.onDetails});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCircleButton(
          Icons.close,
          isDark ? const Color(0xFFFFB74D) : Colors.orange,
          60,
          bgColor: isDark ? const Color(0xFF262A33) : Colors.white,
          onTap: onPass,
        ),
        _buildCircleButton(
          Icons.favorite,
          Colors.white,
          80,
          bgColor: const Color(0xFF7F3DDB),
          onTap: onLike,
        ),
        _buildCircleButton(
          Icons.star,
          isDark ? const Color(0xFFD4B5FF) : Colors.purple,
          60,
          bgColor: isDark ? const Color(0xFF262A33) : Colors.white,
          onTap: onDetails,
        ),
      ],
    );
  }

  Widget _buildCircleButton(
    IconData icon,
    Color color,
    double size, {
    Color bgColor = Colors.white,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: size * 0.4),
      ),
    );
  }
}
