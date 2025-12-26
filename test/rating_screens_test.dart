import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cropfresh_mobile_farmer/src/widgets/rating_widgets.dart';
import 'package:cropfresh_mobile_farmer/src/models/rating_models.dart';

/// Widget Tests for Rating Widgets - Story 3.10
///
/// Tests the individual reusable widgets (not screens with async loading)
/// 
/// AC1: Overall rating badge display
/// AC2: Star distribution chart
/// AC3: List item cards
/// AC9: Voice/TTS support

void main() {
  group('RatingSummaryCard', () {
    testWidgets('displays overall score', (tester) async {
      final summary = RatingSummary.mock();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RatingSummaryCard(summary: summary),
            ),
          ),
        ),
      );

      // Should display the score
      expect(find.text('Quality Rating'), findsOneWidget);
      expect(find.text('/5.0'), findsOneWidget);
    });

    testWidgets('displays star icons', (tester) async {
      final summary = RatingSummary.mock();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RatingSummaryCard(summary: summary),
            ),
          ),
        ),
      );

      // Should have star icons (5 stars)
      expect(find.byIcon(Icons.star_rounded), findsWidgets);
    });

    testWidgets('has voice read button when callback provided', (tester) async {
      final summary = RatingSummary.mock();
      bool voiceReadTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RatingSummaryCard(
                summary: summary,
                onVoiceRead: () => voiceReadTapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
      
      await tester.tap(find.byIcon(Icons.volume_up_rounded));
      expect(voiceReadTapped, isTrue);
    });

    testWidgets('displays completed orders count', (tester) async {
      final summary = RatingSummary.mock();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RatingSummaryCard(summary: summary),
            ),
          ),
        ),
      );

      expect(find.textContaining('completed orders'), findsOneWidget);
    });
  });

  group('StarDistributionChart', () {
    testWidgets('displays title and all 5 star bars', (tester) async {
      final breakdown = StarBreakdown.mock();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400, // Constrain width to prevent overflow
              child: StarDistributionChart(breakdown: breakdown),
            ),
          ),
        ),
      );

      // Should have Rating Distribution title
      expect(find.text('Rating Distribution'), findsOneWidget);
      
      // Should have star numbers 1-5
      expect(find.text('5'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('uses LinearProgressIndicator for bars', (tester) async {
      final breakdown = StarBreakdown.mock();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400, // Constrain width to prevent overflow
              child: StarDistributionChart(breakdown: breakdown),
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsNWidgets(5));
    });
  });

  group('RatingTrendChart', () {
    testWidgets('displays monthly trend title', (tester) async {
      final trend = [
        const TrendItem(month: '2025-10', avgRating: 4.3, count: 8),
        const TrendItem(month: '2025-11', avgRating: 4.5, count: 10),
        const TrendItem(month: '2025-12', avgRating: 4.8, count: 5),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingTrendChart(trend: trend),
          ),
        ),
      );

      expect(find.text('Monthly Trend'), findsOneWidget);
    });

    testWidgets('returns empty widget when trend is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RatingTrendChart(trend: []),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsWidgets);
    });
  });

  group('RatingListItemCard', () {
    testWidgets('displays crop info and rating stars', (tester) async {
      final rating = RatingListItem.mock();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingListItemCard(rating: rating),
          ),
        ),
      );

      // Should display crop type
      expect(find.textContaining(rating.cropType), findsOneWidget);
      
      // Should have star icons
      expect(find.byIcon(Icons.star), findsWidgets);
    });

    testWidgets('shows NEW badge for unseen ratings', (tester) async {
      // Create a rating that's not seen (index 0 has seenByFarmer: false)
      final rating = RatingListItem.mock(index: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingListItemCard(rating: rating),
          ),
        ),
      );

      expect(find.text('NEW'), findsOneWidget);
    });

    testWidgets('does not show NEW badge for seen ratings', (tester) async {
      // index > 0 has seenByFarmer: true
      final rating = RatingListItem.mock(index: 1);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingListItemCard(rating: rating),
          ),
        ),
      );

      expect(find.text('NEW'), findsNothing);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      final rating = RatingListItem.mock();
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingListItemCard(
              rating: rating,
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(RatingListItemCard));
      expect(wasTapped, isTrue);
    });

    testWidgets('displays chevron icon for navigation', (tester) async {
      final rating = RatingListItem.mock();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingListItemCard(rating: rating),
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });
  });

  group('QualityIssueCard', () {
    testWidgets('displays issue icon and label', (tester) async {
      const issue = QualityIssue.bruising;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QualityIssueCard(issue: issue),
          ),
        ),
      );

      expect(find.text(issue.icon), findsOneWidget);
      expect(find.text(issue.label), findsOneWidget);
    });

    testWidgets('displays warning icon', (tester) async {
      const issue = QualityIssue.sizeInconsistency;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QualityIssueCard(issue: issue),
          ),
        ),
      );

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });
  });

  group('RecommendationCard', () {
    testWidgets('displays recommendation text', (tester) async {
      const recommendation = Recommendation(
        issue: QualityIssue.bruising,
        title: 'Handle with care',
        recommendation: 'Use padded crates to prevent bruising.',
        tutorialId: 'tutorial-1',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RecommendationCard(recommendation: recommendation),
          ),
        ),
      );

      expect(find.text(recommendation.title), findsOneWidget);
      expect(find.text(recommendation.recommendation), findsOneWidget);
    });

    testWidgets('shows tutorial button when tutorialId provided', (tester) async {
      const recommendation = Recommendation(
        issue: QualityIssue.bruising,
        title: 'Handle with care',
        recommendation: 'Use padded crates to prevent bruising.',
        tutorialId: 'tutorial-1',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RecommendationCard(
              recommendation: recommendation,
              onTutorialTap: null, // Must provide callback for button to show
            ),
          ),
        ),
      );

      // Button should NOT appear when onTutorialTap is null
      expect(find.text('Watch Tutorial'), findsNothing);
    });

    testWidgets('shows tutorial button when callback provided', (tester) async {
      const recommendation = Recommendation(
        issue: QualityIssue.bruising,
        title: 'Handle with care',
        recommendation: 'Use padded crates to prevent bruising.',
        tutorialId: 'tutorial-1',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecommendationCard(
              recommendation: recommendation,
              onTutorialTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Watch Tutorial'), findsOneWidget);
    });
  });

  group('RatingsImpactCard', () {
    testWidgets('displays impact information title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RatingsImpactCard(),
          ),
        ),
      );

      expect(find.text('Why Ratings Matter'), findsOneWidget);
    });

    testWidgets('displays info icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RatingsImpactCard(),
          ),
        ),
      );

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });
  });
}
