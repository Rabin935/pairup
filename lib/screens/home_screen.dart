import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// --- Profile Data Model ---
class Profile {
  final String name;
  final int age;
  final String occupation;
  final String location;
  final String imageUrl;

  Profile({
    required this.name,
    required this.age,
    required this.occupation,
    required this.location,
    required this.imageUrl,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PairUp App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepPurple,
        ).copyWith(secondary: Colors.deepPurpleAccent),
        useMaterial3: true,
      ),
      // The application starts directly with the HomeScreen
      home: const HomeScreen(),
    );
  }
}

// --- 1. Main Navigation Screen (Stateful) ---

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // We keep the selected index state, but for now, we will lock it to 0
  // int _selectedIndex = 0;

  // // We only keep the DiscoverScreen in the list for now
  // static const List<Widget> _widgetOptions = <Widget>[
  //   DiscoverScreen(),
  //   // LikesScreen(), (Removed)
  //   // ChatScreen(), (Removed)
  //   // ProfileScreen(), (Removed)
  // ];

  // void _onItemTapped(int index) {
  //   // Navigation logic is intentionally disabled for now as requested.
  //   // When re-enabling, use:
  //   /*
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  //   */
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
