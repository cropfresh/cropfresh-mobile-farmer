// Drop Point Widget Tests - Story 3.4 (Task 9.5)
// 
// Tests Flutter widgets for drop point assignment screens.
// Covers key UI components and interactions.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cropfresh_mobile_farmer/src/models/droppoint_models.dart';
import 'package:cropfresh_mobile_farmer/src/widgets/droppoint_widgets.dart';
import 'package:cropfresh_mobile_farmer/src/constants/app_colors.dart';

void main() {
  // ============================================================================
  // Test Data
  // ============================================================================

  final mockDropPoint = DropPoint(
    id: 'dp-001',
    name: 'Kolar Main Point',
    address: 'Near KSRTC Bus Stand, Station Road, Kolar, Karnataka 563101',
    location: const GeoLocation(latitude: 13.1378, longitude: 78.1300),
    distanceKm: 3.2,
    isOpen: true,
  );

  final mockPickupWindow = PickupWindow(
    start: DateTime.now().add(const Duration(days: 1, hours: 7)),
    end: DateTime.now().add(const Duration(days: 1, hours: 9)),
  );

  // ============================================================================
  // DistanceBadge Tests
  // ============================================================================

  group('DistanceBadge', () {
    testWidgets('displays distance in km', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DistanceBadge(distanceKm: 3.2),
          ),
        ),
      );

      // Assert
      expect(find.text('3.2 km'), findsOneWidget);
      expect(find.byIcon(Icons.near_me), findsOneWidget);
    });

    testWidgets('rounds distance to 1 decimal place', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DistanceBadge(distanceKm: 5.678),
          ),
        ),
      );

      // Assert
      expect(find.text('5.7 km'), findsOneWidget);
    });
  });

  // ============================================================================
  // CrateIndicator Tests
  // ============================================================================

  group('CrateIndicator', () {
    testWidgets('displays crate count', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CrateIndicator(cratesNeeded: 2, quantityKg: 100),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('2 crates'), findsOneWidget);
      expect(find.textContaining('100kg'), findsOneWidget);
    });

    testWidgets('shows singular "crate" for 1', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CrateIndicator(cratesNeeded: 1, quantityKg: 50),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('1 crate'), findsOneWidget);
      expect(find.textContaining('1 crates'), findsNothing);
    });

    testWidgets('displays crate icons', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CrateIndicator(cratesNeeded: 3, quantityKg: 150),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.inventory_2_outlined), findsNWidgets(3));
    });
  });

  // ============================================================================
  // CountdownTimerWidget Tests
  // ============================================================================

  group('CountdownTimerWidget', () {
    testWidgets('displays countdown text', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountdownTimerWidget(pickupWindow: mockPickupWindow),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('until drop-off'), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });
  });

  // ============================================================================
  // DropPointCard Tests
  // ============================================================================

  group('DropPointCard', () {
    testWidgets('displays drop point name and address', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DropPointCard(
                dropPoint: mockDropPoint,
                pickupWindow: mockPickupWindow,
                cratesNeeded: 2,
                quantityKg: 100,
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Kolar Main Point'), findsOneWidget);
      expect(find.textContaining('KSRTC'), findsOneWidget);
    });

    testWidgets('displays distance badge', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DropPointCard(
                dropPoint: mockDropPoint,
                pickupWindow: mockPickupWindow,
                cratesNeeded: 1,
                quantityKg: 50,
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('3.2 km'), findsOneWidget);
    });

    testWidgets('shows Get Directions button when enabled', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DropPointCard(
                dropPoint: mockDropPoint,
                pickupWindow: mockPickupWindow,
                cratesNeeded: 1,
                quantityKg: 50,
                showDirections: true,
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Get Directions'), findsOneWidget);
      expect(find.byIcon(Icons.directions), findsOneWidget);
    });

    testWidgets('hides Get Directions button when disabled', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DropPointCard(
                dropPoint: mockDropPoint,
                pickupWindow: mockPickupWindow,
                cratesNeeded: 1,
                quantityKg: 50,
                showDirections: false,
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Get Directions'), findsNothing);
    });

    testWidgets('calls onGetDirections when button tapped', (tester) async {
      // Arrange
      bool wasCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DropPointCard(
                dropPoint: mockDropPoint,
                pickupWindow: mockPickupWindow,
                cratesNeeded: 1,
                quantityKg: 50,
                onGetDirections: () => wasCalled = true,
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Get Directions'));
      await tester.pump();

      // Assert
      expect(wasCalled, isTrue);
    });
  });

  // ============================================================================
  // DeliveryCard Tests
  // ============================================================================

  group('DeliveryCard', () {
    testWidgets('displays crop info and drop point', (tester) async {
      // Arrange
      final delivery = UpcomingDelivery(
        assignment: DropPointAssignment(
          assignmentId: 'a1',
          listingId: 1,
          dropPoint: mockDropPoint,
          pickupWindow: mockPickupWindow,
          cratesNeeded: 1,
        ),
        cropName: 'Tomatoes',
        cropEmoji: '🍅',
        quantityKg: 50,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeliveryCard(delivery: delivery),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('50kg Tomatoes'), findsOneWidget);
      expect(find.text('🍅'), findsOneWidget);
      expect(find.text('Kolar Main Point'), findsOneWidget);
    });

    testWidgets('displays pickup time', (tester) async {
      // Arrange
      final delivery = UpcomingDelivery(
        assignment: DropPointAssignment(
          assignmentId: 'a1',
          listingId: 1,
          dropPoint: mockDropPoint,
          pickupWindow: mockPickupWindow,
          cratesNeeded: 1,
        ),
        cropName: 'Tomatoes',
        cropEmoji: '🍅',
        quantityKg: 50,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeliveryCard(delivery: delivery),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('Tomorrow'), findsOneWidget);
    });

    testWidgets('responds to tap', (tester) async {
      // Arrange
      bool wasTapped = false;
      final delivery = UpcomingDelivery(
        assignment: DropPointAssignment(
          assignmentId: 'a1',
          listingId: 1,
          dropPoint: mockDropPoint,
          pickupWindow: mockPickupWindow,
          cratesNeeded: 1,
        ),
        cropName: 'Tomatoes',
        cropEmoji: '🍅',
        quantityKg: 50,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeliveryCard(
              delivery: delivery,
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DeliveryCard));
      await tester.pump();

      // Assert
      expect(wasTapped, isTrue);
    });
  });

  // ============================================================================
  // Model Tests
  // ============================================================================

  group('PickupWindow', () {
    test('formats date as "Tomorrow" for next day', () {
      // Arrange
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final window = PickupWindow(
        start: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 7),
        end: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9),
      );

      // Assert
      expect(window.formattedDate, equals('Tomorrow'));
    });

    test('formats window as "7-9 AM"', () {
      // Arrange
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final window = PickupWindow(
        start: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 7),
        end: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9),
      );

      // Assert
      expect(window.formattedWindow, equals('7-9 AM'));
    });

    test('calculates countdown in hours', () {
      // Arrange
      final window = PickupWindow(
        start: DateTime.now().add(const Duration(hours: 5)),
        end: DateTime.now().add(const Duration(hours: 7)),
      );

      // Assert
      expect(window.countdownText, contains('hours'));
    });
  });
}
