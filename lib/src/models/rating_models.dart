/// Rating Models - Story 3.10
///
/// Data models for farmer quality ratings and feedback.
/// Follows transaction_models.dart pattern.
///
/// Includes: RatingSummary, RatingListItem, RatingDetails,
/// QualityIssue, Recommendation, StarBreakdown, TrendItem

import 'package:intl/intl.dart';

// ============================================
// ENUMS
// ============================================

/// Quality issue categories for ratings
enum QualityIssue {
  bruising('BRUISING', 'Bruising', '🟣'),
  sizeInconsistency('SIZE_INCONSISTENCY', 'Size Inconsistency', '📏'),
  ripenessIssues('RIPENESS_ISSUES', 'Ripeness Issues', '🍃'),
  freshnessConcerns('FRESHNESS_CONCERNS', 'Freshness Concerns', '⏰'),
  packagingProblems('PACKAGING_PROBLEMS', 'Packaging Problems', '📦');

  final String value;
  final String label;
  final String icon;
  const QualityIssue(this.value, this.label, this.icon);

  static QualityIssue fromString(String value) {
    return QualityIssue.values.firstWhere(
      (e) => e.value == value,
      orElse: () => QualityIssue.bruising,
    );
  }
}

// ============================================
// RATING SUMMARY
// ============================================

/// Star breakdown for distribution chart (AC2)
class StarBreakdown {
  final int star5;
  final int star4;
  final int star3;
  final int star2;
  final int star1;

  const StarBreakdown({
    required this.star5,
    required this.star4,
    required this.star3,
    required this.star2,
    required this.star1,
  });

  int get total => star5 + star4 + star3 + star2 + star1;

  double percentage(int stars) {
    if (total == 0) return 0;
    switch (stars) {
      case 5: return star5 / total * 100;
      case 4: return star4 / total * 100;
      case 3: return star3 / total * 100;
      case 2: return star2 / total * 100;
      case 1: return star1 / total * 100;
      default: return 0;
    }
  }

  factory StarBreakdown.fromJson(Map<String, dynamic> json) {
    return StarBreakdown(
      star5: json['star5'] ?? 0,
      star4: json['star4'] ?? 0,
      star3: json['star3'] ?? 0,
      star2: json['star2'] ?? 0,
      star1: json['star1'] ?? 0,
    );
  }

  static StarBreakdown mock() => const StarBreakdown(
    star5: 18,
    star4: 4,
    star3: 1,
    star2: 0,
    star1: 0,
  );
}

/// Monthly trend item for line chart (AC6)
class TrendItem {
  final String month;
  final double avgRating;
  final int count;

  const TrendItem({
    required this.month,
    required this.avgRating,
    required this.count,
  });

  String get formattedMonth {
    try {
      final date = DateTime.parse('$month-01');
      return DateFormat('MMM').format(date);
    } catch (_) {
      return month;
    }
  }

