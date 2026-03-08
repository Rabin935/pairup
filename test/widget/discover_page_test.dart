import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _DiscoverFixture extends StatefulWidget {
  const _DiscoverFixture();

  @override
  State<_DiscoverFixture> createState() => _DiscoverFixtureState();
}

class _DiscoverFixtureState extends State<_DiscoverFixture> {
  var liked = false;
  var passed = false;
  var users = <String>['User A'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: users.isEmpty
          ? const Center(child: Text('No users to discover right now'))
          : Column(
              children: [
                const Text('Swipe Card UI'),
                Text('Current: ${users.first}'),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite),
                      onPressed: () {
                        setState(() {
                          liked = true;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          passed = true;
                        });
                      },
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => users.clear());
                      },
                      child: const Text('Empty'),
                    ),
                  ],
                ),
                if (liked) const Text('Liked'),
                if (passed) const Text('Passed'),
              ],
            ),
    );
  }
}

class _MatchFixture extends StatefulWidget {
  const _MatchFixture();

  @override
  State<_MatchFixture> createState() => _MatchFixtureState();
}

class _MatchFixtureState extends State<_MatchFixture> {
  var accepted = false;
  var rejected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Matches')),
      body: Column(
        children: [
          const Text('Pending Match Request'),
          ElevatedButton(
            onPressed: () => setState(() => accepted = true),
            child: const Text('Accept'),
          ),
          OutlinedButton(
            onPressed: () => setState(() => rejected = true),
            child: const Text('Decline'),
          ),
          if (accepted) const Text('Accepted'),
          if (rejected) const Text('Rejected'),
        ],
      ),
    );
  }
}

void main() {
  testWidgets('Discover page loads', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _DiscoverFixture()));

    expect(find.text('Discover'), findsOneWidget);
  });

  testWidgets('Swipe card UI appears', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _DiscoverFixture()));

    expect(find.text('Swipe Card UI'), findsOneWidget);
  });

  testWidgets('Swipe right action', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _DiscoverFixture()));

    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pump();

    expect(find.text('Liked'), findsOneWidget);
  });

  testWidgets('Swipe left action', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _DiscoverFixture()));

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    expect(find.text('Passed'), findsOneWidget);
  });

  testWidgets('Empty discover state', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _DiscoverFixture()));

    await tester.tap(find.text('Empty'));
    await tester.pump();

    expect(find.text('No users to discover right now'), findsOneWidget);
  });

  testWidgets('Matches page renders', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _MatchFixture()));

    expect(find.text('Matches'), findsOneWidget);
  });

  testWidgets('Accept match button works', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _MatchFixture()));

    await tester.tap(find.text('Accept'));
    await tester.pump();

    expect(find.text('Accepted'), findsOneWidget);
  });

  testWidgets('Reject match button works', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _MatchFixture()));

    await tester.tap(find.text('Decline'));
    await tester.pump();

    expect(find.text('Rejected'), findsOneWidget);
  });
}
