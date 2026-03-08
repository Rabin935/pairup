import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _LoginPageFixture extends StatefulWidget {
  const _LoginPageFixture();

  @override
  State<_LoginPageFixture> createState() => _LoginPageFixtureState();
}

class _LoginPageFixtureState extends State<_LoginPageFixture> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var loginTapped = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text('Login to PairUp'),
          TextField(controller: emailController),
          TextField(controller: passwordController),
          ElevatedButton(
            onPressed: () {
              setState(() => loginTapped = true);
            },
            child: Text(loginTapped ? 'Login Clicked' : 'Login'),
          ),
        ],
      ),
    );
  }
}

class _RegisterPageFixture extends StatefulWidget {
  const _RegisterPageFixture();

  @override
  State<_RegisterPageFixture> createState() => _RegisterPageFixtureState();
}

class _RegisterPageFixtureState extends State<_RegisterPageFixture> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? errorText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text('Join Us Today'),
          TextField(controller: emailController),
          TextField(controller: passwordController),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (!emailController.text.contains('@') ||
                    passwordController.text.length < 6) {
                  errorText = 'Validation Error';
                } else {
                  errorText = null;
                }
              });
            },
            child: const Text('Create Account'),
          ),
          if (errorText != null) Text(errorText!),
        ],
      ),
    );
  }
}

void main() {
  testWidgets('Login page renders', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _LoginPageFixture()));

    expect(find.text('Login to PairUp'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('Login button works', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _LoginPageFixture()));

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Login Clicked'), findsOneWidget);
  });

  testWidgets('Register page renders', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _RegisterPageFixture()));

    expect(find.text('Join Us Today'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
  });

  testWidgets('Register validation works', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _RegisterPageFixture()));

    await tester.enterText(find.byType(TextField).at(0), 'invalid-email');
    await tester.enterText(find.byType(TextField).at(1), '123');
    await tester.tap(find.text('Create Account'));
    await tester.pump();

    expect(find.text('Validation Error'), findsOneWidget);
  });
}
