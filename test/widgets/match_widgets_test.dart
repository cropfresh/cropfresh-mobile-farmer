// Match Widget Tests - Story 3.5 (Task 9.6)
// 
// Tests Flutter widgets for match screens.
// Covers key UI components and interactions.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cropfresh_mobile_farmer/src/models/match_models.dart';
import 'package:cropfresh_mobile_farmer/src/widgets/match_widgets.dart';

void main() {
  // ============================================================================
  // Test Data
  // ============================================================================

  final mockBuyer = Buyer.mock();
  final mockListing = MatchListing.mock();
  final mockMatch = Match.mock();
  final mockPartialMatch = Match.mock(isPartial: true);

  // ============================================================================
  // MatchBadge Tests
  // ============================================================================

  group('MatchBadge', () {
    testWidgets('displays count', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MatchBadge(count: 5),
          ),
        ),
      );

      // Assert
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('shows 9+ for counts above 9', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MatchBadge(count: 15),
          ),
        ),
      );

      // Assert
      expect(find.text('9+'), findsOneWidget);
    });

    testWidgets('hides when count is 0', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MatchBadge(count: 0),
          ),
        ),
      );

      // Assert
      expect(find.byType(MatchBadge), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });
  });

  // ============================================================================
  // BuyerInfoCard Tests
  // ============================================================================

  group('BuyerInfoCard', () {
    testWidgets('displays buyer business type and city', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BuyerInfoCard(buyer: mockBuyer),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('Restaurant'), findsOneWidget);
      expect(find.textContaining('Bangalore'), findsOneWidget);
    });

    testWidgets('displays delivery date when provided', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BuyerInfoCard(
              buyer: mockBuyer,
              deliveryDate: 'Tomorrow afternoon',
            ),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('Tomorrow afternoon'), findsOneWidget);
    });

    testWidgets('responds to tap', (tester) async {
      // Arrange
      bool wasTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BuyerInfoCard(
              buyer: mockBuyer,
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(BuyerInfoCard));
      await tester.pump();

      // Assert
      expect(wasTapped, isTrue);
    });
  });

  // ============================================================================
  // QuantityCard Tests
  // ============================================================================

  group('QuantityCard', () {
    testWidgets('displays quantity with crop info', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuantityCard(
              quantityRequested: 50,
              listingQuantity: 50,
              cropEmoji: '🍅',
              cropName: 'Tomatoes',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('50 kg'), findsOneWidget);
      expect(find.text('🍅'), findsOneWidget);
      expect(find.text('Tomatoes'), findsOneWidget);
    });

    testWidgets('shows partial match indicator', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuantityCard(
              quantityRequested: 30,
              listingQuantity: 50,
              cropEmoji: '🍅',
              cropName: 'Tomatoes',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('PARTIAL'), findsOneWidget);
      expect(find.textContaining('of your 50 kg'), findsOneWidget);
      expect(find.textContaining('20 kg will remain'), findsOneWidget);
    });

    testWidgets('hides partial indicator for full matches', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuantityCard(
              quantityRequested: 50,
              listingQuantity: 50,
              cropEmoji: '🍅',
              cropName: 'Tomatoes',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('PARTIAL'), findsNothing);
    });
  });

  // ============================================================================
  // PriceCard Tests
  // ============================================================================

  group('PriceCard', () {
    testWidgets('displays formatted price and total', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PriceCard(
              totalAmount: 1800,
              pricePerKg: 36,
              quantityKg: 50,
            ),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('1.8K'), findsOneWidget);
      expect(find.textContaining('36/kg'), findsOneWidget);
      expect(find.textContaining('50 kg'), findsOneWidget);
    });

    testWidgets('formats large amounts correctly', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PriceCard(
              totalAmount: 150000,
              pricePerKg: 50,
              quantityKg: 3000,
            ),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('1.5L'), findsOneWidget);
    });
  });

  // ============================================================================
  // MatchExpiryTimer Tests
  // ============================================================================

  group('MatchExpiryTimer', () {
    testWidgets('displays countdown text', (tester) async {
      // Arrange
      final expiresAt = DateTime.now().add(const Duration(hours: 2, minutes: 45));
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchExpiryTimer(expiresAt: expiresAt),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('Expires in'), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('shows expired state', (tester) async {
      // Arrange
      final expiresAt = DateTime.now().subtract(const Duration(hours: 1));
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MatchExpiryTimer(expiresAt: expiresAt),
          ),
        ),
      );

      // Assert
      expect(find.text('Expired'), findsOneWidget);
      expect(find.byIcon(Icons.timer_off), findsOneWidget);
    });
  });

  // ============================================================================
  // MatchCard Tests
  // ============================================================================

  group('MatchCard', () {
    testWidgets('displays crop info, buyer type, price, expiry', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MatchCard(match: mockMatch),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('🍅'), findsOneWidget);
      expect(find.textContaining('Tomatoes'), findsOneWidget);
      expect(find.textContaining('Restaurant'), findsOneWidget);
    });

    testWidgets('responds to tap with callback', (tester) async {
      // Arrange
      bool wasTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MatchCard(
                match: mockMatch,
                onTap: () => wasTapped = true,
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(MatchCard));
      await tester.pump();

      // Assert
      expect(wasTapped, isTrue);
    });

    testWidgets('shows partial match indicator', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MatchCard(match: mockPartialMatch),
            ),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('Partial'), findsOneWidget);
    });
  });

  // ============================================================================
  // EmptyMatchesState Tests
  // ============================================================================

  group('EmptyMatchesState', () {
    testWidgets('displays empty state message', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyMatchesState(),
          ),
        ),
      );

      // Assert
      expect(find.text('No pending matches'), findsOneWidget);
      expect(find.byIcon(Icons.handshake_outlined), findsOneWidget);
    });

    testWidgets('shows refresh button when callback provided', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyMatchesState(onRefresh: () {}),
          ),
        ),
      );

      // Assert
      expect(find.text('Refresh'), findsOneWidget);
    });
  });
}
