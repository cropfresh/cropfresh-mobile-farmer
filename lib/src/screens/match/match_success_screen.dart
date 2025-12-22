import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_typography.dart';
import '../../models/match_models.dart';

/// Match Success Screen - Story 3.5 (AC: 3)
/// 
/// Shows success confirmation after accepting a match.
/// Displays drop point reminder and navigation options.
class MatchSuccessScreen extends StatefulWidget {
  final Match match;
  final Map<String, dynamic>? dropPoint;
  final String? successMessage;
  final VoidCallback? onViewOrder;
  final VoidCallback? onBackToDashboard;

  const MatchSuccessScreen({
    super.key,
    required this.match,
    this.dropPoint,
    this.successMessage,
    this.onViewOrder,
    this.onBackToDashboard,
  });

  @override
  State<MatchSuccessScreen> createState() => _MatchSuccessScreenState();
}

class _MatchSuccessScreenState extends State<MatchSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Setup success animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Start animation
    _animationController.forward();

    // Auto-navigate to dashboard after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && widget.onBackToDashboard != null) {
        widget.onBackToDashboard!();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Animated success icon
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: AppColors.successGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Success heading
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Match Accepted!',
                  style: AppTypography.headlineLarge.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Success message
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  widget.successMessage ?? 
                      'Deliver to the drop point by the scheduled time.',
                  style: AppTypography.bodyLarge.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Order summary card
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildSummaryCard(colorScheme),
              ),

              const Spacer(),

              // Action buttons
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: AppSpacing.recommendedTouchTarget,
                      child: FilledButton(
                        onPressed: widget.onViewOrder,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                        ),
                        child: const Text('View Order Details'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      height: AppSpacing.recommendedTouchTarget,
                      child: OutlinedButton(
                        onPressed: widget.onBackToDashboard,
                        child: const Text('Back to Dashboard'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
      ),
      child: Column(
        children: [
          // Crop info
          Row(
            children: [
              Text(
                widget.match.listing.cropEmoji,
                style: const TextStyle(fontSize: 40),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.match.formattedQuantity} ${widget.match.listing.cropType}',
                      style: AppTypography.titleMedium.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Sold to ${widget.match.buyer.businessType}',
                      style: AppTypography.bodyMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                widget.match.formattedTotal,
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Drop point info if available
          if (widget.dropPoint != null) ...[
            const SizedBox(height: AppSpacing.md),
            Divider(color: colorScheme.outlineVariant),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Drop Point',
                        style: AppTypography.labelMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        widget.dropPoint!['name'] as String? ?? 'Assigned',
                        style: AppTypography.bodyMedium.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
