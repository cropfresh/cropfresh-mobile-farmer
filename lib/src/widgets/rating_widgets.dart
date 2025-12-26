/// Rating Widgets - Story 3.10
///
/// Reusable UI components for ratings screens:
/// - RatingSummaryCard: Overall rating display (AC1, AC2)
/// - StarDistributionChart: Horizontal bar chart (AC2)
/// - RatingTrendChart: Monthly line chart (AC6)
/// - RatingListItemCard: Individual rating card (AC3)
/// - QualityIssueCard: Issue with icon (AC4)
/// - RecommendationCard: Improvement suggestion (AC5)
/// - RatingsImpactCard: Explain rating benefits (AC7)
///
/// Follows: Material Design 3, 60-30-10 color rule, 48dp touch targets,
/// voice-first TTS, WCAG 2.2 AA+ accessibility.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../models/rating_models.dart';

// ============================================
// AC1, AC2: RATING SUMMARY CARD
// ============================================

/// Main rating summary card with overall score and stats
class RatingSummaryCard extends StatelessWidget {
  final RatingSummary summary;
  final VoidCallback? onVoiceRead;

  const RatingSummaryCard({
    super.key,
    required this.summary,
    this.onVoiceRead,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: summary.ttsAnnouncement,
      child: Card(
        elevation: 8,
        shadowColor: AppColors.primary.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: AppColors.primaryGradient,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                // Header row
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 28,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Quality Rating',
                      style: AppTypography.titleMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (onVoiceRead != null)
                      IconButton(
                        onPressed: onVoiceRead,
                        icon: const Icon(Icons.volume_up_rounded),
                        color: Colors.white,
                        tooltip: 'Read aloud',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Big rating display
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      summary.overallScore.toStringAsFixed(1),
                      style: AppTypography.displayLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 64,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '/5.0',
                        style: AppTypography.titleLarge.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),

                // Star row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final filled = index < summary.overallScore.round();
                    return Icon(
                      filled ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: filled
                          ? AppColors.starFilled
                          : Colors.white.withValues(alpha: 0.5),
                      size: 28,
                    );
                  }),
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  '${summary.totalOrders} completed orders',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Stats row
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (summary.bestCropType != null)
                        Flexible(
                          child: _StatItem(
                            icon: Icons.emoji_events,
                            label: 'Best Crop',
                            value: summary.bestCropType!,
                          ),
                        ),
                      if (summary.bestCropType != null)
                        Container(
                          width: 1,
                          height: 32,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      Flexible(
                        child: _StatItem(
                          icon: Icons.trending_up,
                          label: 'This Month',
                          value: summary.monthlyTrend.isNotEmpty
                              ? '${summary.monthlyTrend.last.avgRating.toStringAsFixed(1)}★'
                              : 'N/A',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.white.withValues(alpha: 0.7)),
        const SizedBox(width: 6),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                value,
                style: AppTypography.titleSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================
// AC2: STAR DISTRIBUTION CHART
// ============================================

/// Horizontal bar chart showing star distribution
class StarDistributionChart extends StatelessWidget {
  final StarBreakdown breakdown;

  const StarDistributionChart({
    super.key,
    required this.breakdown,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart_rounded, color: colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Rating Distribution',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Star bars
            _StarBar(stars: 5, count: breakdown.star5, percentage: breakdown.percentage(5)),
            _StarBar(stars: 4, count: breakdown.star4, percentage: breakdown.percentage(4)),
            _StarBar(stars: 3, count: breakdown.star3, percentage: breakdown.percentage(3)),
            _StarBar(stars: 2, count: breakdown.star2, percentage: breakdown.percentage(2)),
            _StarBar(stars: 1, count: breakdown.star1, percentage: breakdown.percentage(1)),
          ],
        ),
      ),
    );
  }
}

class _StarBar extends StatelessWidget {
  final int stars;
  final int count;
  final double percentage;

