import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../models/photo_quality_models.dart';

/// Quality Guidance Widgets - Story 3.2 (AC4)
/// 
/// Reusable components for showing photo quality feedback:
/// - QualityGuidanceCard: Card showing quality issue with suggestion
/// - QualityComparisonModal: Side-by-side good vs bad photo comparison
/// - QualityFeedbackBanner: Inline banner for quick feedback
/// - QualityScoreBadge: Circular score indicator

// ============================================================================
// Quality Guidance Card
// ============================================================================

class QualityGuidanceCard extends StatelessWidget {
  final QualityIssueType issueType;
  final String message;
  final String suggestion;
  final VoidCallback? onRetake;
  final VoidCallback? onDismiss;

  const QualityGuidanceCard({
    super.key,
    required this.issueType,
    required this.message,
    required this.suggestion,
    this.onRetake,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIssueIcon(),
                    color: AppColors.error,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getIssueTitle(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onErrorContainer,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.onErrorContainer.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (onDismiss != null)
                  IconButton(
                    onPressed: onDismiss,
                    icon: Icon(
                      Icons.close,
                      color: AppColors.onErrorContainer.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),

          // Suggestion
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    suggestion,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Actions
          if (onRetake != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: onRetake,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Retake Photo'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIssueIcon() {
    switch (issueType) {
      case QualityIssueType.tooDark:
        return Icons.brightness_low;
      case QualityIssueType.tooBright:
        return Icons.brightness_high;
      case QualityIssueType.blurry:
        return Icons.blur_on;
      case QualityIssueType.noProduce:
        return Icons.image_not_supported;
      case QualityIssueType.lowResolution:
        return Icons.photo_size_select_small;
    }
  }

  String _getIssueTitle() {
    switch (issueType) {
      case QualityIssueType.tooDark:
        return 'Too Dark';
      case QualityIssueType.tooBright:
        return 'Too Bright';
      case QualityIssueType.blurry:
        return 'Blurry Photo';
      case QualityIssueType.noProduce:
        return 'No Produce Detected';
      case QualityIssueType.lowResolution:
        return 'Low Resolution';
    }
  }
}

// ============================================================================
// Quality Comparison Modal
// ============================================================================

class QualityComparisonModal extends StatelessWidget {
  final QualityIssueType issueType;
  final String? badPhotoPath;
  final VoidCallback onRetake;
  final VoidCallback onDismiss;

  const QualityComparisonModal({
    super.key,
    required this.issueType,
    this.badPhotoPath,
    required this.onRetake,
    required this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required QualityIssueType issueType,
    String? badPhotoPath,
    required VoidCallback onRetake,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QualityComparisonModal(
        issueType: issueType,
        badPhotoPath: badPhotoPath,
        onRetake: onRetake,
        onDismiss: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.compare,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Photo Comparison',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'See the difference',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Comparison images
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Bad example
                Expanded(
                  child: _buildComparisonCard(
                    label: 'Your Photo',
                    isGood: false,
                    icon: _getIssueIcon(),
                  ),
                ),
                const SizedBox(width: 16),
                // Good example
                Expanded(
                  child: _buildComparisonCard(
                    label: 'Good Example',
                    isGood: true,
                    icon: Icons.check_circle,
                  ),
                ),
              ],
            ),
          ),

          // Tips
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.tips_and_updates,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getTip(),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDismiss,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Keep Photo'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onRetake();
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Retake'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildComparisonCard({
    required String label,
    required bool isGood,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isGood
            ? AppColors.secondaryContainer.withValues(alpha: 0.5)
            : AppColors.errorContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGood ? AppColors.secondary : AppColors.error,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Placeholder for photo
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isGood
                  ? AppColors.secondary.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 40,
              color: isGood ? AppColors.secondary : AppColors.error,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isGood ? Icons.check_circle : Icons.cancel,
                size: 16,
                color: isGood ? AppColors.secondary : AppColors.error,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isGood
                      ? AppColors.onSecondaryContainer
                      : AppColors.onErrorContainer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIssueIcon() {
    switch (issueType) {
      case QualityIssueType.tooDark:
        return Icons.brightness_low;
      case QualityIssueType.tooBright:
        return Icons.brightness_high;
      case QualityIssueType.blurry:
        return Icons.blur_on;
      case QualityIssueType.noProduce:
        return Icons.image_not_supported;
      case QualityIssueType.lowResolution:
        return Icons.photo_size_select_small;
    }
  }

  String _getTip() {
    switch (issueType) {
      case QualityIssueType.tooDark:
        return 'Move to a brighter area or use natural daylight for better visibility.';
      case QualityIssueType.tooBright:
        return 'Avoid direct sunlight. Find a shaded area for more even lighting.';
      case QualityIssueType.blurry:
        return 'Hold your phone steady and tap to focus before taking the photo.';
      case QualityIssueType.noProduce:
        return 'Make sure your produce is clearly visible and fills most of the frame.';
      case QualityIssueType.lowResolution:
        return 'Move closer to your produce to capture more detail.';
    }
  }
}

// ============================================================================
// Quality Feedback Banner
// ============================================================================

class QualityFeedbackBanner extends StatelessWidget {
  final bool isSuccess;
  final String message;
  final VoidCallback? onAction;
  final String? actionLabel;

  const QualityFeedbackBanner({
    super.key,
    required this.isSuccess,
    required this.message,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSuccess ? AppColors.secondary : AppColors.error,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isSuccess ? AppColors.secondary : AppColors.error)
                .withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.warning_rounded,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onAction != null && actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// Quality Score Badge
// ============================================================================

class QualityScoreBadge extends StatelessWidget {
  final double score; // 0.0 - 1.0
  final double size;

  const QualityScoreBadge({
    super.key,
    required this.score,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (score * 100).round();
    final isGood = score >= 0.7;
    final color = isGood ? AppColors.secondary : AppColors.error;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color, width: 3),
      ),
      child: Center(
        child: Text(
          '$percentage',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.35,
          ),
        ),
      ),
    );
  }
}
