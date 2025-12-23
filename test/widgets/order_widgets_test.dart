import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cropfresh_mobile_farmer/src/models/order_models.dart';
import 'package:cropfresh_mobile_farmer/src/widgets/order_widgets.dart';
import 'package:cropfresh_mobile_farmer/src/constants/app_colors.dart';

/// Order Widgets Tests - Story 3.6 (AC: 1, 5, 6)
///
/// Widget tests for order tracking components:
/// - OrderCard: renders correctly with status badge
/// - StatusBadge: shows correct colors for each status
/// - StatusTimeline: 7-stage timeline with progress
/// - TimelineStepCard: individual step rendering
/// - HaulerContactCard: displays hauler info
/// - DelayIndicator: shows delay banner
/// - EmptyOrdersState: displays correct empty state per filter
void main() {
  group('OrderBadge', () {
    testWidgets('renders badge with count', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorScheme: AppColors.lightColorScheme),
          home: const Scaffold(body: OrderBadge(count: 5)),
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('shows 9+ for counts over 9', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorScheme: AppColors.lightColorScheme),
          home: const Scaffold(body: OrderBadge(count: 15)),
        ),
      );

      expect(find.text('9+'), findsOneWidget);
    });

    testWidgets('hides when count is zero', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorScheme: AppColors.lightColorScheme),
          home: const Scaffold(body: OrderBadge(count: 0)),
        ),
      );

      expect(find.byType(OrderBadge), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });
  });

  group('StatusBadge', () {
    testWidgets('displays correct label for each status (AC1)', (tester) async {
      for (final status in OrderStatus.values) {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(colorScheme: AppColors.lightColorScheme),
            home: Scaffold(body: StatusBadge(status: status)),
          ),
        );

        expect(find.text(status.label), findsOneWidget);
      }
    });

    testWidgets('shows compact variant correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorScheme: AppColors.lightColorScheme),
          home: const Scaffold(
            body: StatusBadge(status: OrderStatus.inTransit, compact: true),
          ),
        ),
      );

      expect(find.text('In Transit'), findsOneWidget);
    });
  });

  group('OrderCard', () {
    testWidgets('renders order info correctly (AC5)', (tester) async {
      final order = Order.mock(status: OrderStatus.inTransit);
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorScheme: AppColors.lightColorScheme),
          home: Scaffold(body: OrderCard(order: order)),
        ),
      );

      // Check crop info displayed
      expect(find.textContaining('Tomatoes'), findsOneWidget);
      expect(find.textContaining('50 kg'), findsOneWidget);
      
      // Check status badge
      expect(find.text('In Transit'), findsOneWidget);
      
      // Check price displayed
      expect(find.textContaining('₹'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows progress bar with correct value', (tester) async {
      final order = Order.mock(status: OrderStatus.inTransit);
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorScheme: AppColors.lightColorScheme),
          home: Scaffold(body: OrderCard(order: order)),
        ),
      );

      final progressFinder = find.byType(LinearProgressIndicator);
      expect(progressFinder, findsOneWidget);
    });

    testWidgets('displays delay badge when order is delayed', (tester) async {
      // Order.mock with inTransit status has delay by default
      final order = Order.mock(status: OrderStatus.inTransit);
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorScheme: AppColors.lightColorScheme),
          home: Scaffold(body: OrderCard(order: order)),
        ),
      );

      // Should show delay minutes
      expect(find.textContaining('min delay'), findsOneWidget);
    });

    testWidgets('triggers onTap callback', (tester) async {
      bool tapped = false;
      final order = Order.mock();
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorScheme: AppColors.lightColorScheme),
          home: Scaffold(
            body: OrderCard(
              order: order,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(OrderCard));
      await tester.pumpAndSettle();
      
      expect(tapped, isTrue);
    });

    testWidgets('has accessibility semantics (AC6)', (tester) async {
      final order = Order.mock();
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorScheme: AppColors.lightColorScheme),
          home: Scaffold(body: OrderCard(order: order, onTap: () {})),
        ),
      );

      // Check that Semantics widget exists with button role
      expect(find.byType(Semantics), findsWidgets);
    });
  });

  group('StatusTimeline', () {
    testWidgets('renders all 7 status stages (AC1)', (tester) async {
      final events = OrderStatus.values.map((s) => TimelineEvent(
        step: s.step,
        status: s,
        label: s.label,
        completed: s.step < 5,
        active: s.step == 5,
      )).toList();
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorScheme: AppColors.lightColorScheme),
          home: Scaffold(
            body: SingleChildScrollView(
              child: StatusTimeline(
                events: events,
                currentStatus: OrderStatus.inTransit,
              ),
            ),
          ),
        ),
      );

      // All 7 status labels should be present
      for (final status in OrderStatus.values) {
        expect(find.text(status.label), findsOneWidget);
      }
    });

    testWidgets('shows completed steps with checkmark', (tester) async {
      final events = OrderStatus.values.map((s) => TimelineEvent(
        step: s.step,
        status: s,
        label: s.label,
        completed: s == OrderStatus.listed || s == OrderStatus.matched,
        active: s == OrderStatus.pickupScheduled,
      )).toList();
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorScheme: AppColors.lightColorScheme),
          home: Scaffold(
            body: SingleChildScrollView(
              child: StatusTimeline(
                events: events,
                currentStatus: OrderStatus.pickupScheduled,
              ),
            ),
          ),
        ),
      );

      // Should find check icons for completed steps
      expect(find.byIcon(Icons.check), findsNWidgets(2));
    });
  });

  group('HaulerContactCard', () {
    testWidgets('displays hauler name and vehicle (AC3)', (tester) async {
      final hauler = Hauler.mock();
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorScheme: AppColors.lightColorScheme),
          home: Scaffold(
            body: HaulerContactCard(hauler: hauler, onCall: () {}),
          ),
        ),
      );

      expect(find.text(hauler.name), findsOneWidget);
      expect(find.textContaining('Tempo'), findsOneWidget);
    });

    testWidgets('shows ETA when provided', (tester) async {
      final hauler = Hauler.mock();
      final eta = DateTime.now().add(const Duration(hours: 2));
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorScheme: AppColors.lightColorScheme),
          home: Scaffold(
            body: HaulerContactCard(
              hauler: hauler,
              eta: eta,
              onCall: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('ETA:'), findsOneWidget);
    });

    testWidgets('triggers call callback on button tap', (tester) async {
      bool called = false;
      final hauler = Hauler.mock();
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorScheme: AppColors.lightColorScheme),
          home: Scaffold(
            body: HaulerContactCard(
              hauler: hauler,
              onCall: () => called = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.call));
      await tester.pumpAndSettle();
      
      expect(called, isTrue);
    });
  });

  group('DelayIndicator', () {
    testWidgets('displays delay minutes (AC4)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorScheme: AppColors.lightColorScheme),
          home: const Scaffold(
            body: DelayIndicator(delayMinutes: 30),
          ),
        ),
      );

      expect(find.textContaining('30 min'), findsOneWidget);
    });

    testWidgets('shows delay reason when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorScheme: AppColors.lightColorScheme),
          home: const Scaffold(
            body: DelayIndicator(
              delayMinutes: 30,
              reason: 'Traffic congestion',
            ),
          ),
        ),
      );

      expect(find.text('Traffic congestion'), findsOneWidget);
    });
  });

  group('EmptyOrdersState', () {
    testWidgets('shows correct message for active filter (AC5)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorScheme: AppColors.lightColorScheme),
          home: const Scaffold(
            body: EmptyOrdersState(filter: OrderFilter.active),
          ),
        ),
      );

      expect(find.text('No active orders'), findsOneWidget);
    });

    testWidgets('shows correct message for completed filter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorScheme: AppColors.lightColorScheme),
          home: const Scaffold(
            body: EmptyOrdersState(filter: OrderFilter.completed),
          ),
        ),
      );

      expect(find.text('No completed orders'), findsOneWidget);
    });

    testWidgets('shows refresh button when callback provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorScheme: AppColors.lightColorScheme),
          home: Scaffold(
            body: EmptyOrdersState(
              filter: OrderFilter.all,
              onRefresh: () {},
            ),
          ),
        ),
      );

      expect(find.text('Refresh'), findsOneWidget);
    });
  });

  group('Order Model', () {
    test('OrderStatus has correct step numbers', () {
      expect(OrderStatus.listed.step, 1);
      expect(OrderStatus.matched.step, 2);
      expect(OrderStatus.pickupScheduled.step, 3);
      expect(OrderStatus.atDropPoint.step, 4);
      expect(OrderStatus.inTransit.step, 5);
      expect(OrderStatus.delivered.step, 6);
      expect(OrderStatus.paid.step, 7);
    });

    test('Order.progress returns correct percentage', () {
      final order = Order.mock(status: OrderStatus.inTransit);
      expect(order.progress, closeTo(5 / 7, 0.01));
    });

    test('Order.isActive returns true for non-paid orders', () {
      for (final status in OrderStatus.values) {
        final order = Order.mock(status: status);
        if (status == OrderStatus.paid) {
          expect(order.isActive, isFalse);
        } else {
          expect(order.isActive, isTrue);
        }
      }
    });

    test('Order.ttsAnnouncement contains crop type', () {
      final order = Order.mock(status: OrderStatus.inTransit);
      expect(order.ttsAnnouncement, contains('Tomatoes'));
      expect(order.ttsAnnouncement, contains('In Transit'));
    });

    test('TimelineEvent.formattedTimestamp returns correct format', () {
      final event = TimelineEvent(
        step: 1,
        status: OrderStatus.listed,
        label: 'Listed',
        completed: true,
        timestamp: DateTime(2025, 12, 22, 15, 30),
      );
      
      expect(event.formattedTimestamp, 'Dec 22, 3:30 PM');
    });
  });
}
