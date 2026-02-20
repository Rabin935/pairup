import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pairup/features/splash/presentation/pages/bottom_screens/chat_screen.dart';
import 'package:pairup/features/splash/presentation/pages/bottom_screens/home_screen.dart';
import 'package:pairup/features/splash/presentation/pages/bottom_screens/like_screen.dart';
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

  static const List<Widget> _btmScreen = [
    HomeScreen(),
    LikeScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    final index = widget.initialTabIndex;
    _selectedIndex = (index >= 0 && index < _btmScreen.length) ? index : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _btmScreen),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Like',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 252, 255, 255),
        selectedItemColor: const Color.fromARGB(255, 15, 14, 17),
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
