import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_typography.dart';
import '../../models/droppoint_models.dart';
import '../../widgets/droppoint_widgets.dart';

/// UpcomingDeliveriesWidget - Story 3.4 (AC: 5)
/// 
/// Dashboard widget showing farmer's upcoming deliveries:
/// - Today/tomorrow deliveries with countdown (AC5)
/// - Tap to view full assignment details (AC5)
/// - Empty state when no deliveries pending
/// 
/// Material Design 3 with smooth animations
class UpcomingDeliveriesWidget extends StatefulWidget {
  final VoidCallback? onViewAll;
  
  const UpcomingDeliveriesWidget({
    super.key,
    this.onViewAll,
  });

  @override
  State<UpcomingDeliveriesWidget> createState() => _UpcomingDeliveriesWidgetState();
}

class _UpcomingDeliveriesWidgetState extends State<UpcomingDeliveriesWidget> {
  List<UpcomingDelivery> _deliveries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeliveries();
  }

  Future<void> _loadDeliveries() async {
    // Simulate API call (Phase 2 will call actual API)
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        // Mock data - in production, fetch from API
        _deliveries = [
          UpcomingDelivery.mock(),
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return _buildLoadingState(isDark);
    }

    if (_deliveries.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return _buildContent(isDark);
  }

  Widget _buildLoadingState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDark),
          const SizedBox(height: AppSpacing.md),
          // Shimmer placeholder
          Container(
            height: 72,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceContainerHigh : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDark),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_shipping_outlined,
                    size: 32,
                    color: AppColors.secondary.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No upcoming deliveries',
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/create-listing');
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Create a listing'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDark),
          const SizedBox(height: AppSpacing.md),
          
          // Delivery cards
          ...List.generate(_deliveries.length, (index) {
            final delivery = _deliveries[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < _deliveries.length - 1 ? AppSpacing.sm : 0,
              ),
              child: DeliveryCard(
                delivery: delivery,
                isDark: isDark,
                onTap: () => _openDeliveryDetails(delivery),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.schedule,
              size: 20,
              color: AppColors.secondary,
            ),
            const SizedBox(width: 8),
            Text(
              'Upcoming Deliveries',
              style: AppTypography.titleSmall.copyWith(
                color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
              ),
            ),
          ],
        ),
        if (_deliveries.isNotEmpty && widget.onViewAll != null)
          TextButton(
            onPressed: widget.onViewAll,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
            ),
            child: Text(
              'View All',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }

  void _openDeliveryDetails(UpcomingDelivery delivery) {
    Navigator.pushNamed(
      context,
      '/drop-point',
      arguments: {
        'listingId': delivery.assignment.listingId,
        'cropType': delivery.cropName,
        'cropEmoji': delivery.cropEmoji,
        'quantity': delivery.quantityKg,
      },
    );
  }
}

/// Compact reminder banner for dashboard (AC5)
class DeliveryReminderBanner extends StatelessWidget {
  final UpcomingDelivery delivery;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const DeliveryReminderBanner({
    super.key,
    required this.delivery,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUrgent = delivery.assignment.pickupWindow.timeUntilStart.inHours < 4;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isUrgent
              ? [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.9),
                ]
              : [
                  AppColors.secondary,
                  AppColors.secondary.withValues(alpha: 0.9),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isUrgent ? AppColors.primary : AppColors.secondary).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isUrgent ? Icons.alarm : Icons.local_shipping,
                    color: Colors.white,
                    size: 24,
                  ),
                ),

                const SizedBox(width: AppSpacing.md),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isUrgent ? 'Delivery Soon!' : 'Upcoming Delivery',
                        style: AppTypography.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${delivery.quantityKg.toStringAsFixed(0)}kg ${delivery.cropName} • ${delivery.assignment.pickupWindow.formattedDate} ${delivery.assignment.pickupWindow.formattedWindow}',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                // Dismiss button
                if (onDismiss != null)
                  IconButton(
                    onPressed: onDismiss,
                    icon: Icon(
                      Icons.close,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    iconSize: 20,
                    constraints: const BoxConstraints(
                      minWidth: AppSpacing.minTouchTarget,
                      minHeight: AppSpacing.minTouchTarget,
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
