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
}
