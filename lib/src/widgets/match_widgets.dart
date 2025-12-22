import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../models/match_models.dart';
import 'match_notification_widgets.dart';

/// Match Widgets - Story 3.5 (AC: 2, 6)
/// 
/// Reusable UI components for buyer match screens:
/// - BuyerInfoCard: Displays buyer business type and location (AC2)
/// - QuantityCard: Shows requested quantity with partial indicator (AC2)
/// - PriceCard: Total earnings display with gradient (AC2)
/// - MatchExpiryTimer: Countdown until match expires (AC2)
/// - MatchCard: Summary card for match list (AC6)
/// - MatchBadge: Badge indicator for pending match count (AC6)

/// Badge showing pending match count (AC6)
class MatchBadge extends StatelessWidget {
  final int count;
  final double size;

  const MatchBadge({
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
      decoration: BoxDecoration(
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

/// Buyer information card (AC2)
class BuyerInfoCard extends StatelessWidget {
  final Buyer buyer;
  final String? deliveryDate;
  final VoidCallback? onTap;

  const BuyerInfoCard({
    super.key,
    required this.buyer,
    this.deliveryDate,
    this.onTap,
  });

  IconData _getBusinessIcon() {
    final type = buyer.businessType.toLowerCase();
    if (type.contains('restaurant')) return Icons.restaurant;
    if (type.contains('hotel')) return Icons.hotel;
    if (type.contains('retail')) return Icons.store;
    if (type.contains('wholesale')) return Icons.warehouse;
    return Icons.business;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: AppSpacing.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section title
              Text(
                'Buyer Details',
                style: AppTypography.labelMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              
              // Business type with icon
              Row(
                children: [
                  Container(
                    width: AppSpacing.minTouchTarget,
                    height: AppSpacing.minTouchTarget,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                    child: Icon(
                      _getBusinessIcon(),
                      color: colorScheme.onPrimaryContainer,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          buyer.displayName,
                          style: AppTypography.titleMedium.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        if (deliveryDate != null)
                          Text(
                            'Delivery: $deliveryDate',
                            style: AppTypography.bodyMedium.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quantity display card with partial match indicator (AC2, AC5)
class QuantityCard extends StatelessWidget {
  final double quantityRequested;
  final double listingQuantity;
  final String cropEmoji;
  final String cropName;

  const QuantityCard({
    super.key,
    required this.quantityRequested,
    required this.listingQuantity,
    required this.cropEmoji,
    required this.cropName,
  });

  bool get isPartial => quantityRequested < listingQuantity;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = quantityRequested / listingQuantity;

    return Card(
      elevation: AppSpacing.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title with partial badge
            Row(
              children: [
                Text(
                  'Quantity Requested',
                  style: AppTypography.labelMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (isPartial) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(AppSpacing.xxs),
                    ),
                    child: Text(
                      'PARTIAL',
                      style: AppTypography.labelSmall.copyWith(
                        color: colorScheme.onTertiaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Crop info with emoji
            Row(
              children: [
                Text(
                  cropEmoji,
                  style: const TextStyle(fontSize: 40),
                  semanticsLabel: cropName,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${quantityRequested.toStringAsFixed(0)} kg',
                        style: AppTypography.headlineMedium.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isPartial)
                        Text(
                          'of your ${listingQuantity.toStringAsFixed(0)} kg listing',
                          style: AppTypography.bodyMedium.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        )
                      else
                        Text(
                          cropName,
                          style: AppTypography.bodyMedium.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // Progress bar for partial matches
            if (isPartial) ...[
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.xxs),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${(listingQuantity - quantityRequested).toStringAsFixed(0)} kg will remain active',
                style: AppTypography.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Price display card with gradient (AC2)
class PriceCard extends StatelessWidget {
  final double totalAmount;
  final double pricePerKg;
  final double quantityKg;

  const PriceCard({
    super.key,
    required this.totalAmount,
    required this.pricePerKg,
    required this.quantityKg,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.successGradient,
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // "You'll Earn" label
            Text(
              "You'll Earn",
              style: AppTypography.labelLarge.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            // Large price display (28sp+ for accessibility)
            Text(
              '₹${_formatAmount(totalAmount)}',
              style: AppTypography.headlineLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 36, // Above 28sp requirement
              ),
              semanticsLabel: 'Total earnings: ${totalAmount.toStringAsFixed(0)} rupees',
            ),
            const SizedBox(height: AppSpacing.sm),

            // Price breakdown
            Text(
              '₹${pricePerKg.toStringAsFixed(0)}/kg × ${quantityKg.toStringAsFixed(0)} kg',
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

/// Match expiry countdown timer (AC2)
class MatchExpiryTimer extends StatelessWidget {
  final DateTime expiresAt;
  final bool showIcon;

  const MatchExpiryTimer({
    super.key,
    required this.expiresAt,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final diff = expiresAt.difference(DateTime.now());
    final isExpired = diff.isNegative;
    final isUrgent = !isExpired && diff.inMinutes < 30;
    final isWarning = !isExpired && diff.inHours < 2;

    // Determine colors based on urgency
    Color bgColor;
    Color textColor;
    if (isExpired) {
      bgColor = colorScheme.errorContainer;
      textColor = colorScheme.onErrorContainer;
    } else if (isUrgent) {
      bgColor = colorScheme.error;
      textColor = colorScheme.onError;
    } else if (isWarning) {
      bgColor = colorScheme.tertiaryContainer;
      textColor = colorScheme.onTertiaryContainer;
    } else {
      bgColor = colorScheme.surfaceContainerHighest;
      textColor = colorScheme.onSurface;
    }

    final countdownText = _getCountdownText(diff);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              isExpired ? Icons.timer_off : Icons.schedule,
              color: textColor,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            isExpired ? 'Expired' : 'Expires in $countdownText',
            style: AppTypography.labelLarge.copyWith(
              color: textColor,
              fontWeight: isUrgent ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getCountdownText(Duration diff) {
    if (diff.isNegative) return 'Expired';
    
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

/// Summary card for match list (AC6)
class MatchCard extends StatelessWidget {
  final Match match;
  final VoidCallback? onTap;

  const MatchCard({
    super.key,
    required this.match,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: 'Match for ${match.listing.cropType}, ${match.formattedTotal}. '
             'Buyer: ${match.buyer.displayName}. '
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
                  // Top row: Crop + Expiry timer
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
                            match.listing.cropEmoji,
                            style: const TextStyle(fontSize: 24),
                            semanticsLabel: match.listing.cropType,
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
                              '${match.formattedQuantity} ${match.listing.cropType}',
                              style: AppTypography.titleMedium.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (match.isPartial)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.tertiaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Partial match',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: colorScheme.onTertiaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Expiry timer - Live countdown
                      LiveCountdownTimer(
                        expiresAt: match.expiresAt,
                        showIcon: false,
                        compact: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Divider
                  Divider(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    height: 1,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Bottom row: Buyer + Price
                  Row(
                    children: [
                      // Buyer info with icon
                      Icon(
                        Icons.storefront_rounded,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          match.buyer.displayName,
                          style: AppTypography.bodyMedium.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // Price with gradient background
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.successGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          match.formattedTotal,
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

/// Empty state for matches list (AC6)
class EmptyMatchesState extends StatelessWidget {
  final VoidCallback? onRefresh;

  const EmptyMatchesState({
    super.key,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.handshake_outlined,
              size: 80,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No pending matches',
              style: AppTypography.titleLarge.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "When buyers match with your listings, they'll appear here.",
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
