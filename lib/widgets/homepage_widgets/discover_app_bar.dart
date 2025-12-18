import 'package:flutter/material.dart';

class DiscoverAppBar extends StatelessWidget {
  const DiscoverAppBar({super.key});

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
            _buildSquareButton(Icons.tune),
          ],
        ),
      ),
    );
  }

  Widget _buildSquareButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(15),
      ),

      child: Icon(icon, color: Colors.black),
    );
  }
}
