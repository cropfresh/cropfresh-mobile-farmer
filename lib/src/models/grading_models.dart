// AI Grading Models - Story 3.3
// Models for AI quality grading and DPLE price estimation.

/// Quality grade assigned by AI
enum QualityGrade {
  A,
  B,
  C,
}

/// Extension methods for QualityGrade
extension QualityGradeExtension on QualityGrade {
  String get label {
    switch (this) {
      case QualityGrade.A:
        return 'Grade A';
      case QualityGrade.B:
        return 'Grade B';
      case QualityGrade.C:
        return 'Grade C';
    }
  }

  String get description {
    switch (this) {
      case QualityGrade.A:
        return 'Premium Quality';
      case QualityGrade.B:
        return 'Good Quality';
      case QualityGrade.C:
        return 'Fair Quality';
    }
  }

  String get explanation {
    switch (this) {
      case QualityGrade.A:
        return 'Excellent color, uniform size, no defects';
      case QualityGrade.B:
        return 'Good quality, minor size variation';
      case QualityGrade.C:
        return 'Fair quality, some blemishes detected';
    }
  }

  double get priceMultiplier {
    switch (this) {
      case QualityGrade.A:
        return 1.20; // +20%
      case QualityGrade.B:
        return 1.00; // Baseline
      case QualityGrade.C:
        return 0.85; // -15%
    }
  }

  String get adjustmentLabel {
    switch (this) {
      case QualityGrade.A:
        return '+20%';
      case QualityGrade.B:
        return 'Baseline';
      case QualityGrade.C:
        return '-15%';
    }
  }
}

/// Type of quality indicator evaluated by AI
enum QualityIndicatorType {
  freshness,
  colorVibrancy,
  sizeConsistency,
  surfaceQuality,
  ripeness,
}

/// Extension methods for QualityIndicatorType
extension QualityIndicatorTypeExtension on QualityIndicatorType {
  String get label {
    switch (this) {
      case QualityIndicatorType.freshness:
        return 'Freshness';
      case QualityIndicatorType.colorVibrancy:
        return 'Color';
      case QualityIndicatorType.sizeConsistency:
        return 'Size';
      case QualityIndicatorType.surfaceQuality:
        return 'Surface';
      case QualityIndicatorType.ripeness:
        return 'Ripeness';
    }
  }

  String get iconName {
    switch (this) {
      case QualityIndicatorType.freshness:
        return 'spa';
      case QualityIndicatorType.colorVibrancy:
        return 'palette';
      case QualityIndicatorType.sizeConsistency:
        return 'straighten';
      case QualityIndicatorType.surfaceQuality:
        return 'texture';
      case QualityIndicatorType.ripeness:
        return 'eco';
    }
  }
}

/// Individual quality indicator with score
class QualityIndicator {
  final QualityIndicatorType type;
  final double score; // 0.0 - 1.0
  final String label; // e.g., "Excellent", "Good", "Fair"

  const QualityIndicator({
    required this.type,
    required this.score,
    required this.label,
  });

  /// Create from JSON (API response)
  factory QualityIndicator.fromJson(Map<String, dynamic> json) {
    return QualityIndicator(
      type: _parseIndicatorType(json['type'] as String? ?? 'freshness'),
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      label: json['label'] as String? ?? 'Unknown',
    );
  }

  static QualityIndicatorType _parseIndicatorType(String type) {
    switch (type.toLowerCase()) {
      case 'freshness':
        return QualityIndicatorType.freshness;
      case 'color':
      case 'color_vibrancy':
        return QualityIndicatorType.colorVibrancy;
      case 'size':
      case 'size_consistency':
        return QualityIndicatorType.sizeConsistency;
      case 'surface':
      case 'surface_quality':
        return QualityIndicatorType.surfaceQuality;
      case 'ripeness':
        return QualityIndicatorType.ripeness;
      default:
        return QualityIndicatorType.freshness;
    }
  }
}

/// AI grading result for a produce photo
class GradingResult {
  final QualityGrade grade;
  final double confidence; // 0.0 - 1.0
  final List<QualityIndicator> indicators;
  final String explanation;
  final DateTime gradedAt;

  const GradingResult({
    required this.grade,
    required this.confidence,
    required this.indicators,
    required this.explanation,
    required this.gradedAt,
  });

