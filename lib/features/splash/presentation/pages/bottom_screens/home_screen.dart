import 'package:flutter/material.dart';
import 'package:pairup/core/widgets/homepage_widgets/Action_button.dart';
import 'package:pairup/core/widgets/homepage_widgets/discoverCard.dart';
import 'package:pairup/core/widgets/homepage_widgets/discover_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: const [
              DiscoverAppBar(),
              Expanded(
                child: DiscoverCard(), // This expands to fill available space
              ),
              ActionButton(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
