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
  final GlobalKey<DiscoverCardState> _discoverKey = GlobalKey<DiscoverCardState>();

  Future<void> _refreshDeck() async {
    await _discoverKey.currentState?.refreshDeck();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              DiscoverAppBar(onRefresh: _refreshDeck),
              Expanded(
                child: DiscoverCard(key: _discoverKey),
              ),
              ActionButton(
                onPass: () {
                  _discoverKey.currentState?.triggerPass();
                },
                onLike: () {
                  _discoverKey.currentState?.triggerLike();
                },
                onDetails: () {
                  _discoverKey.currentState?.triggerDetails();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