  /// Create from JSON (API response)
  factory GradingResult.fromJson(Map<String, dynamic> json) {
    return GradingResult(
      grade: _parseGrade(json['grade'] as String? ?? 'B'),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      indicators: (json['quality_indicators'] as List<dynamic>?)
              ?.map((e) => QualityIndicator.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      explanation: json['explanation'] as String? ?? '',
      gradedAt: DateTime.now(),
    );
  }

  static QualityGrade _parseGrade(String grade) {
    switch (grade.toUpperCase()) {
      case 'A':
        return QualityGrade.A;
      case 'B':
        return QualityGrade.B;
      case 'C':
        return QualityGrade.C;
      default:
        return QualityGrade.B;
    }
  }

  /// Create mock grading result for development
  factory GradingResult.mock({QualityGrade? grade}) {
    final mockGrade = grade ?? QualityGrade.A;
    return GradingResult(
      grade: mockGrade,
      confidence: mockGrade == QualityGrade.A
          ? 0.95
          : mockGrade == QualityGrade.B
              ? 0.88
              : 0.72,
      indicators: [
        QualityIndicator(
          type: QualityIndicatorType.freshness,
          score: mockGrade == QualityGrade.A ? 0.92 : 0.75,
          label: mockGrade == QualityGrade.A ? 'Excellent' : 'Good',
        ),
        QualityIndicator(
          type: QualityIndicatorType.colorVibrancy,
          score: mockGrade == QualityGrade.A ? 0.94 : 0.78,
          label: mockGrade == QualityGrade.A ? 'Vibrant' : 'Normal',
        ),
        QualityIndicator(
          type: QualityIndicatorType.sizeConsistency,
          score: mockGrade == QualityGrade.A ? 0.88 : 0.68,
          label: mockGrade == QualityGrade.A ? 'Uniform' : 'Varied',
        ),
        QualityIndicator(
          type: QualityIndicatorType.surfaceQuality,
          score: mockGrade == QualityGrade.A ? 0.95 : 0.80,
          label: mockGrade == QualityGrade.A ? 'No defects' : 'Minor marks',
        ),
      ],
      explanation: mockGrade.explanation,
      gradedAt: DateTime.now(),
    );
  }
}

/// DPLE Price breakdown result
class PriceBreakdown {
  final double marketRatePerKg;
  final String gradeAdjustment;
  final double gradeMultiplier;
  final double finalPricePerKg;
  final double totalEarnings;
  final double quantityKg;
  final String currency;
  final String paymentTerms;

  const PriceBreakdown({
    required this.marketRatePerKg,
    required this.gradeAdjustment,
    required this.gradeMultiplier,
    required this.finalPricePerKg,
    required this.totalEarnings,
    required this.quantityKg,
    this.currency = 'INR',
    this.paymentTerms = 'T+0 on delivery',
  });

  /// Create from JSON (API response)
  factory PriceBreakdown.fromJson(Map<String, dynamic> json) {
    return PriceBreakdown(
      marketRatePerKg: (json['market_rate_per_kg'] as num?)?.toDouble() ?? 0.0,
      gradeAdjustment: json['grade_adjustment'] as String? ?? '',
      gradeMultiplier: (json['grade_multiplier'] as num?)?.toDouble() ?? 1.0,
      finalPricePerKg: (json['final_price_per_kg'] as num?)?.toDouble() ?? 0.0,
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      quantityKg: (json['quantity_kg'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      paymentTerms: json['payment_terms'] as String? ?? 'T+0 on delivery',
    );
  }

  /// Create mock price breakdown for development
  factory PriceBreakdown.mock({
    required QualityGrade grade,
    required double quantityKg,
    double? marketRate,
  }) {
    final baseRate = marketRate ?? 30.0;
    final multiplier = grade.priceMultiplier;
    final finalPrice = baseRate * multiplier;
    
    return PriceBreakdown(
      marketRatePerKg: baseRate,
      gradeAdjustment: grade.adjustmentLabel,
      gradeMultiplier: multiplier,
      finalPricePerKg: finalPrice,
      totalEarnings: finalPrice * quantityKg,
      quantityKg: quantityKg,
    );
  }
}

/// Rejection reason when farmer doesn't accept the offer
enum RejectionReason {
  retakePhoto,
  cancelListing,
  listAnyway,
}

/// Extension methods for RejectionReason
extension RejectionReasonExtension on RejectionReason {
  String get apiValue {
    switch (this) {
      case RejectionReason.retakePhoto:
        return 'RETAKE_PHOTO';
      case RejectionReason.cancelListing:
        return 'CANCEL';
      case RejectionReason.listAnyway:
        return 'LIST_ANYWAY';
    }
  }
}
