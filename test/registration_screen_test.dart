import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cropfresh_mobile_farmer/src/screens/auth/registration_screen.dart';

void main() {
  testWidgets('Registration Screen UI Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(
      home: RegistrationScreen(),
    ));

    // Verify that "Start Farming" text is present.
    expect(find.text('Start Farming'), findsOneWidget);

    // Verify that "Mobile Number" label is present.
    expect(find.text('Mobile Number'), findsOneWidget);

    // Verify that "Send OTP" button is present.
    expect(find.text('Send OTP'), findsOneWidget);

    // Verify Language Selector is present (checking for "English")
    expect(find.text('English'), findsOneWidget);
  });
}