  const _StarBar({
    required this.stars,
    required this.count,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Star label
          SizedBox(
            width: 24,
            child: Row(
              children: [
                Text(
                  '$stars',
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(Icons.star, size: 12, color: AppColors.starFilled),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Progress bar
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  stars >= 4 ? AppColors.secondary : 
                  stars == 3 ? Colors.orange : AppColors.error,
                ),
                minHeight: 10,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Percentage
          SizedBox(
            width: 48,
            child: Text(
              '${percentage.toStringAsFixed(0)}%',
              style: AppTypography.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// AC6: RATING TREND CHART
// ============================================

/// Simple trend display (simplified from fl_chart for now)
class RatingTrendChart extends StatelessWidget {
  final List<TrendItem> trend;

  const RatingTrendChart({
    super.key,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (trend.isEmpty) return const SizedBox.shrink();

    // Calculate improvement
    double improvement = 0;
    if (trend.length >= 2) {
      improvement = trend.last.avgRating - trend[trend.length - 2].avgRating;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart_rounded, color: colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Monthly Trend',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (improvement != 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: improvement > 0
                          ? AppColors.secondary.withValues(alpha: 0.15)
                          : AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          improvement > 0
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 14,
                          color: improvement > 0
                              ? AppColors.secondary
                              : AppColors.error,
                        ),
                        Text(
                          '${improvement.abs().toStringAsFixed(1)}',
                          style: AppTypography.labelSmall.copyWith(
                            color: improvement > 0
                                ? AppColors.secondary
                                : AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Simple bar visualization - increased height to prevent overflow
            SizedBox(
              height: 100, // Increased from 80
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: trend.map((item) {
                  final height = (item.avgRating / 5.0) * 50; // Reduced max bar height
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2), // Reduced padding
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              item.avgRating.toStringAsFixed(1),
                              style: AppTypography.labelSmall.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            height: height,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              item.formattedMonth,
                              style: AppTypography.labelSmall.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// AC3: RATING LIST ITEM CARD
// ============================================

/// Individual rating card for list view
class RatingListItemCard extends StatelessWidget {
  final RatingListItem rating;
  final VoidCallback? onTap;

  const RatingListItemCard({
    super.key,
    required this.rating,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: onTap != null,
      label: rating.semanticLabel,
      child: Card(
        elevation: rating.seenByFarmer ? 1 : 3,
        shadowColor: rating.seenByFarmer
            ? null
            : AppColors.accent.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: rating.seenByFarmer
              ? BorderSide.none
              : BorderSide(color: AppColors.accent.withValues(alpha: 0.3), width: 1),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Crop icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      rating.cropIcon,
                      style: const TextStyle(fontSize: 24),
                      semanticsLabel: rating.cropType,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${rating.formattedQuantity} ${rating.cropType}',
                              style: AppTypography.titleSmall.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!rating.seenByFarmer)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'NEW',
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        rating.formattedDate,
                        style: AppTypography.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (rating.truncatedComment.isNotEmpty)
                        Text(
                          rating.truncatedComment,
                          style: AppTypography.bodySmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),

                // Stars and chevron
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rating.rating
                              ? Icons.star
                              : Icons.star_outline,
                          size: 16,
                          color: index < rating.rating
                              ? AppColors.starFilled
                              : colorScheme.outline,
                        );
                      }),
                    ),
                    if (rating.hasIssues)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 12,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${rating.qualityIssues.length} issue${rating.qualityIssues.length > 1 ? 's' : ''}',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 4),
                Flexible(
                  flex: 0,
                  child: Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
// AC4: QUALITY ISSUE CARD
// ============================================

/// Quality issue display with icon
class QualityIssueCard extends StatelessWidget {
  final QualityIssue issue;

  const QualityIssueCard({
    super.key,
    required this.issue,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Text(
            issue.icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              issue.label,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 20,
          ),
        ],
      ),
    );
  }
}

// ============================================
// AC5: RECOMMENDATION CARD
// ============================================

/// Improvement recommendation with tutorial link
class RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;
  final VoidCallback? onTutorialTap;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    this.onTutorialTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tips_and_updates_outlined,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    recommendation.title,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              recommendation.recommendation,
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (onTutorialTap != null) ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 48, // 48dp touch target
                child: OutlinedButton.icon(
                  onPressed: onTutorialTap,
                  icon: const Icon(Icons.play_circle_outline, size: 20),
                  label: const Text('Watch Tutorial'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================
// AC7: RATINGS IMPACT CARD
// ============================================

/// Explains how ratings affect farmer
class RatingsImpactCard extends StatelessWidget {
  const RatingsImpactCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 1,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Why Ratings Matter',
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _ImpactItem(
              icon: Icons.priority_high_rounded,
              text: 'Higher ratings = priority in buyer matching',
            ),
            const SizedBox(height: AppSpacing.sm),
            _ImpactItem(
              icon: Icons.visibility,
              text: 'Your rating is shown to buyers',
            ),
            const SizedBox(height: AppSpacing.sm),
            _ImpactItem(
              icon: Icons.handshake_outlined,
              text: 'Consistent quality builds trust',
            ),
          ],
        ),
      ),
    );
  }
}

class _ImpactItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ImpactItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: colorScheme.primary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
