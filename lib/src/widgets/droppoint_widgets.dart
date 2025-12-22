import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../models/droppoint_models.dart';

/// Drop Point Widgets - Story 3.4 (AC: 1, 3, 5)
/// 
/// Reusable UI components for drop point assignment screens:
/// - DropPointCard: Main card showing location details (AC1)
/// - DistanceBadge: Shows distance from farmer (AC1)
/// - CrateIndicator: Visual crate count (AC1)
/// - CountdownTimer: Time until drop-off (AC5)
/// - DeliveryCard: Compact card for dashboard (AC5)

/// Distance badge showing km from farmer (AC1)
class DistanceBadge extends StatelessWidget {
  final double distanceKm;
  final bool isDark;

  const DistanceBadge({
    super.key,
    required this.distanceKm,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.near_me,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            '${distanceKm.toStringAsFixed(1)} km',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Crate indicator showing required crates (AC1)
class CrateIndicator extends StatelessWidget {
  final int cratesNeeded;
  final double quantityKg;
  final bool isDark;

  const CrateIndicator({
    super.key,
    required this.cratesNeeded,
    required this.quantityKg,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.darkSurfaceContainer 
            : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkOutlineVariant : AppColors.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          // Crate icon stack
          Stack(
            children: List.generate(
              cratesNeeded.clamp(1, 3),
              (index) => Transform.translate(
                offset: Offset(index * 8.0, 0),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.secondary,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: 18,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md + (cratesNeeded.clamp(1, 3) * 8.0)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bring $cratesNeeded crate${cratesNeeded > 1 ? 's' : ''}',
                  style: AppTypography.titleSmall.copyWith(
                    color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                  ),
                ),
                Text(
                  'For ${quantityKg.toStringAsFixed(0)}kg produce',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Countdown timer until drop-off (AC5)
class CountdownTimerWidget extends StatelessWidget {
  final PickupWindow pickupWindow;
  final bool isDark;

  const CountdownTimerWidget({
    super.key,
    required this.pickupWindow,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final countdown = pickupWindow.countdownText;
    final isUrgent = pickupWindow.timeUntilStart.inHours < 4;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: isUrgent
            ? LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
              )
            : LinearGradient(
                colors: [
                  AppColors.secondary.withValues(alpha: 0.15),
                  AppColors.secondary.withValues(alpha: 0.05),
                ],
              ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: 18,
            color: isUrgent ? AppColors.primary : AppColors.secondary,
          ),
          const SizedBox(width: 8),
          Text(
            '$countdown until drop-off',
            style: AppTypography.labelLarge.copyWith(
              color: isUrgent ? AppColors.primary : AppColors.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Main drop point card (AC1)
class DropPointCard extends StatelessWidget {
  final DropPoint dropPoint;
  final PickupWindow pickupWindow;
  final int cratesNeeded;
  final double quantityKg;
  final bool showDirections;
  final VoidCallback? onGetDirections;
  final bool isDark;

  const DropPointCard({
    super.key,
    required this.dropPoint,
    required this.pickupWindow,
    required this.cratesNeeded,
    required this.quantityKg,
    this.showDirections = true,
    this.onGetDirections,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with name and distance
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.store,
                  color: AppColors.secondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dropPoint.name,
                      style: AppTypography.titleMedium.copyWith(
                        color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    DistanceBadge(
                      distanceKm: dropPoint.distanceKm,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on,
                size: 18,
                color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  dropPoint.address,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Time window
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  pickupWindow.formattedDate,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 1,
                  height: 16,
                  color: AppColors.secondary.withValues(alpha: 0.3),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.access_time,
                  size: 18,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  pickupWindow.formattedWindow,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          if (showDirections) ...[
            const SizedBox(height: AppSpacing.md),

            // Get Directions button
            SizedBox(
              width: double.infinity,
              height: AppSpacing.recommendedTouchTarget,
              child: OutlinedButton.icon(
                onPressed: onGetDirections,
                icon: const Icon(Icons.directions),
                label: const Text('Get Directions'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Compact delivery card for dashboard (AC5)
class DeliveryCard extends StatelessWidget {
  final UpcomingDelivery delivery;
  final VoidCallback? onTap;
  final bool isDark;

  const DeliveryCard({
    super.key,
    required this.delivery,
    this.onTap,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.darkSurfaceContainer : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkOutlineVariant : AppColors.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              // Crop emoji
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  delivery.cropEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${delivery.quantityKg.toStringAsFixed(0)}kg ${delivery.cropName}',
                      style: AppTypography.titleSmall.copyWith(
                        color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      delivery.assignment.dropPoint.name,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Time/countdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    delivery.assignment.pickupWindow.formattedDate,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    delivery.assignment.pickupWindow.formattedWindow,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.chevron_right,
                color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
