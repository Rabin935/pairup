import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

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

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
