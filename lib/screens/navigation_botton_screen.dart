import 'package:flutter/material.dart';
import 'package:pairup/screens/bottom_screens/chat_screen.dart';
import 'package:pairup/screens/bottom_screens/home_screen.dart';
import 'package:pairup/screens/bottom_screens/like_screen.dart';
import 'package:pairup/screens/bottom_screens/profile_screen.dart';

class NavigationBottonScreen extends StatefulWidget {
  const NavigationBottonScreen({super.key});

  @override
  State<NavigationBottonScreen> createState() => _NavigationBottonScreenState();
}

class _NavigationBottonScreenState extends State<NavigationBottonScreen> {
  int _selectedIndex = 0;

  List<Widget> BtmScreen = [
    const HomeScreen(),
    const LikeScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BtmScreen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Like',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Profile',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined),
            label: 'Profile',
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 252, 255, 255),
        selectedItemColor: const Color.fromARGB(255, 15, 14, 17),
        currentIndex: _selectedIndex,
        onTap: (Index) {
          setState(() {
            _selectedIndex = Index;
          });
        },
      ),
    );
  }
}
