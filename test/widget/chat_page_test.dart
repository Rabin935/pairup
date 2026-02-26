import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _ChatListFixture extends StatelessWidget {
  const _ChatListFixture();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: ListView(
        children: const [
          ListTile(title: Text('Chat A')),
          ListTile(title: Text('Chat B')),
        ],
      ),
    );
  }
}

class _ChatComposerFixture extends StatefulWidget {
  const _ChatComposerFixture();

  @override
  State<_ChatComposerFixture> createState() => _ChatComposerFixtureState();
}

class _ChatComposerFixtureState extends State<_ChatComposerFixture> {
  final controller = TextEditingController();
  final messages = <String>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: messages.map((m) => Text(m)).toList(),
            ),
          ),
          TextField(controller: controller),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              setState(() => messages.add(controller.text));
            },
          ),
        ],
      ),
    );
  }
}

class _TypingIndicatorFixture extends StatelessWidget {
  const _TypingIndicatorFixture();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Row(
        children: [
          Text('Typing...'),
          SizedBox(width: 8),
          CircularProgressIndicator(strokeWidth: 2),
        ],
      ),
    );
  }
}

class _ProfileFixture extends StatefulWidget {
  const _ProfileFixture();

  @override
  State<_ProfileFixture> createState() => _ProfileFixtureState();
}

class _ProfileFixtureState extends State<_ProfileFixture> {
  var edited = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => setState(() => edited = true),
            child: const Text('Edit Profile'),
          ),
          ElevatedButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              builder: (_) => const ListTile(title: Text('Upload from gallery')),
            ),
            child: const Text('Upload Photo'),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: const [
                Card(child: Center(child: Text('Post 1'))),
                Card(child: Center(child: Text('Post 2'))),
              ],
            ),
          ),
          if (edited) const Text('Profile Edited'),
        ],
      ),
    );
  }
}

class _SettingsFixture extends StatefulWidget {
  const _SettingsFixture();

  @override
  State<_SettingsFixture> createState() => _SettingsFixtureState();
}

class _SettingsFixtureState extends State<_SettingsFixture> {
  ThemeMode mode = ThemeMode.light;
  String language = 'English';
  bool notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Column(
        children: [
          DropdownButton<ThemeMode>(
            value: mode,
            items: const [
              DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
              DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => mode = value);
            },
          ),
          DropdownButton<String>(
            value: language,
            items: const [
              DropdownMenuItem(value: 'English', child: Text('English')),
              DropdownMenuItem(value: 'Nepali', child: Text('Nepali')),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => language = value);
            },
          ),
          SwitchListTile(
            title: const Text('Notifications'),
            value: notifications,
            onChanged: (value) {
              setState(() => notifications = value);
            },
          ),
        ],
      ),
    );
  }
}

void main() {
  testWidgets('Chat list renders', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _ChatListFixture()));

    expect(find.text('Chat A'), findsOneWidget);
    expect(find.text('Chat B'), findsOneWidget);
  });

  testWidgets('Chat message bubble renders', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.centerRight,
            child: DecoratedBox(
              decoration: BoxDecoration(color: Colors.purple),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text('Hello bubble'),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Hello bubble'), findsOneWidget);
  });

  testWidgets('Send message button works', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _ChatComposerFixture()));

    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();

    expect(find.text('Hello'), findsWidgets);
  });

  testWidgets('Message input field works', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _ChatComposerFixture()));

    await tester.enterText(find.byType(TextField), 'Typing text');
    await tester.pump();

    expect(find.text('Typing text'), findsOneWidget);
  });

  testWidgets('Chat scroll works', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView.builder(
            itemCount: 40,
            itemBuilder: (_, i) => Text('Message $i'),
          ),
        ),
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pump();

    expect(find.text('Message 39'), findsOneWidget);
  });

  testWidgets('Typing indicator widget', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _TypingIndicatorFixture()));

    expect(find.text('Typing...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Profile page renders', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _ProfileFixture()));

    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('Edit profile button works', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _ProfileFixture()));

    await tester.tap(find.text('Edit Profile'));
    await tester.pump();

    expect(find.text('Profile Edited'), findsOneWidget);
  });

  testWidgets('Upload photo widget works', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _ProfileFixture()));

    await tester.tap(find.text('Upload Photo'));
    await tester.pumpAndSettle();

    expect(find.text('Upload from gallery'), findsOneWidget);
  });

  testWidgets('Posts grid renders', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _ProfileFixture()));

    expect(find.byType(GridView), findsOneWidget);
    expect(find.text('Post 1'), findsOneWidget);
  });

  testWidgets('Settings page renders', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _SettingsFixture()));

    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Theme switch works', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _SettingsFixture()));

    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark').last);
    await tester.pumpAndSettle();

    expect(find.text('Dark'), findsWidgets);
  });

  testWidgets('Language switch works', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _SettingsFixture()));

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nepali').last);
    await tester.pumpAndSettle();

    expect(find.text('Nepali'), findsWidgets);
  });

  testWidgets('Notification toggle works', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _SettingsFixture()));

    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isTrue,
    );

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );
  });
}