  factory TrendItem.fromJson(Map<String, dynamic> json) {
    return TrendItem(
      month: json['month'] ?? '',
      avgRating: (json['avgRating'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
    );
  }
}

/// Aggregate rating summary (AC2)
class RatingSummary {
  final double overallScore;
  final int totalOrders;
  final StarBreakdown starBreakdown;
  final List<TrendItem> monthlyTrend;
  final String? bestCropType;
  final int unseenCount;

  const RatingSummary({
    required this.overallScore,
    required this.totalOrders,
    required this.starBreakdown,
    required this.monthlyTrend,
    this.bestCropType,
    required this.unseenCount,
  });

  bool get hasRatings => totalOrders > 0;
  bool get hasUnseen => unseenCount > 0;

  /// TTS announcement for voice-first UX (AC9)
  String get ttsAnnouncement {
    if (!hasRatings) {
      return 'You have no ratings yet. Complete your first order to receive ratings.';
    }
    return 'Your quality rating is ${overallScore.toStringAsFixed(1)} out of 5 stars, '
        'based on $totalOrders completed orders. '
        '${hasUnseen ? 'You have $unseenCount new ratings to view.' : ''}';
  }

  factory RatingSummary.fromJson(Map<String, dynamic> json) {
    return RatingSummary(
      overallScore: (json['overallScore'] ?? 0).toDouble(),
      totalOrders: json['totalOrders'] ?? 0,
      starBreakdown: StarBreakdown.fromJson(json['starBreakdown'] ?? {}),
      monthlyTrend: (json['monthlyTrend'] as List? ?? [])
          .map((e) => TrendItem.fromJson(e))
          .toList(),
      bestCropType: json['bestCropType'],
      unseenCount: json['unseenCount'] ?? 0,
    );
  }

  static RatingSummary mock() => RatingSummary(
    overallScore: 4.7,
    totalOrders: 23,
    starBreakdown: StarBreakdown.mock(),
    monthlyTrend: [
      const TrendItem(month: '2025-10', avgRating: 4.3, count: 8),
      const TrendItem(month: '2025-11', avgRating: 4.5, count: 10),
      const TrendItem(month: '2025-12', avgRating: 4.8, count: 5),
    ],
    bestCropType: 'Tomato',
    unseenCount: 2,
  );
}

// ============================================
// RATING LIST ITEM
// ============================================

/// Individual rating for list view (AC3)
class RatingListItem {
  final String id;
  final int orderId;
  final String cropType;
  final String cropIcon;
  final double quantityKg;
  final int rating;
  final String? comment;
  final List<QualityIssue> qualityIssues;
  final DateTime ratedAt;
  final bool seenByFarmer;

  const RatingListItem({
    required this.id,
    required this.orderId,
    required this.cropType,
    required this.cropIcon,
    required this.quantityKg,
    required this.rating,
    this.comment,
    required this.qualityIssues,
    required this.ratedAt,
    required this.seenByFarmer,
  });

  bool get hasIssues => qualityIssues.isNotEmpty;
  bool get isLowRating => rating < 4;
  
  String get formattedDate => DateFormat('MMM d, y').format(ratedAt);
  String get formattedQuantity => '${quantityKg.toStringAsFixed(0)} kg';
  
  String get truncatedComment {
    if (comment == null || comment!.isEmpty) return '';
    return comment!.length > 80 ? '${comment!.substring(0, 80)}...' : comment!;
  }

  /// Semantic label for accessibility
  String get semanticLabel {
    return '$rating star rating for $cropType, $formattedQuantity, rated on $formattedDate. '
        '${comment ?? 'No comment'}';
  }

  factory RatingListItem.fromJson(Map<String, dynamic> json) {
    return RatingListItem(
      id: json['id'] ?? '',
      orderId: json['orderId'] ?? 0,
      cropType: json['cropType'] ?? '',
      cropIcon: json['cropIcon'] ?? '🥬',
      quantityKg: (json['quantityKg'] ?? 0).toDouble(),
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      qualityIssues: (json['qualityIssues'] as List? ?? [])
          .map((e) => QualityIssue.fromString(e))
          .toList(),
      ratedAt: DateTime.tryParse(json['ratedAt'] ?? '') ?? DateTime.now(),
      seenByFarmer: json['seenByFarmer'] ?? false,
    );
  }

  static RatingListItem mock({int index = 0, int rating = 5}) {
    final crops = ['Tomato', 'Potato', 'Onion', 'Carrot', 'Cabbage'];
    final icons = ['🍅', '🥔', '🧅', '🥕', '🥬'];
    final cropIndex = index % crops.length;
    
    return RatingListItem(
      id: 'rating-$index',
      orderId: 1000 + index,
      cropType: crops[cropIndex],
      cropIcon: icons[cropIndex],
      quantityKg: 50 + (index * 10).toDouble(),
      rating: rating,
      comment: rating >= 4 
          ? 'Excellent quality produce!'
          : 'Some items had quality issues.',
      qualityIssues: rating < 4 
          ? [QualityIssue.bruising]
          : [],
      ratedAt: DateTime.now().subtract(Duration(days: index)),
      seenByFarmer: index > 0,
    );
  }
}

// ============================================
// RATING DETAILS
// ============================================

/// Improvement recommendation for quality issues (AC5)
class Recommendation {
  final QualityIssue issue;
  final String title;
  final String recommendation;
  final String? tutorialId;

  const Recommendation({
    required this.issue,
    required this.title,
    required this.recommendation,
    this.tutorialId,
  });

  bool get hasTutorial => tutorialId != null && tutorialId!.isNotEmpty;

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      issue: QualityIssue.fromString(json['issue'] ?? ''),
      title: json['title'] ?? '',
      recommendation: json['recommendation'] ?? '',
      tutorialId: json['tutorialId'],
    );
  }
}

/// Full rating details for detail view (AC4)
class RatingDetails {
  final String id;
  final int orderId;
  final String cropType;
  final String cropIcon;
  final double quantityKg;
  final int rating;
  final String? comment;
  final List<QualityIssue> qualityIssues;
  final List<Recommendation> recommendations;
  final DateTime ratedAt;
  final DateTime? deliveredAt;
  final String? aiGradedPhotoUrl;
  final String? buyerPhotoUrl;

