// Photo Quality Models - Story 3.2
// Shared models for photo quality validation across screens and widgets.

/// Types of quality issues that can be detected in photos
enum QualityIssueType {
  tooDark,
  tooBright,
  blurry,
  noProduce,
  lowResolution,
}

/// Represents a single quality issue with a message and suggestion
class PhotoQualityIssue {
  final QualityIssueType type;
  final String message;
  final String suggestion;

  const PhotoQualityIssue({
    required this.type,
    required this.message,
    required this.suggestion,
  });
}

/// Result of photo quality validation
class PhotoQualityResult {
  final bool isValid;
  final double qualityScore; // 0.0 - 1.0
  final List<PhotoQualityIssue> issues;

  const PhotoQualityResult({
    required this.isValid,
    required this.qualityScore,
    required this.issues,
  });
}
