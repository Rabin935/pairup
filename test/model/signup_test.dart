import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pairup/features/auth/domain/entities/auth_entity.dart';
import 'package:pairup/features/auth/presentation/pages/signup_screen.dart';

void main() {
  test('AuthEntity creates correctly', () {
    final user = AuthEntity(
      firstname: "Rabin",
      lastname: "Rabin",
      email: "rabin@test.com",
      password: "123456",
    );

    expect(user.firstname, "Rabin");
    expect(user.lastname, "Rabin");
    expect(user.email, "rabin@test.com");
    expect(user.password, "123456");
  });

  testWidgets('Email field accepts input', (tester) async {
    await tester.pumpWidget(MaterialApp(home: SignupScreen()));

    await tester.pumpAndSettle();

    // final emailFinder = find.byKey(const Key('email'));

    // expect(emailFinder, findsOneWidget);

    // await tester.enterText(emailFinder, 'test@gmail.com');

    // await tester.pump();

    // expect(find.text('test@gmail.com'), findsOneWidget);

    final emailFinder = find.text('Create Account');

  await tester.ensureVisible(emailFinder);
  await tester.tap(emailFinder);

  await tester.pumpAndSettle();

  expect(emailFinder, findsOneWidget);
  expect(find.text('test@gmail.com'), findsOneWidget);
  });

  testWidgets('Shows validation error on empty signup', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: SignupScreen()),
  );

  await tester.pumpAndSettle();

  final buttonFinder = find.text('Create Account');

  await tester.ensureVisible(buttonFinder);
  await tester.tap(buttonFinder);

  await tester.pumpAndSettle();

  expect(find.textContaining('Email'), findsOneWidget);
  expect(find.textContaining('Password'), findsOneWidget);
});


  testWidgets('Password is hidden initially', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: SignupScreen()),
  );

  await tester.pumpAndSettle();

  final textField = tester.widget<TextField>(
    find.descendant(
      of: find.byKey(const Key('password')),
      matching: find.byType(TextField),
    ),
  );

  expect(textField.obscureText, true);
});



  testWidgets('Signup button present', (tester) async {
    await tester.pumpWidget(MaterialApp(home: SignupScreen()));

    final button = find.byType(ElevatedButton);

    expect(button, findsOneWidget);
  });
}
