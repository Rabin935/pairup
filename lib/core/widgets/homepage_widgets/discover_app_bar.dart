import 'package:flutter/material.dart';

class DiscoverAppBar extends StatelessWidget {
  final VoidCallback? onRefresh;

  const DiscoverAppBar({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSquareButton(Icons.chevron_left),
            Column(
              children: const [
                Text(
                  "Discover",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text("Kathmandu", style: TextStyle(color: Colors.grey)),
              ],
            ),
            _buildSquareButton(
              onRefresh != null ? Icons.refresh : Icons.tune,
              onTap: onRefresh,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSquareButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, color: Colors.black),
      ),
    );
  }
}
