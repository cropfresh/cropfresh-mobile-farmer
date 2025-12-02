import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cropfresh_mobile_farmer/src/screens/auth/otp_verification_screen.dart';

void main() {
  testWidgets('OTP Verification Screen UI Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(
      home: OtpVerificationScreen(phoneNumber: '9876543210'),
    ));

    // Verify "Verify Mobile" text is present.
    expect(find.text('Verify Mobile'), findsOneWidget);

    // Verify phone number is displayed
    expect(find.text('Enter OTP sent to +91 9876543210'), findsOneWidget);

    // Verify "Verify & Continue" button is present.
    expect(find.text('Verify & Continue'), findsOneWidget);
    
    // Verify Timer text is present (starts at 10:00)
    expect(find.text('10:00'), findsOneWidget);
  });
}
