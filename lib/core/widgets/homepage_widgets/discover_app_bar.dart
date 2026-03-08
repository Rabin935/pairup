import 'package:flutter/material.dart';
import 'package:pairup/core/localization/app_localizations.dart';

class DiscoverAppBar extends StatelessWidget {
  final VoidCallback? onRefresh;

  const DiscoverAppBar({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.tr('discover'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          _buildSquareButton(
            onRefresh != null ? Icons.refresh : Icons.tune,
            iconColor: isDark ? Colors.white : Colors.black,
            borderColor: isDark
                ? const Color(0xFF353944)
                : Colors.grey.shade200,
            onTap: onRefresh,
          ),
        ],
      ),
    );
  }

  Widget _buildSquareButton(
    IconData icon, {
    required Color iconColor,
    required Color borderColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, color: iconColor),
      ),
    );
  }
}
