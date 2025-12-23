import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../models/order_models.dart';

/// Order Widgets - Story 3.6 (AC: 1, 5, 6)
/// 
/// Reusable UI components for order tracking screens:
/// - OrderBadge: Badge for active order count (AC5)
/// - StatusBadge: Visual status indicator (AC1)
/// - OrderCard: Summary card for order list (AC5)
/// - StatusTimeline: 7-stage progress timeline (AC1)
/// - TimelineStepCard: Individual timeline step with details (AC1)
/// - HaulerContactCard: Contact info for in-transit orders (AC3)
/// - DelayIndicator: ETA delay banner (AC4)
/// - EmptyOrdersState: No orders placeholder (AC5)

/// Badge showing active order count (AC5)
class OrderBadge extends StatelessWidget {
  final int count;
  final double size;

  const OrderBadge({
    super.key,
    required this.count,
    this.size = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.error,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          count > 9 ? '9+' : count.toString(),
          style: AppTypography.labelSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Status badge with color and icon (AC1)
class StatusBadge extends StatelessWidget {
  final OrderStatus status;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Determine colors based on status
    Color bgColor;
    Color textColor;
    IconData icon;
    
    switch (status) {
      case OrderStatus.listed:
      case OrderStatus.matched:
      case OrderStatus.pickupScheduled:
      case OrderStatus.atDropPoint:
        bgColor = colorScheme.primaryContainer;
        textColor = colorScheme.onPrimaryContainer;
        icon = Icons.pending_outlined;
        break;
      case OrderStatus.inTransit:
        bgColor = colorScheme.secondaryContainer;
        textColor = colorScheme.onSecondaryContainer;
        icon = Icons.local_shipping_outlined;
        break;
      case OrderStatus.delivered:
      case OrderStatus.paid:
        bgColor = AppColors.secondaryContainer;
        textColor = AppColors.onSecondaryContainer;
        icon = Icons.check_circle_outline;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.xs : AppSpacing.md,
        vertical: compact ? AppSpacing.xxs : AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 14 : 18, color: textColor),
          SizedBox(width: compact ? 4 : AppSpacing.xs),
          Text(
            status.label,
            style: (compact ? AppTypography.labelSmall : AppTypography.labelMedium)
                .copyWith(color: textColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Summary card for order list (AC5)
class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: 'Order for ${order.listing.cropType}, ${order.formattedTotal}. '
             'Status: ${order.status.label}. '
             'Buyer: ${order.buyer.displayName}. '
             'Tap to view details.',
      child: Card(
        elevation: 4,
        shadowColor: AppColors.primary.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: Crop + Status badge
                  Row(
                    children: [
                      // Crop emoji in container
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            order.listing.cropEmoji,
                            style: const TextStyle(fontSize: 24),
                            semanticsLabel: order.listing.cropType,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // Crop info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${order.listing.formattedQuantity} ${order.listing.cropType}',
                              style: AppTypography.titleMedium.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              order.buyer.displayName,
                              style: AppTypography.bodySmall.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Status badge
                      StatusBadge(status: order.status, compact: true),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: order.progress,
                      minHeight: 6,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        order.isCompleted 
                            ? AppColors.secondary 
                            : colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Bottom row: Step info + Price
                  Row(
                    children: [
                      // Step indicator
                      Icon(
                        Icons.timeline_outlined,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Step ${order.currentStep} of ${order.totalSteps}',
                        style: AppTypography.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (order.hasDelay) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            order.delayDisplay!,
                            style: AppTypography.labelSmall.copyWith(
                              color: colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      // Price with gradient background
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: order.isCompleted 
                              ? AppColors.successGradient 
                              : AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          order.formattedTotal,
                          style: AppTypography.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 7-stage status timeline with animated progress (AC1)
class StatusTimeline extends StatelessWidget {
  final List<TimelineEvent> events;
  final OrderStatus currentStatus;
  final VoidCallback? onStepTap;

  const StatusTimeline({
    super.key,
    required this.events,
    required this.currentStatus,
    this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: List.generate(events.length, (index) {
        final event = events[index];
        final isLast = index == events.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator column
            SizedBox(
              width: 32,
              child: Column(
                children: [
                  // Circle indicator
                  _TimelineCircle(
                    completed: event.completed,
                    active: event.active,
                  ),
                  // Connecting line (except last)
                  if (!isLast)
                    Container(
                      width: 3,
                      height: 48,
                      decoration: BoxDecoration(
                        color: event.completed
                            ? AppColors.secondary
                            : colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Event content
            Expanded(
              child: TimelineStepCard(
                event: event,
                isActive: event.active,
                onTap: onStepTap,
              ),
            ),
          ],
        );
      }),
    );
  }
}

/// Circle indicator for timeline step
class _TimelineCircle extends StatelessWidget {
  final bool completed;
  final bool active;

  const _TimelineCircle({
    required this.completed,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (completed) {
      // Green checkmark
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.secondary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.check,
          color: Colors.white,
          size: 18,
        ),
      );
    } else if (active) {
      // Animated pulsing primary color
      return TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.8, end: 1.2),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4 * value),
                  blurRadius: 8 * value,
                  spreadRadius: 2 * (value - 0.8),
                ),
              ],
            ),
            child: const Icon(
              Icons.radio_button_checked,
              color: Colors.white,
              size: 16,
            ),
          );
        },
      );
    } else {
      // Grey pending circle
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
          border: Border.all(
            color: colorScheme.outlineVariant,
            width: 2,
          ),
        ),
      );
    }
  }
}

/// Individual timeline step card (AC1, AC3)
class TimelineStepCard extends StatelessWidget {
  final TimelineEvent event;
  final bool isActive;
  final VoidCallback? onTap;

  const TimelineStepCard({
    super.key,
    required this.event,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: onTap != null,
      label: '${event.label}. ${event.completed ? "Completed" : (isActive ? "In progress" : "Pending")}. '
             '${event.formattedTimestamp ?? ""}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          decoration: BoxDecoration(
            color: isActive 
                ? colorScheme.primaryContainer.withValues(alpha: 0.5)
                : (event.completed 
                    ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
            border: isActive 
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          child: Row(
            children: [
              // Status icon
              Icon(
                _getStatusIcon(event.status),
                color: event.completed 
                    ? AppColors.secondary
                    : (isActive ? AppColors.primary : colorScheme.onSurfaceVariant),
                size: 24,
                semanticLabel: event.status.label,
              ),
              const SizedBox(width: AppSpacing.md),
              // Label and timestamp
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.label,
                      style: AppTypography.titleSmall.copyWith(
                        color: event.completed || isActive
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
                    if (event.formattedTimestamp != null)
                      Text(
                        event.formattedTimestamp!,
                        style: AppTypography.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    if (event.note != null)
                      Text(
                        event.note!,
                        style: AppTypography.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              // Chevron for tappable items
              if (onTap != null && (event.completed || isActive))
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.listed:
        return Icons.inventory_2_outlined;
      case OrderStatus.matched:
        return Icons.handshake_outlined;
      case OrderStatus.pickupScheduled:
        return Icons.schedule_outlined;
      case OrderStatus.atDropPoint:
        return Icons.location_on_outlined;
      case OrderStatus.inTransit:
        return Icons.local_shipping_outlined;
      case OrderStatus.delivered:
        return Icons.check_circle_outline;
      case OrderStatus.paid:
        return Icons.payments_outlined;
    }
  }
}

/// Hauler contact card for in-transit orders (AC3)
class HaulerContactCard extends StatelessWidget {
  final Hauler hauler;
  final DateTime? eta;
  final VoidCallback? onCall;

  const HaulerContactCard({
    super.key,
    required this.hauler,
    this.eta,
    this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: AppSpacing.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
          gradient: LinearGradient(
            colors: [
              colorScheme.secondaryContainer,
              colorScheme.secondaryContainer.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.local_shipping,
                    color: colorScheme.onSecondaryContainer,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Hauler Details',
                    style: AppTypography.labelMedium.copyWith(
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              
              // Hauler info row
              Row(
                children: [
                  // Avatar
                  Container(
                    width: AppSpacing.minTouchTarget,
                    height: AppSpacing.minTouchTarget,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Name and vehicle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hauler.name,
                          style: AppTypography.titleMedium.copyWith(
                            color: colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          hauler.vehicleDisplay,
                          style: AppTypography.bodyMedium.copyWith(
                            color: colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Call button
                  SizedBox(
                    width: AppSpacing.recommendedTouchTarget,
                    height: AppSpacing.recommendedTouchTarget,
                    child: FilledButton(
                      onPressed: onCall,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.sm),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Icon(Icons.call, color: Colors.white),
                    ),
                  ),
                ],
              ),
              
              // ETA if available
              if (eta != null) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppSpacing.xs),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 18,
                        color: colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'ETA: ${_formatEta(eta!)}',
                        style: AppTypography.labelLarge.copyWith(
                          color: colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatEta(DateTime dt) {
    final now = DateTime.now();
    String dayPrefix;
    if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
      dayPrefix = 'Today';
    } else if (dt.day == now.day + 1) {
      dayPrefix = 'Tomorrow';
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      dayPrefix = '${months[dt.month - 1]} ${dt.day}';
    }
    
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$dayPrefix $hour:${dt.minute.toString().padLeft(2, '0')} $amPm';
  }
}

/// Delay indicator banner (AC4)
class DelayIndicator extends StatelessWidget {
  final int delayMinutes;
  final String? reason;
  final DateTime? updatedEta;

  const DelayIndicator({
    super.key,
    required this.delayMinutes,
    this.reason,
    this.updatedEta,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: colorScheme.onErrorContainer,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delayed by $delayMinutes min',
                  style: AppTypography.titleSmall.copyWith(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (reason != null)
                  Text(
                    reason!,
                    style: AppTypography.bodySmall.copyWith(
                      color: colorScheme.onErrorContainer.withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
          ),
          if (updatedEta != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppSpacing.xs),
              ),
              child: Text(
                'New ETA',
                style: AppTypography.labelSmall.copyWith(
                  color: colorScheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Empty state for orders list (AC5)
class EmptyOrdersState extends StatelessWidget {
  final OrderFilter filter;
  final VoidCallback? onRefresh;

  const EmptyOrdersState({
    super.key,
    required this.filter,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    String title;
    String description;
    IconData icon;

    switch (filter) {
      case OrderFilter.active:
        title = 'No active orders';
        description = 'When your listings are matched and orders are placed, they\'ll appear here.';
        icon = Icons.local_shipping_outlined;
        break;
      case OrderFilter.completed:
        title = 'No completed orders';
        description = 'Your completed orders will be shown here for 90 days.';
        icon = Icons.check_circle_outline;
        break;
      case OrderFilter.all:
        title = 'No orders yet';
        description = 'Create a listing and wait for a buyer match to start receiving orders.';
        icon = Icons.inventory_2_outlined;
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 80,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTypography.titleLarge.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (onRefresh != null) ...[
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// ETA countdown timer with live updates (reused from match_widgets pattern)
class EtaCountdownTimer extends StatefulWidget {
  final DateTime eta;
  final bool hasDelay;

  const EtaCountdownTimer({
    super.key,
    required this.eta,
    this.hasDelay = false,
  });

  @override
  State<EtaCountdownTimer> createState() => _EtaCountdownTimerState();
}

class _EtaCountdownTimerState extends State<EtaCountdownTimer> {
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.eta.difference(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isOverdue = _remaining.isNegative;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isOverdue || widget.hasDelay
            ? colorScheme.errorContainer
            : colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOverdue ? Icons.timer_off : Icons.timer_outlined,
            size: 18,
            color: isOverdue || widget.hasDelay
                ? colorScheme.onErrorContainer
                : colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            isOverdue ? 'Overdue' : _formatRemaining(_remaining),
            style: AppTypography.labelLarge.copyWith(
              color: isOverdue || widget.hasDelay
                  ? colorScheme.onErrorContainer
                  : colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatRemaining(Duration d) {
    if (d.isNegative) return 'Overdue';
    
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    
    if (hours > 0) {
      return 'ETA: ${hours}h ${minutes}m';
    }
    return 'ETA: ${minutes}m';
  }
}
