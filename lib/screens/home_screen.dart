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
  int _selectedIndex = 0;

  // We only keep the DiscoverScreen in the list for now
  static const List<Widget> _widgetOptions = <Widget>[
    DiscoverScreen(),
    // LikesScreen(), (Removed)
    // ChatScreen(), (Removed)
    // ProfileScreen(), (Removed)
  ];

  void _onItemTapped(int index) {
    // Navigation logic is intentionally disabled for now as requested.
    // When re-enabling, use:
    /*
    setState(() {
      _selectedIndex = index;
    });
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[0],

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Likes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        // Set the currently selected item to the first one (index 0)
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        // The tap handler is connected but does nothing internally (as requested)
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// --- 2. Discover Screen (The only visible screen) ---

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  // State: List of profiles and the current index
  final List<Profile> _profiles = [
    Profile(
      name: 'Rabin Tamang',
      age: 21,
      occupation: 'Professional model',
      location: 'Kathmandu',
      imageUrl:
          'https://res.cloudinary.com/dtndr0wru/image/upload/v1764936474/curly_bra96e.jpg',
    ),
  ];

  int _currentIndex = 0;

  // Method to handle swipe action and update state
  void _swipeCard(bool liked) {
    if (_profiles.isEmpty) return;

    // Cycle to the next profile
    setState(() {
      final nextIndex = (_currentIndex + 1) % _profiles.length;
      _currentIndex = nextIndex;

      // Optional: show a snackbar based on action
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            liked
                ? 'You liked ${_profiles[_currentIndex].name}!'
                : 'You passed on ${_profiles[_currentIndex].name}',
          ),
          duration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentProfile = _profiles.isNotEmpty
        ? _profiles[_currentIndex]
        : null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {},
        ),
        title: Column(
          children: [
            const Text(
              'Discover',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              currentProfile?.location ?? 'Location Unknown',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.tune_rounded), onPressed: () {}),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // The Profile Card (passes current profile data)
            Expanded(
              child: currentProfile != null
                  ? ProfileCard(profile: currentProfile)
                  : const Center(child: Text('No more profiles!')),
            ),
            const SizedBox(height: 40),
            // The Interaction Buttons (passes the state update callback)
            InteractionButtons(onSwipe: _swipeCard),
          ],
        ),
      ),
    );
  }
}

// --- Profile Card Widget (Stateless, receives dynamic data) ---
class ProfileCard extends StatelessWidget {
  final Profile profile;
  const ProfileCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Stack(
        children: <Widget>[
          // Background Image (Placeholder)
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(profile.imageUrl), // Dynamic image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Gradient Overlay to make text readable
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                stops: const [0.6, 1.0],
              ),
            ),
          ),
          // Distance Badge (Top Left)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.black),
                  SizedBox(width: 4),
                  Text(
                    '1 km',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Options Menu (Top Right)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Column(
                children: List.generate(
                  3,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Name and Details (Bottom - Dynamic Content)
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${profile.name}, ${profile.age}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.occupation,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Interaction Buttons Widget (Stateless, invokes state update via callback) ---
class InteractionButtons extends StatelessWidget {
  final Function(bool liked) onSwipe;
  const InteractionButtons({super.key, required this.onSwipe});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        // Reject/Pass Button (X)
        FloatingActionButton(
          heroTag: 'rejectBtn',
          onPressed: () => onSwipe(false), // Reject
          backgroundColor: Colors.white,
          shape: const CircleBorder(),
          elevation: 4,
          child: const Icon(Icons.close, color: Colors.orange, size: 36),
        ),
        // Like Button (Heart)
        FloatingActionButton(
          heroTag: 'likeBtn',
          onPressed: () => onSwipe(true), // Like
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: const CircleBorder(),
          elevation: 6,
          child: Transform.scale(
            scale: 1.5,
            child: const Icon(Icons.favorite, color: Colors.white, size: 32),
          ),
        ),
        // Super Like Button (Star)
        FloatingActionButton(
          heroTag: 'superLikeBtn',
          onPressed: () =>
              onSwipe(true), // Treat Super Like as a Like for simple demo
          backgroundColor: Colors.white,
          shape: const CircleBorder(),
          elevation: 4,
          child: const Icon(
            Icons.star,
            color: Colors.deepPurpleAccent,
            size: 36,
          ),
        ),
      ],
    );
  }
}
