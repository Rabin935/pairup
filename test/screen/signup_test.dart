import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pairup/features/auth/presentation/pages/signup_screen.dart';

void main() {
  // testWidgets('Should have title', (WidgetTester tester) async {
  testWidgets('Should have title', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignupScreen()));
    Finder title = find.text('Join Us Today');
    expect(title, findsOneWidget);
  });

  testWidgets('Testing first and last name', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignupScreen()));

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Ram');
    await tester.enterText(find.byType(TextField).last, 'Tamang');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
    await tester.pumpAndSettle();

    expect(find.text('Ram'), findsOneWidget);
    expect(find.text('Tamang'), findsOneWidget);
  });

  testWidgets('Testing email and number', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignupScreen()));

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'ram@gmail.com');
    await tester.enterText(find.byType(TextField).last, '1234567890');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
    await tester.pumpAndSettle();

    expect(find.text('ram@gmail.com'), findsOneWidget);
    expect(find.text('1234567890'), findsOneWidget);
  });

  testWidgets('Testing password', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignupScreen()));

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Tamang123');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
    await tester.pumpAndSettle();

    expect(find.text('Tamang123'), findsOneWidget);
  });

  testWidgets('Testing create button', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignupScreen()));
    Finder title = find.widgetWithText(ElevatedButton, 'Create Account');

    expect(title, findsOneWidget);
  });
}
