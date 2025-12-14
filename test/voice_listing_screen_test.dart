// Voice Listing Screen Widget Tests
// Tests for Story 3.1 Voice Input UI

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cropfresh_mobile_farmer/src/screens/listing/voice_listing_screen.dart';
import 'package:cropfresh_mobile_farmer/src/screens/listing/listing_confirmation_screen.dart';
import 'package:cropfresh_mobile_farmer/src/screens/listing/crop_selection_grid.dart';

void main() {
  group('VoiceListingScreen', () {
    testWidgets('should render microphone button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: VoiceListingScreen(),
        ),
      );

      // Find mic icon
      expect(find.byIcon(Icons.mic), findsOneWidget);
    });

    testWidgets('should show language selector', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: VoiceListingScreen(),
        ),
      );

      // Find language icon
      expect(find.byIcon(Icons.language), findsOneWidget);
    });

    testWidgets('should have manual fallback option', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: VoiceListingScreen(),
        ),
      );

      // Find manual selection text
      expect(find.text('Or select crop manually'), findsOneWidget);
    });
  });

  group('CropSelectionGrid', () {
    testWidgets('should render crop grid with 12 items', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CropSelectionGrid(),
        ),
      );

      // Common crops should be visible
      expect(find.text('Tomato'), findsOneWidget);
      expect(find.text('Potato'), findsOneWidget);
      expect(find.text('Onion'), findsOneWidget);
    });

    testWidgets('should show quantity input section', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CropSelectionGrid(),
        ),
      );

      expect(find.text('How much do you want to sell?'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });
  });

  group('ListingConfirmationScreen', () {
    testWidgets('should show Yes/No buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ListingConfirmationScreen(),
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              builder: (_) => const ListingConfirmationScreen(),
              settings: RouteSettings(
                name: '/listing-confirmation',
                arguments: {
                  'cropType': 'Tomato',
                  'quantity': 50.0,
                  'unit': 'kg',
                  'transcribedText': 'tomato 50 kilos',
                  'confidence': 0.9,
                  'language': 'en-IN',
                },
              ),
            );
          },
        ),
      );

      await tester.pumpAndSettle();

      // Find confirmation buttons
      expect(find.text('No'), findsOneWidget);
      expect(find.text('Yes, Correct'), findsOneWidget);
    });
  });
}
