// Dashboard Shell Widget Tests
// Tests for MD3 NavigationBar functionality

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cropfresh_mobile_farmer/src/screens/dashboard/dashboard_shell.dart';
import 'package:cropfresh_mobile_farmer/src/screens/dashboard/dashboard_home_screen.dart';
import 'package:cropfresh_mobile_farmer/src/screens/dashboard/listings_screen.dart';
import 'package:cropfresh_mobile_farmer/src/screens/dashboard/markets_screen.dart';
import 'package:cropfresh_mobile_farmer/src/screens/dashboard/profile_screen.dart';

void main() {
  testWidgets('DashboardShell should render NavigationBar with 4 destinations',
      (WidgetTester tester) async {
    // Build the DashboardShell widget
    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardShell(),
      ),
    );

    // Verify NavigationBar exists
    expect(find.byType(NavigationBar), findsOneWidget);

    // Verify all 4 navigation destinations are present
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Listings'), findsOneWidget);
    expect(find.text('Markets'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('DashboardShell should show Home tab by default',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardShell(),
      ),
    );

    // Home screen content should be visible
    // The greeting or quick actions should be visible
    expect(find.text('Quick Actions'), findsOneWidget);
  });

  testWidgets('Tapping Listings tab should switch to ListingsScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardShell(),
      ),
    );

    // Tap on the Listings navigation destination
    await tester.tap(find.text('Listings'));
    await tester.pumpAndSettle();

    // Verify ListingsScreen content is visible
    expect(find.text('My Listings'), findsOneWidget);
    expect(find.text('No Listings Yet'), findsOneWidget);
  });

  testWidgets('Tapping Markets tab should switch to MarketsScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardShell(),
      ),
    );

    // Tap on the Markets navigation destination
    await tester.tap(find.text('Markets'));
    await tester.pumpAndSettle();

    // Verify MarketsScreen content is visible
    expect(find.text('Market Prices'), findsOneWidget);
    expect(find.text('Today\'s Rates (Sample)'), findsOneWidget);
  });

  testWidgets('Tapping Profile tab should switch to ProfileScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardShell(),
      ),
    );

    // Tap on the Profile navigation destination
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    // Verify ProfileScreen content is visible
    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Verified Farmer'), findsOneWidget);
  });

  testWidgets('NavigationBar should preserve screen state with IndexedStack',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardShell(),
      ),
    );

    // Go to Markets tab
    await tester.tap(find.text('Markets'));
    await tester.pumpAndSettle();

    // Go to Profile tab
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    // Go back to Home tab
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    // Verify Home screen is still showing (IndexedStack preserves state)
    expect(find.text('Quick Actions'), findsOneWidget);
  });
}
