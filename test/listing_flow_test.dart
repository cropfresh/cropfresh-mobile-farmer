// Enhanced Listing Flow Widget Tests
// Tests for Center FAB, Manual Listing, and Review screens

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cropfresh_mobile_farmer/src/screens/dashboard/dashboard_shell.dart';
import 'package:cropfresh_mobile_farmer/src/screens/listing/manual_listing_screen.dart';
import 'package:cropfresh_mobile_farmer/src/screens/listing/listing_review_screen.dart';

void main() {
  group('DashboardShell Center FAB', () {
    testWidgets('should render center FAB with mic icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardShell(),
        ),
      );

      // FAB should exist
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.mic), findsOneWidget);
    });

    testWidgets('should render 4 navigation items', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardShell(),
        ),
      );

      // Check all nav items
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Listings'), findsOneWidget);
      expect(find.text('Markets'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('FAB tap should open modal bottom sheet', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardShell(),
        ),
      );

      // Tap FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Check mode selector options
      expect(find.text('List Your Crop'), findsOneWidget);
      expect(find.text('Speak to List'), findsOneWidget);
      expect(find.text('Type to List'), findsOneWidget);
    });
  });

  group('ManualListingScreen', () {
    testWidgets('should show crop selection on first step', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ManualListingScreen(),
        ),
      );

      expect(find.text('What are you selling?'), findsOneWidget);
      expect(find.text('Tomato'), findsOneWidget);
      expect(find.text('Potato'), findsOneWidget);
    });

    testWidgets('should have continue button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ManualListingScreen(),
        ),
      );

      expect(find.text('Continue'), findsOneWidget);
    });
  });

  group('ListingReviewScreen', () {
    testWidgets('should show create listing button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ListingReviewScreen(),
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              builder: (_) => const ListingReviewScreen(),
              settings: RouteSettings(
                name: '/listing-review',
                arguments: {
                  'cropType': 'Tomato',
                  'cropEmoji': '🍅',
                  'quantity': 50.0,
                  'entryMode': 'manual',
                },
              ),
            );
          },
        ),
      );

      expect(find.text('Create Listing'), findsOneWidget);
      expect(find.text('Estimated Earnings'), findsOneWidget);
    });
  });
}
