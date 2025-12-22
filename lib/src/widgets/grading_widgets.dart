import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../models/grading_models.dart';

/// Grading Widgets - Story 3.3
/// 
/// Reusable components for AI quality grading display:
/// - GradeBadge: Large color-coded grade indicator (A/B/C)
/// - QualityIndicatorChip: Individual quality score chip
/// - PriceBreakdownCard: DPLE price line-item display
/// - AnimatedPrice: Counting-up price animation

// ============================================================================
// Grade Badge - Large central grade display (AC1)
// ============================================================================

class GradeBadge extends StatelessWidget {
  final QualityGrade grade;
  final double size;

  const GradeBadge({
    super.key,
    required this.grade,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getGradeColor(grade),
            _getGradeColor(grade).withValues(alpha: 0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _getGradeColor(grade).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            grade.name,
            style: TextStyle(
              fontSize: size * 0.45,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'GRADE',
            style: TextStyle(
              fontSize: size * 0.12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Color _getGradeColor(QualityGrade grade) {
    switch (grade) {
      case QualityGrade.A:
        return AppColors.secondary; // Green
      case QualityGrade.B:
        return const Color(0xFFFFC107); // Yellow/Amber
      case QualityGrade.C:
        return AppColors.primary; // Orange
    }
  }
}

// ============================================================================
// Quality Indicator Chip - Individual quality factor display (AC2)
// ============================================================================

class QualityIndicatorChip extends StatelessWidget {
  final QualityIndicator indicator;
  final bool isDark;

  const QualityIndicatorChip({
    super.key,
    required this.indicator,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final isGood = indicator.score >= 0.7;
    final color = isGood ? AppColors.secondary : AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(indicator.type),
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            indicator.type.label,
            style: AppTypography.labelMedium.copyWith(
              color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              indicator.label,
              style: AppTypography.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(QualityIndicatorType type) {
    switch (type) {
      case QualityIndicatorType.freshness:
        return Icons.spa;
      case QualityIndicatorType.colorVibrancy:
        return Icons.palette;
      case QualityIndicatorType.sizeConsistency:
        return Icons.straighten;
      case QualityIndicatorType.surfaceQuality:
        return Icons.texture;
      case QualityIndicatorType.ripeness:
        return Icons.eco;
    }
  }
}

// ============================================================================
// Price Breakdown Card - DPLE pricing display (AC3, AC4)
// ============================================================================

class PriceBreakdownCard extends StatefulWidget {
  final PriceBreakdown priceBreakdown;
  final String cropType;
  final QualityGrade grade;
  final bool isDark;

  const PriceBreakdownCard({
    super.key,
    required this.priceBreakdown,
    required this.cropType,
    required this.grade,
    this.isDark = false,
  });

  @override
  State<PriceBreakdownCard> createState() => _PriceBreakdownCardState();
}

class _PriceBreakdownCardState extends State<PriceBreakdownCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _countAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _countAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pb = widget.priceBreakdown;
    
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkSurfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.secondary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.currency_rupee,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price Breakdown',
                        style: AppTypography.titleSmall.copyWith(
                          color: widget.isDark 
                              ? AppColors.darkOnSurface 
                              : AppColors.onSurface,
                        ),
                      ),
                      Text(
                        '${widget.cropType} • ${pb.quantityKg.toStringAsFixed(0)} kg',
                        style: AppTypography.bodySmall.copyWith(
                          color: widget.isDark 
                              ? AppColors.darkOnSurfaceVariant 
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Line items
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                _buildLineItem(
                  label: 'Market rate',
                  value: '₹${pb.marketRatePerKg.toStringAsFixed(0)}/kg',
                  isDark: widget.isDark,
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildLineItem(
                  label: 'Your grade: ${widget.grade.label}',
                  value: pb.gradeAdjustment,
                  valueColor: _getGradeColor(widget.grade),
                  isDark: widget.isDark,
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Divider(),
                ),
                
                _buildLineItem(
                  label: 'Your price',
                  value: '₹${pb.finalPricePerKg.toStringAsFixed(0)}/kg',
                  isLarge: true,
                  isDark: widget.isDark,
                ),
              ],
            ),
          ),
          
          // Total earnings - Big highlight (AC4)
          Container(
            margin: const EdgeInsets.fromLTRB(
              AppSpacing.md, 0, AppSpacing.md, AppSpacing.md,
            ),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: AppColors.successGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Estimated Earnings',
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedBuilder(
                  animation: _countAnimation,
                  builder: (context, child) {
                    final value = pb.totalEarnings * _countAnimation.value;
                    return Text(
                      '₹${value.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.verified,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      pb.paymentTerms,
                      style: AppTypography.labelMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineItem({
    required String label,
    required String value,
    Color? valueColor,
    bool isLarge = false,
    bool isDark = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isLarge
              ? AppTypography.titleSmall.copyWith(
                  color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                )
              : AppTypography.bodyMedium.copyWith(
                  color: isDark 
                      ? AppColors.darkOnSurfaceVariant 
                      : AppColors.onSurfaceVariant,
                ),
        ),
        Text(
          value,
          style: isLarge
              ? AppTypography.titleMedium.copyWith(
                  color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                )
              : AppTypography.labelLarge.copyWith(
                  color: valueColor ?? 
                      (isDark ? AppColors.darkOnSurface : AppColors.onSurface),
                ),
        ),
      ],
    );
  }

  Color _getGradeColor(QualityGrade grade) {
    switch (grade) {
      case QualityGrade.A:
        return AppColors.secondary;
      case QualityGrade.B:
        return const Color(0xFFFFC107);
      case QualityGrade.C:
        return AppColors.primary;
    }
  }
}

// ============================================================================
// Animated Price Counter
// ============================================================================

class AnimatedPrice extends StatefulWidget {
  final double value;
  final String prefix;
  final TextStyle? style;
  final Duration duration;

  const AnimatedPrice({
    super.key,
    required this.value,
    this.prefix = '₹',
    this.style,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<AnimatedPrice> createState() => _AnimatedPriceState();
}

class _AnimatedPriceState extends State<AnimatedPrice>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedPrice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _animation = Tween<double>(
        begin: _previousValue,
        end: widget.value,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${widget.prefix}${_animation.value.toStringAsFixed(0)}',
          style: widget.style,
        );
      },
    );
  }
}

// ============================================================================
// Grade Color Helper Mixin
// ============================================================================

mixin GradeColorMixin {
  Color getGradeColor(QualityGrade grade) {
    switch (grade) {
      case QualityGrade.A:
        return AppColors.secondary; // Green
      case QualityGrade.B:
        return const Color(0xFFFFC107); // Yellow/Amber
      case QualityGrade.C:
        return AppColors.primary; // Orange
    }
  }
}

// ============================================================================
// Success Tick Animation (for accept confirmation)
// ============================================================================

class SuccessTickAnimation extends StatefulWidget {
  final double size;
  final Color color;
  final VoidCallback? onComplete;

  const SuccessTickAnimation({
    super.key,
    this.size = 80,
    this.color = const Color(0xFF2E7D32),
    this.onComplete,
  });

  @override
  State<SuccessTickAnimation> createState() => _SuccessTickAnimationState();
}

class _SuccessTickAnimationState extends State<SuccessTickAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _tickAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    );

    _tickAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    );

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: AnimatedBuilder(
          animation: _tickAnimation,
          builder: (context, child) {
            return CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _TickPainter(
                progress: _tickAnimation.value,
                color: widget.color,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TickPainter extends CustomPainter {
  final double progress;
  final Color color;

  _TickPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;

    // Define tick points
    final start = Offset(center.dx - radius * 0.5, center.dy);
    final middle = Offset(center.dx - radius * 0.1, center.dy + radius * 0.4);
    final end = Offset(center.dx + radius * 0.6, center.dy - radius * 0.3);

    final path = Path();

    if (progress <= 0.5) {
      // First stroke (start to middle)
      final t = progress * 2;
      final currentPoint = Offset(
        start.dx + (middle.dx - start.dx) * t,
        start.dy + (middle.dy - start.dy) * t,
      );
      path.moveTo(start.dx, start.dy);
      path.lineTo(currentPoint.dx, currentPoint.dy);
    } else {
      // First stroke complete, draw second stroke
      path.moveTo(start.dx, start.dy);
      path.lineTo(middle.dx, middle.dy);

      final t = (progress - 0.5) * 2;
      final currentPoint = Offset(
        middle.dx + (end.dx - middle.dx) * t,
        middle.dy + (end.dy - middle.dy) * t,
      );
      path.lineTo(currentPoint.dx, currentPoint.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TickPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
