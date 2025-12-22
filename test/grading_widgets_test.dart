// Grading Widgets & Models Tests - Story 3.3
// Tests for AI grading display components

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cropfresh_mobile_farmer/src/models/grading_models.dart';
import 'package:cropfresh_mobile_farmer/src/widgets/grading_widgets.dart';

void main() {
  // ============================================================================
  // Model Tests
  // ============================================================================
  
  group('QualityGrade', () {
    test('should have correct labels', () {
      expect(QualityGrade.A.label, equals('Grade A'));
      expect(QualityGrade.B.label, equals('Grade B'));
      expect(QualityGrade.C.label, equals('Grade C'));
    });

    test('should have correct descriptions', () {
      expect(QualityGrade.A.description, contains('Premium'));
      expect(QualityGrade.B.description, contains('Good'));
      expect(QualityGrade.C.description, contains('Fair'));
    });
  });

  group('GradingResult', () {
    test('mock should return valid Grade A result', () {
      final result = GradingResult.mock(grade: QualityGrade.A);
      
      expect(result.grade, equals(QualityGrade.A));
      expect(result.confidence, greaterThan(0.9));
      expect(result.indicators.length, greaterThan(0));
      expect(result.explanation, isNotEmpty);
    });

    test('mock should return valid Grade C result with lower confidence', () {
      final result = GradingResult.mock(grade: QualityGrade.C);
      
      expect(result.grade, equals(QualityGrade.C));
      expect(result.confidence, lessThan(0.9));
    });
  });

  group('PriceBreakdown', () {
    test('mock should apply +20% for Grade A', () {
      final breakdown = PriceBreakdown.mock(
        grade: QualityGrade.A,
        quantityKg: 10,
        marketRate: 100,
      );
      
      expect(breakdown.gradeAdjustment, equals('+20%'));
      expect(breakdown.gradeMultiplier, equals(1.2));
      expect(breakdown.finalPricePerKg, equals(120));
      expect(breakdown.totalEarnings, equals(1200));
    });

    test('mock should apply baseline for Grade B', () {
      final breakdown = PriceBreakdown.mock(
        grade: QualityGrade.B,
        quantityKg: 10,
        marketRate: 100,
      );
      
      expect(breakdown.gradeAdjustment, equals('Baseline'));
      expect(breakdown.gradeMultiplier, equals(1.0));
      expect(breakdown.finalPricePerKg, equals(100));
    });

    test('mock should apply -15% for Grade C', () {
      final breakdown = PriceBreakdown.mock(
        grade: QualityGrade.C,
        quantityKg: 10,
        marketRate: 100,
      );
      
      expect(breakdown.gradeAdjustment, equals('-15%'));
      expect(breakdown.gradeMultiplier, equals(0.85));
      expect(breakdown.finalPricePerKg, equals(85));
      expect(breakdown.totalEarnings, equals(850));
    });
  });

  // ============================================================================
  // Widget Tests
  // ============================================================================

  group('GradeBadge', () {
    testWidgets('should render Grade A', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradeBadge(grade: QualityGrade.A, size: 100),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.text('GRADE'), findsOneWidget);
    });

    testWidgets('should render Grade B', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradeBadge(grade: QualityGrade.B, size: 100),
          ),
        ),
      );

      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('should render Grade C', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradeBadge(grade: QualityGrade.C, size: 100),
          ),
        ),
      );

      expect(find.text('C'), findsOneWidget);
    });
  });

  group('QualityIndicatorChip', () {
    testWidgets('should render indicator with type label', (WidgetTester tester) async {
      const indicator = QualityIndicator(
        type: QualityIndicatorType.freshness,
        score: 0.92,
        label: 'Excellent',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QualityIndicatorChip(indicator: indicator),
          ),
        ),
      );

      expect(find.text('Freshness'), findsOneWidget);
      expect(find.text('Excellent'), findsOneWidget);
    });

    testWidgets('should render color indicator type', (WidgetTester tester) async {
      const colorIndicator = QualityIndicator(
        type: QualityIndicatorType.colorVibrancy,
        score: 0.88,
        label: 'Vibrant',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QualityIndicatorChip(indicator: colorIndicator),
          ),
        ),
      );

      expect(find.text('Color'), findsOneWidget);
    });
  });

  group('PriceBreakdownCard', () {
    testWidgets('should render card with price information', (WidgetTester tester) async {
      final priceBreakdown = PriceBreakdown.mock(
        grade: QualityGrade.A,
        quantityKg: 50,
        marketRate: 30,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PriceBreakdownCard(
                priceBreakdown: priceBreakdown,
                cropType: 'Tomato',
                grade: QualityGrade.A,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Just check the card renders without error
      expect(find.byType(PriceBreakdownCard), findsOneWidget);
    });
  });

  group('SuccessTickAnimation', () {
    testWidgets('should render widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: SuccessTickAnimation(size: 80)),
          ),
        ),
      );

      expect(find.byType(SuccessTickAnimation), findsOneWidget);
    });
  });
}
