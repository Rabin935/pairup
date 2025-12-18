import 'package:flutter/material.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color.fromARGB(255, 139, 139, 139),
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: onTap,
        leading: Icon(icon, color: const Color.fromARGB(255, 39, 39, 39)),
        title: Text(
          title,
          style: const TextStyle(
            color: Color.fromARGB(255, 46, 46, 46),
            fontSize: 16,
          ),
        ),
        trailing: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: [
            if (trailing != null)
              Text(
                trailing!,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            const Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
