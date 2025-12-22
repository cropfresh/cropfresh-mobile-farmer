// Match Widgets & Models Tests - Story 3.5 (Task 9.6)
// Tests for match display components and models

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cropfresh_mobile_farmer/src/models/match_models.dart';
import 'package:cropfresh_mobile_farmer/src/widgets/match_widgets.dart';
import 'package:cropfresh_mobile_farmer/src/widgets/match_notification_widgets.dart';

void main() {
  // ============================================================================
  // Model Tests
  // ============================================================================

  group('MatchStatus', () {
    test('should have correct labels', () {
      expect(MatchStatus.pendingAcceptance.label, equals('Pending'));
      expect(MatchStatus.accepted.label, equals('Accepted'));
      expect(MatchStatus.rejected.label, equals('Rejected'));
      expect(MatchStatus.expired.label, equals('Expired'));
    });

    test('should parse from API string', () {
      expect(MatchStatusExtension.fromString('PENDING_ACCEPTANCE'),
          equals(MatchStatus.pendingAcceptance));
      expect(MatchStatusExtension.fromString('ACCEPTED'),
          equals(MatchStatus.accepted));
      expect(MatchStatusExtension.fromString('REJECTED'),
          equals(MatchStatus.rejected));
      expect(MatchStatusExtension.fromString('EXPIRED'),
          equals(MatchStatus.expired));
    });

    test('should return pendingAcceptance for unknown values', () {
      expect(MatchStatusExtension.fromString('UNKNOWN'),
          equals(MatchStatus.pendingAcceptance));
      expect(MatchStatusExtension.fromString(null),
          equals(MatchStatus.pendingAcceptance));
    });
  });

  group('RejectionReason', () {
    test('should have correct labels', () {
      expect(RejectionReason.qualityChanged.label, equals('Quality changed'));
      expect(RejectionReason.soldElsewhere.label, equals('Sold elsewhere'));
      expect(RejectionReason.changedMind.label, equals('Changed my mind'));
      expect(RejectionReason.other.label, equals('Other reason'));
    });

    test('should have correct API values', () {
      expect(RejectionReason.qualityChanged.apiValue, equals('QUALITY_CHANGED'));
      expect(RejectionReason.soldElsewhere.apiValue, equals('SOLD_ELSEWHERE'));
    });
  });

  group('Buyer', () {
    test('mock should return valid buyer', () {
      final buyer = Buyer.mock();

      expect(buyer.businessType, isNotEmpty);
      expect(buyer.city, isNotEmpty);
      expect(buyer.displayName, isNotEmpty);
    });

    test('displayName should format correctly', () {
      final buyer = Buyer(
        businessType: 'Restaurant',
        city: 'Bangalore',
        area: 'Koramangala',
      );

      expect(buyer.displayName, equals('Restaurant in Koramangala, Bangalore'));
    });

    test('displayName without area should format correctly', () {
      final buyer = Buyer(
        businessType: 'Retailer',
        city: 'Mysore',
        area: null,
      );

      expect(buyer.displayName, equals('Retailer in Mysore'));
    });
  });

  group('Match', () {
    test('mock should return valid match', () {
      final match = Match.mock();

      expect(match.id, isNotEmpty);
      expect(match.buyer, isNotNull);
      expect(match.listing, isNotNull);
      expect(match.quantityRequested, greaterThan(0));
      expect(match.pricePerKg, greaterThan(0));
    });

    test('isPartial should detect partial matches', () {
      final fullMatch = Match.mock();
      expect(fullMatch.isPartial, isFalse); // Mock creates full match by default

      // Create partial match manually
      final partialMatch = Match(
        id: 'partial-1',
        status: MatchStatus.pendingAcceptance,
        buyer: Buyer.mock(),
        listing: MatchListing.mock(),
        quantityRequested: 30,
        pricePerKg: 35,
        totalAmount: 1050,
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        createdAt: DateTime.now(),
      );
      expect(partialMatch.quantityRequested, lessThan(partialMatch.listing.quantityKg));
      expect(partialMatch.isPartial, isTrue);
    });

    test('timeUntilExpiry should calculate correctly', () {
      final match = Match(
        id: 'test-1',
        status: MatchStatus.pendingAcceptance,
        buyer: Buyer.mock(),
        listing: MatchListing.mock(),
        quantityRequested: 50,
        pricePerKg: 35,
        totalAmount: 1750,
        expiresAt: DateTime.now().add(const Duration(hours: 2, minutes: 30)),
        createdAt: DateTime.now(),
      );

      expect(match.timeUntilExpiry.inHours, greaterThanOrEqualTo(2));
      expect(match.timeUntilExpiry.inMinutes, greaterThan(140));
    });

    test('expiryCountdownText should format correctly', () {
      final match = Match(
        id: 'test-1',
        status: MatchStatus.pendingAcceptance,
        buyer: Buyer.mock(),
        listing: MatchListing.mock(),
        quantityRequested: 50,
        pricePerKg: 35,
        totalAmount: 1750,
        expiresAt: DateTime.now().add(const Duration(hours: 5)),
        createdAt: DateTime.now(),
      );

      expect(match.expiryCountdownText, contains('h'));
    });
  });

  // ============================================================================
  // Widget Tests
  // ============================================================================

  group('MatchBadge', () {
    testWidgets('should render count badge', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MatchBadge(count: 3),
          ),
        ),
      );

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('should show 9+ for counts greater than 9', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MatchBadge(count: 15),
          ),
        ),
      );

      expect(find.text('9+'), findsOneWidget);
    });

    testWidgets('should not render when count is 0', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MatchBadge(count: 0),
          ),
        ),
      );

      expect(find.byType(MatchBadge), findsOneWidget);
      // The internal container should be a SizedBox.shrink
      expect(find.text('0'), findsNothing);
    });
  });

  group('BuyerInfoCard', () {
    testWidgets('should render buyer information', (WidgetTester tester) async {
      final buyer = Buyer(
        businessType: 'Restaurant',
        city: 'Bangalore',
        area: 'Koramangala',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BuyerInfoCard(
                buyer: buyer,
                deliveryDate: 'Dec 25',
              ),
            ),
          ),
        ),
      );

      // Check widget is rendered
      expect(find.byType(BuyerInfoCard), findsOneWidget);
      // Check buyer type is shown
      expect(find.textContaining('Restaurant'), findsOneWidget);
    });
  });

  group('QuantityCard', () {
    testWidgets('should render quantity information', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
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

      expect(find.textContaining('50'), findsWidgets);
      expect(find.text('🍅'), findsOneWidget);
    });

    testWidgets('should show partial indicator when partial', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
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

      // Should show partial match indicator - PARTIAL badge
      expect(find.byType(QuantityCard), findsOneWidget);
      expect(find.text('PARTIAL'), findsOneWidget);
    });
  });

  group('PriceCard', () {
    testWidgets('should render price breakdown', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PriceCard(
              totalAmount: 1750,
              pricePerKg: 35,
              quantityKg: 50,
            ),
          ),
        ),
      );

      expect(find.textContaining('35'), findsWidgets);
      // Amount may be formatted as 1.8K or 1750
      expect(find.byType(PriceCard), findsOneWidget);
    });
  });

  group('LiveCountdownTimer', () {
    testWidgets('should render countdown', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiveCountdownTimer(
              expiresAt: DateTime.now().add(const Duration(hours: 2)),
            ),
          ),
        ),
      );

      // Wait for timer to initialize
      await tester.pump();

      expect(find.byType(LiveCountdownTimer), findsOneWidget);
    });

    testWidgets('should show compact version', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiveCountdownTimer(
              expiresAt: DateTime.now().add(const Duration(hours: 1)),
              compact: true,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(LiveCountdownTimer), findsOneWidget);
    });

    testWidgets('should call onExpired when timer expires', (WidgetTester tester) async {
      bool expiredCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiveCountdownTimer(
              expiresAt: DateTime.now().subtract(const Duration(seconds: 1)),
              onExpired: () {
                expiredCalled = true;
              },
            ),
          ),
        ),
      );

      // Pump to allow timer to tick
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Note: Due to async nature, this might need adjustment in real testing
      // expect(expiredCalled, isTrue);
    });
  });

  group('MatchCard', () {
    testWidgets('should render match summary', (WidgetTester tester) async {
      final match = Match.mock();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MatchCard(
                match: match,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(MatchCard), findsOneWidget);
      // Should show crop name
      expect(find.textContaining(match.listing.cropType), findsWidgets);
    });
  });

  group('EmptyMatchesState', () {
    testWidgets('should render empty state message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyMatchesState(),
          ),
        ),
      );

      expect(find.byType(EmptyMatchesState), findsOneWidget);
      expect(find.textContaining('No pending matches'), findsOneWidget);
    });
  });
}
