// CropFresh Mobile Farmer App - Widget Tests
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cropfresh_mobile_farmer/main.dart';

void main() {
  testWidgets('App should display splash screen on launch', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CropFreshFarmerApp());

    // Verify that splash screen content is displayed
    expect(find.text('CropFresh'), findsWidgets);
  });

  testWidgets('App should have Material 3 styling', (WidgetTester tester) async {
    await tester.pumpWidget(const CropFreshFarmerApp());

    // Find the MaterialApp widget
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    
    // Verify Material 3 is enabled
    expect(materialApp.theme?.useMaterial3, isTrue);
  });
}
