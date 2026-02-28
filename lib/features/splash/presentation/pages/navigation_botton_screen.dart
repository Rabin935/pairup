import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/core/localization/app_localizations.dart';
import 'package:pairup/features/splash/presentation/pages/bottom_screens/chat_screen.dart';
import 'package:pairup/features/splash/presentation/pages/bottom_screens/create_screen.dart';
import 'package:pairup/features/splash/presentation/pages/bottom_screens/home_screen.dart';
import 'package:pairup/features/splash/presentation/pages/bottom_screens/explore_screen.dart';
import 'package:pairup/features/splash/presentation/pages/bottom_screens/profile_screen.dart';

class NavigationBottonScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const NavigationBottonScreen({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<NavigationBottonScreen> createState() =>
      _NavigationBottonScreenState();
}

class _NavigationBottonScreenState
    extends ConsumerState<NavigationBottonScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    final index = widget.initialTabIndex;
    _selectedIndex = (index >= 0 && index < 5) ? index : 0;
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const ExploreScreen();
      case 2:
        return const CreateScreen();
      case 3:
        return const ChatScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }

  Widget _navItem({
    required int index,
    required IconData outlined,
    required IconData filled,
    required String label,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? filled : outlined,
                color: isSelected ? activeColor : inactiveColor,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = colorScheme.primary;
    final inactiveColor = isDark
        ? Colors.blueGrey.shade200
        : const Color(0xFF8C939D);
    final fabBackground = isDark
        ? colorScheme.primary
        : const Color(0xFF673AB7);
    final bottomBarColor = isDark ? const Color(0xFF171A20) : Colors.white;

    return Scaffold(
      body: _buildScreen(_selectedIndex),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 8),
        child: SizedBox(
          width: 62,
          height: 62,
          child: FloatingActionButton(
            heroTag: 'create-fab',
            backgroundColor: fabBackground,
            elevation: 7,
            shape: const CircleBorder(),
            onPressed: () => setState(() => _selectedIndex = 2),
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: bottomBarColor,
        elevation: 12,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              _navItem(
                index: 0,
                outlined: Icons.home_outlined,
                filled: Icons.home,
                label: l10n.tr('home'),
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              _navItem(
                index: 1,
                outlined: Icons.explore_outlined,
                filled: Icons.explore,
                label: l10n.tr('discover'),
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              const SizedBox(width: 56),
              _navItem(
                index: 3,
                outlined: Icons.chat_bubble_outline,
                filled: Icons.chat_bubble,
                label: l10n.tr('messages'),
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              _navItem(
                index: 4,
                outlined: Icons.person_2_outlined,
                filled: Icons.person,
                label: l10n.tr('profile'),
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