  const RatingDetails({
    required this.id,
    required this.orderId,
    required this.cropType,
    required this.cropIcon,
    required this.quantityKg,
    required this.rating,
    this.comment,
    required this.qualityIssues,
    required this.recommendations,
    required this.ratedAt,
    this.deliveredAt,
    this.aiGradedPhotoUrl,
    this.buyerPhotoUrl,
  });

  bool get hasIssues => qualityIssues.isNotEmpty;
  bool get hasRecommendations => recommendations.isNotEmpty;
  bool get hasPhotos => aiGradedPhotoUrl != null || buyerPhotoUrl != null;
  
  String get formattedDate => DateFormat('MMMM d, y').format(ratedAt);
  String get formattedQuantity => '${quantityKg.toStringAsFixed(0)} kg';

  /// TTS announcement for voice-first UX (AC9)
  String get ttsAnnouncement {
    final base = 'Rating for $formattedQuantity of $cropType: $rating stars. ';
    final commentPart = comment != null && comment!.isNotEmpty 
        ? 'Buyer comment: $comment. '
        : '';
    final issuePart = hasIssues 
        ? 'Quality issues: ${qualityIssues.map((e) => e.label).join(', ')}. '
        : '';
    return base + commentPart + issuePart;
  }

  factory RatingDetails.fromJson(Map<String, dynamic> json) {
    return RatingDetails(
      id: json['id'] ?? '',
      orderId: json['orderId'] ?? 0,
      cropType: json['cropType'] ?? '',
      cropIcon: json['cropIcon'] ?? '🥬',
      quantityKg: (json['quantityKg'] ?? 0).toDouble(),
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      qualityIssues: (json['qualityIssues'] as List? ?? [])
          .map((e) => QualityIssue.fromString(e))
          .toList(),
      recommendations: (json['recommendations'] as List? ?? [])
          .map((e) => Recommendation.fromJson(e))
          .toList(),
      ratedAt: DateTime.tryParse(json['ratedAt'] ?? '') ?? DateTime.now(),
      deliveredAt: json['deliveredAt'] != null 
          ? DateTime.tryParse(json['deliveredAt'])
          : null,
      aiGradedPhotoUrl: json['aiGradedPhotoUrl'],
      buyerPhotoUrl: json['buyerPhotoUrl'],
    );
  }

  static RatingDetails mock({int rating = 3}) {
    return RatingDetails(
      id: 'rating-detail-1',
      orderId: 1001,
      cropType: 'Onion',
      cropIcon: '🧅',
      quantityKg: 75,
      rating: rating,
      comment: 'Some items were bruised. Overall acceptable but could be better.',
      qualityIssues: rating < 4 ? [QualityIssue.bruising] : [],
      recommendations: rating < 4 
          ? [
              const Recommendation(
                issue: QualityIssue.bruising,
                title: 'Bruising detected',
                recommendation: 'Handle produce gently during transport. Use padded crates and avoid stacking too high.',
                tutorialId: 'handling-101',
              ),
            ]
          : [],
      ratedAt: DateTime.now().subtract(const Duration(days: 3)),
      deliveredAt: DateTime.now().subtract(const Duration(days: 4)),
    );
  }
}

// ============================================
// API RESPONSE MODELS
// ============================================

/// Paginated ratings list response
class RatingsResponse {
  final List<RatingListItem> ratings;
  final int page;
  final int limit;
  final int total;
  final bool hasMore;
  final RatingSummary summary;

  const RatingsResponse({
    required this.ratings,
    required this.page,
    required this.limit,
    required this.total,
    required this.hasMore,
    required this.summary,
  });

  factory RatingsResponse.fromJson(Map<String, dynamic> json) {
    final pagination = json['pagination'] ?? {};
    return RatingsResponse(
      ratings: (json['ratings'] as List? ?? [])
          .map((e) => RatingListItem.fromJson(e))
          .toList(),
      page: pagination['page'] ?? 1,
      limit: pagination['limit'] ?? 10,
      total: pagination['total'] ?? 0,
      hasMore: pagination['hasMore'] ?? false,
      summary: RatingSummary.fromJson(json['summary'] ?? {}),
    );
  }

  static RatingsResponse mock({int count = 10}) {
    return RatingsResponse(
      ratings: List.generate(
        count,
        (i) => RatingListItem.mock(
          index: i,
          rating: i % 3 == 0 ? 3 : (i % 2 == 0 ? 4 : 5),
        ),
      ),
      page: 1,
      limit: 10,
      total: 23,
      hasMore: true,
      summary: RatingSummary.mock(),
    );
  }
}
