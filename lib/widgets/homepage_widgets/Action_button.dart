import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCircleButton(Icons.close, Colors.orange, 60),
        _buildCircleButton(
          Icons.favorite,
          Colors.white,
          80,
          bgColor: const Color(0xFF7F3DDB),
        ),
        _buildCircleButton(Icons.star, Colors.purple, 60),
      ],
    );
  }

  Widget _buildCircleButton(
    IconData icon,
    Color color,
    double size, {
    Color bgColor = Colors.white,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: size * 0.4),
    );
  }
}
