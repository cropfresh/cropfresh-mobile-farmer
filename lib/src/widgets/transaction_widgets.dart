import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../models/transaction_models.dart';

/// Transaction Widgets - Story 3.7
///
/// Reusable UI components for earnings and transaction history screens:
/// - EarningsSummaryCard: Dashboard earnings overview (AC1)
/// - EarningsStatTile: Individual stat with animation
/// - TransactionCard: List item for transactions (AC2)
/// - TransactionFilterChip: Filter chips for status/date/crop (AC3)
/// - PaymentBreakdownCard: Detailed payment info (AC4)
/// - TransactionTimeline: Status history display (AC4)
/// - EmptyTransactionsState: No transactions placeholder (AC7)
///
/// Follows: Material Design 3, 60-30-10 color rule, 48dp touch targets,
/// voice-first TTS, WCAG 2.2 AA+ accessibility.

// ============================================
// AC1: EARNINGS SUMMARY CARD
// ============================================

/// Main earnings dashboard card with glassmorphism effect
class EarningsSummaryCard extends StatelessWidget {
  final EarningsSummary earnings;
  final VoidCallback? onTap;
  final VoidCallback? onVoiceRead;

  const EarningsSummaryCard({
    super.key,
    required this.earnings,
    this.onTap,
    this.onVoiceRead,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: onTap != null,
      label: earnings.ttsAnnouncement,
      child: Card(
        elevation: 8,
        shadowColor: AppColors.primary.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: AppColors.primaryGradient,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 24,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'My Earnings',
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      // Voice read button (AC6)
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
                      // Badge for new transactions
                      if (earnings.hasBadge)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '+${earnings.newSinceLastVisit}',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Total earnings - Large display
                  Text(
                    earnings.formattedTotal,
                    style: AppTypography.displayMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    '${earnings.totalOrderCount} completed orders',
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Stats row
                  Row(
                    children: [
                      Expanded(
                        child: _EarningsStatTile(
                          icon: Icons.calendar_month_outlined,
                          label: 'This Month',
                          value: earnings.formattedThisMonth,
                          subLabel: '${earnings.thisMonthOrderCount} orders',
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 48,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      Expanded(
                        child: _EarningsStatTile(
                          icon: Icons.hourglass_bottom_outlined,
                          label: 'Pending',
                          value: earnings.formattedPending,
                          isWarning: earnings.pending > 0,
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

/// Individual stat tile within earnings card
class _EarningsStatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subLabel;
  final bool isWarning;

  const _EarningsStatTile({
    required this.icon,
    required this.label,
    required this.value,
    this.subLabel,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isWarning
                    ? AppColors.primary
                    : Colors.white.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subLabel != null)
            Text(
              subLabel!,
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================
// AC2: TRANSACTION CARD
// ============================================

/// Transaction list item with smooth hover/tap effects
class TransactionCard extends StatelessWidget {
  final TransactionItem transaction;
  final VoidCallback? onTap;
  final bool showDate;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
    this.showDate = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: onTap != null,
      label: transaction.semanticLabel,
      child: Card(
        elevation: 2,
        shadowColor: AppColors.primary.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Crop icon container
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      transaction.cropIcon,
                      style: const TextStyle(fontSize: 24),
                      semanticsLabel: transaction.cropType,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Transaction info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Crop and quantity
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${transaction.formattedQuantity} ${transaction.cropType}',
                              style: AppTypography.titleSmall.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Quality grade badge
                          if (transaction.qualityGrade != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getGradeColor(transaction.qualityGrade!)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Grade ${transaction.qualityGrade}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: _getGradeColor(transaction.qualityGrade!),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Buyer info
                      Text(
                        transaction.buyerDisplay,
                        style: AppTypography.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Date (optional)
                      if (showDate)
                        Text(
                          transaction.formattedDate,
                          style: AppTypography.labelSmall.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),

                // Amount and status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Amount with gradient container
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: transaction.isCompleted
                            ? AppColors.successGradient
                            : null,
                        color: transaction.isPending
                            ? colorScheme.tertiaryContainer
                            : null,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        transaction.formattedAmount,
                        style: AppTypography.titleSmall.copyWith(
                          color: transaction.isCompleted
                              ? Colors.white
                              : colorScheme.onTertiaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Status label
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          transaction.isCompleted
                              ? Icons.check_circle
                              : Icons.schedule,
                          size: 14,
                          color: transaction.isCompleted
                              ? AppColors.secondary
                              : colorScheme.tertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          transaction.status.label,
                          style: AppTypography.labelSmall.copyWith(
                            color: transaction.isCompleted
                                ? AppColors.secondary
                                : colorScheme.tertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.xs),

                // Chevron
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'A':
        return AppColors.secondary;
      case 'B':
        return AppColors.primary;
      case 'C':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

// ============================================
// AC3: FILTER CHIPS
// ============================================

/// Filter chip bar for transactions
class TransactionFilterBar extends StatelessWidget {
  final TransactionFilter filter;
  final ValueChanged<TransactionFilter> onFilterChanged;

  const TransactionFilterBar({
    super.key,
    required this.filter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          // Status filter chips
          ...TransactionStatus.values.map(
            (status) => Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: FilterChip(
                selected: filter.status == status,
                label: Text(status.label),
                onSelected: (_) => onFilterChanged(
                  filter.copyWith(status: status, page: 1),
                ),
                avatar: filter.status == status
                    ? const Icon(Icons.check, size: 18)
                    : null,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Date range chip
          ActionChip(
            avatar: const Icon(Icons.date_range, size: 18),
            label: Text(_getDateRangeLabel()),
            onPressed: () => _showDateRangePicker(context),
          ),
          const SizedBox(width: AppSpacing.xs),

          // Sort chip
          ActionChip(
            avatar: Icon(
              filter.ascending
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              size: 18,
            ),
            label: Text('Sort: ${filter.sortBy.label}'),
            onPressed: () => _showSortOptions(context),
          ),
        ],
      ),
    );
  }

  String _getDateRangeLabel() {
    if (filter.fromDate == null && filter.toDate == null) {
      return 'Last 90 days';
    }
    // TODO: Format date range
    return 'Custom range';
  }

  void _showDateRangePicker(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
      initialDateRange: filter.fromDate != null && filter.toDate != null
          ? DateTimeRange(start: filter.fromDate!, end: filter.toDate!)
          : DateTimeRange(
              start: now.subtract(const Duration(days: 90)),
              end: now,
            ),
    );

    if (picked != null) {
      onFilterChanged(filter.copyWith(
        fromDate: picked.start,
        toDate: picked.end,
        page: 1,
      ));
    }
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Sort by'),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const Divider(),
            ...TransactionSortBy.values.map(
              (sortBy) => RadioListTile<TransactionSortBy>(
                value: sortBy,
                groupValue: filter.sortBy,
                title: Text(sortBy.label),
                onChanged: (value) {
                  onFilterChanged(filter.copyWith(sortBy: value, page: 1));
                  Navigator.pop(context);
                },
              ),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Ascending order'),
              value: filter.ascending,
              onChanged: (value) {
                onFilterChanged(filter.copyWith(ascending: value, page: 1));
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

// ============================================
// AC4: PAYMENT BREAKDOWN CARD
// ============================================

/// Detailed payment breakdown with visual hierarchy
class PaymentBreakdownCard extends StatelessWidget {
  final PaymentBreakdown payment;
  final VoidCallback? onVoiceRead;

  const PaymentBreakdownCard({
    super.key,
    required this.payment,
    this.onVoiceRead,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: payment.ttsAnnouncement,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Payment Breakdown',
                    style: AppTypography.titleMedium.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (onVoiceRead != null)
                    IconButton(
                      onPressed: onVoiceRead,
                      icon: const Icon(Icons.volume_up_rounded),
                      tooltip: 'Read aloud',
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Breakdown rows
              _PaymentRow(
                label: 'Base Amount',
                value: payment.formattedBaseAmount,
              ),
              if (payment.qualityBonus != 0)
                _PaymentRow(
                  label: 'Quality Bonus',
                  value: payment.formattedQualityBonus,
                  isHighlight: payment.qualityBonus > 0,
                ),
              _PaymentRow(
                label: 'Platform Fee',
                value: payment.formattedPlatformFee,
                note: 'Farmers pay ₹0',
              ),

              const Divider(height: AppSpacing.xl),

              // Net amount - Hero row
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: AppColors.successGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      'Net Amount',
                      style: AppTypography.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      payment.formattedNetAmount,
                      style: AppTypography.headlineSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Payment details
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.account_balance,
                      label: 'Payment Method',
                      value: 'UPI',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _InfoRow(
                      icon: Icons.tag,
                      label: 'Transaction ID',
                      value: payment.upiTxnId,
                    ),
                    if (payment.formattedPaidAt != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _InfoRow(
                        icon: Icons.schedule,
                        label: 'Paid On',
                        value: payment.formattedPaidAt!,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;
  final String? note;

  const _PaymentRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (note != null) ...[
            const SizedBox(width: 4),
            Text(
              '($note)',
              style: AppTypography.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
          const Spacer(),
          Text(
            value,
            style: AppTypography.titleSmall.copyWith(
              color: isHighlight ? AppColors.secondary : colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ============================================
// AC7: EMPTY STATE
// ============================================

/// Empty transactions placeholder
class EmptyTransactionsState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onActionPressed;
  final String? actionLabel;

  const EmptyTransactionsState({
    super.key,
    this.title = 'No transactions yet',
    this.message = 'Your completed transactions will appear here.',
    this.onActionPressed,
    this.actionLabel,
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
            // Empty icon with animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.receipt_long_outlined,
                      size: 56,
                      color: colorScheme.primary.withValues(alpha: 0.6),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            Text(
              title,
              style: AppTypography.titleLarge.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),

            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            if (onActionPressed != null && actionLabel != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================
// AC5: RECEIPT DOWNLOAD BUTTON
// ============================================

/// Receipt download button with availability check
class ReceiptDownloadButton extends StatelessWidget {
  final bool canDownload;
  final bool isLoading;
  final VoidCallback? onPressed;

  const ReceiptDownloadButton({
    super.key,
    required this.canDownload,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!canDownload) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Receipt no longer available (beyond 90 days)',
                style: AppTypography.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return FilledButton.tonal(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.download),
                SizedBox(width: AppSpacing.sm),
                Text('Download Receipt'),
              ],
            ),
    );
  }
}
