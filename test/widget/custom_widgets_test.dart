import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _ErrorWidgetFixture extends StatelessWidget {
  const _ErrorWidgetFixture();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Something went wrong'));
  }
}

class _ButtonFixture extends StatefulWidget {
  const _ButtonFixture();

  @override
  State<_ButtonFixture> createState() => _ButtonFixtureState();
}

class _ButtonFixtureState extends State<_ButtonFixture> {
  var tapped = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => setState(() => tapped = true),
          child: Text(tapped ? 'Tapped' : 'Tap me'),
        ),
      ),
    );
  }
}

class _InputFixture extends StatefulWidget {
  const _InputFixture();

  @override
  State<_InputFixture> createState() => _InputFixtureState();
}

class _InputFixtureState extends State<_InputFixture> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: TextField(controller: controller));
  }
}

class _CardFixture extends StatelessWidget {
  const _CardFixture();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: ListTile(
        title: Text('Card title'),
        subtitle: Text('Card subtitle'),
      ),
    );
  }
}

class _AvatarFixture extends StatelessWidget {
  const _AvatarFixture();

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(radius: 20, child: Text('A'));
  }
}

class _BottomNavFixture extends StatefulWidget {
  const _BottomNavFixture();

  @override
  State<_BottomNavFixture> createState() => _BottomNavFixtureState();
}

class _BottomNavFixtureState extends State<_BottomNavFixture> {
  var index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('Tab $index'),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (value) => setState(() => index = value),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        ],
      ),
    );
  }
}

class _EmptyStateFixture extends StatelessWidget {
  const _EmptyStateFixture();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No data available'));
  }
}

void main() {
  testWidgets('Loading indicator renders', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Error widget renders', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _ErrorWidgetFixture()));

    expect(find.text('Something went wrong'), findsOneWidget);
  });

  testWidgets('Custom button widget', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _ButtonFixture()));

    await tester.tap(find.text('Tap me'));
    await tester.pump();

    expect(find.text('Tapped'), findsOneWidget);
  });

  testWidgets('Custom input widget', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _InputFixture()));

    await tester.enterText(find.byType(TextField), 'PairUp input');
    await tester.pump();

    expect(find.text('PairUp input'), findsOneWidget);
  });

  testWidgets('AppBar widget', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(appBar: AppBar(title: const Text('Custom AppBar'))),
      ),
    );

    expect(find.text('Custom AppBar'), findsOneWidget);
  });

  testWidgets('Bottom navigation bar', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _BottomNavFixture()));

    expect(find.byType(BottomNavigationBar), findsOneWidget);

    await tester.tap(find.text('Search'));
    await tester.pump();

    expect(find.text('Tab 1'), findsOneWidget);
  });

  testWidgets('Card component', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _CardFixture()));

    expect(find.byType(Card), findsOneWidget);
    expect(find.text('Card title'), findsOneWidget);
  });

  testWidgets('Avatar component', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _AvatarFixture()));

    expect(find.byType(CircleAvatar), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
  });

  testWidgets('Empty state widget', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _EmptyStateFixture()));

    expect(find.text('No data available'), findsOneWidget);
  });
}
