import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../models/notification_models.dart';

/// Notification Widgets - Story 3.8
///
/// Reusable UI components for notification center and preferences:
/// - NotificationCard: Individual notification item (AC3)
/// - NotificationBellBadge: AppBar bell icon with badge (AC3)
/// - NotificationEmptyState: No notifications placeholder
/// - QuietHoursTimePicker: Time range picker for quiet hours (AC4)
/// - NotificationLevelSelector: Segmented control for level (AC4)
/// - NotificationCategoryToggle: Category toggle with icon
///
/// Follows: Material Design 3, 60-30-10 color rule, 48dp touch targets,
/// voice-first TTS, WCAG 2.2 AA+ accessibility.

// =============================================================================
// NOTIFICATION CARD
// =============================================================================

/// Individual notification list item with swipe-to-delete (AC3)
class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkRead;
  final VoidCallback? onDelete;
  final bool showSwipeHint;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkRead,
    this.onDelete,
    this.showSwipeHint = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: onTap != null,
      label: notification.semanticLabel,
      child: Dismissible(
        key: Key(notification.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDelete?.call(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.delete_outline,
            color: colorScheme.onErrorContainer,
          ),
        ),
        child: Card(
          elevation: notification.isRead ? 0 : 2,
          shadowColor: notification.color.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: notification.isRead
                ? BorderSide.none
                : BorderSide(
                    color: notification.color.withValues(alpha: 0.3),
                    width: 1,
                  ),
          ),
          color: notification.isRead 
              ? colorScheme.surfaceContainerHighest
              : colorScheme.surface,
          child: InkWell(
            onTap: onTap,
            onLongPress: onMarkRead,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon container
                  _NotificationIcon(
                    icon: notification.icon,
                    color: notification.color,
                    isRead: notification.isRead,
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: AppTypography.titleSmall.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: notification.isRead 
                                      ? FontWeight.w500 
                                      : FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Unread indicator
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: notification.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Body
                        Text(
                          notification.body,
                          style: AppTypography.bodyMedium.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),

                        // Timestamp and metadata
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: colorScheme.outline,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              notification.relativeTime,
                              style: AppTypography.labelSmall.copyWith(
                                color: colorScheme.outline,
                              ),
                            ),
                            if (notification.isCritical) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: notification.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'URGENT',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: notification.color,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Chevron
                  if (notification.deeplink != null)
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.xs),
                      child: Icon(
                        Icons.chevron_right,
                        color: colorScheme.outline,
                        size: 20,
                      ),
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

/// Icon container for notification
class _NotificationIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isRead;

  const _NotificationIcon({
    required this.icon,
    required this.color,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isRead
            ? color.withValues(alpha: 0.1)
            : color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: isRead ? color.withValues(alpha: 0.6) : color,
        size: 22,
      ),
    );
  }
}

// =============================================================================
// NOTIFICATION BELL BADGE
// =============================================================================

/// Animated notification bell icon with unread count badge (AC3)
class NotificationBellBadge extends StatefulWidget {
  final int unreadCount;
  final VoidCallback onTap;
  final bool animate;

  const NotificationBellBadge({
    super.key,
    required this.unreadCount,
    required this.onTap,
    this.animate = false,
  });

  @override
  State<NotificationBellBadge> createState() => _NotificationBellBadgeState();
}

class _NotificationBellBadgeState extends State<NotificationBellBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(NotificationBellBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Animate when count increases
    if (widget.unreadCount > oldWidget.unreadCount && widget.animate) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Semantics(
      button: true,
      label: widget.unreadCount > 0
          ? 'Notifications, ${widget.unreadCount} unread'
          : 'Notifications',
      child: Tooltip(
        message: widget.unreadCount > 0
            ? '${widget.unreadCount} unread notifications'
            : 'Notifications',
        child: InkWell(
          onTap: widget.onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    widget.unreadCount > 0
                        ? Icons.notifications
                        : Icons.notifications_outlined,
                    color: colorScheme.onSurface,
                    size: 24,
                  ),
                  if (widget.unreadCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: _BadgeCounter(count: widget.unreadCount),
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

/// Badge counter bubble
class _BadgeCounter extends StatelessWidget {
  final int count;

  const _BadgeCounter({required this.count});

  @override
  Widget build(BuildContext context) {
    final displayCount = count > 99 ? '99+' : count.toString();

    return Container(
      constraints: const BoxConstraints(
        minWidth: 18,
        minHeight: 18,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          displayCount,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.onError,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// NOTIFICATION EMPTY STATE
// =============================================================================

/// Empty state for notification center
class NotificationEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRefresh;

  const NotificationEmptyState({
    super.key,
    this.title = 'No notifications',
    this.message = 'You\'re all caught up!',
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
            // Icon with animated background
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.notifications_none_rounded,
                  size: 48,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title
            Text(
              title,
              style: AppTypography.titleLarge.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),

            // Message
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            // Refresh button
            if (onRefresh != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
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

// =============================================================================
// NOTIFICATION SKELETON LOADER
// =============================================================================

/// Shimmer loading skeleton for notifications
class NotificationCardSkeleton extends StatelessWidget {
  const NotificationCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon skeleton
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.outline.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Content skeleton
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 150,
                    decoration: BoxDecoration(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.outline.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 14,
                    width: 200,
                    decoration: BoxDecoration(
                      color: colorScheme.outline.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 12,
                    width: 80,
                    decoration: BoxDecoration(
                      color: colorScheme.outline.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton list for loading state
class NotificationListSkeleton extends StatelessWidget {
  final int count;

  const NotificationListSkeleton({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, __) => const NotificationCardSkeleton(),
    );
  }
}

// =============================================================================
// NOTIFICATION LEVEL SELECTOR
// =============================================================================

/// Segmented control for notification level (AC4)
class NotificationLevelSelector extends StatelessWidget {
  final NotificationLevel selected;
  final ValueChanged<NotificationLevel> onChanged;

  const NotificationLevelSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<NotificationLevel>(
      segments: NotificationLevel.values.map((level) => 
        ButtonSegment<NotificationLevel>(
          value: level,
          label: Text(level.label),
          tooltip: level.description,
        ),
      ).toList(),
      selected: {selected},
      onSelectionChanged: (Set<NotificationLevel> selection) {
        onChanged(selection.first);
      },
      style: ButtonStyle(
        visualDensity: VisualDensity.comfortable,
      ),
    );
  }
}

// =============================================================================
// QUIET HOURS PICKER
// =============================================================================

/// Time range picker for quiet hours (AC4)
class QuietHoursTimePicker extends StatelessWidget {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool enabled;
  final ValueChanged<TimeOfDay> onStartChanged;
  final ValueChanged<TimeOfDay> onEndChanged;

  const QuietHoursTimePicker({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.enabled,
    required this.onStartChanged,
    required this.onEndChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: AbsorbPointer(
        absorbing: !enabled,
        child: Row(
          children: [
            Expanded(
              child: _TimePickerButton(
                label: 'Start',
                time: startTime,
                onTap: () => _showTimePicker(context, startTime, onStartChanged),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Icon(
                Icons.arrow_forward,
                color: colorScheme.outline,
              ),
            ),
            Expanded(
              child: _TimePickerButton(
                label: 'End',
                time: endTime,
                onTap: () => _showTimePicker(context, endTime, onEndChanged),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTimePicker(
    BuildContext context,
    TimeOfDay initialTime,
    ValueChanged<TimeOfDay> onChanged,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onChanged(picked);
    }
  }
}

class _TimePickerButton extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  const _TimePickerButton({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final formattedTime = _formatTime12Hour(time);

    return Semantics(
      button: true,
      label: '$label time: $formattedTime',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formattedTime,
                    style: AppTypography.titleMedium.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
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

  String _formatTime12Hour(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

// =============================================================================
// NOTIFICATION CATEGORY TOGGLE
// =============================================================================

/// Category toggle switch with icon (AC4)
class NotificationCategoryToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const NotificationCategoryToggle({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      toggled: value,
      label: '$title, $subtitle',
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: value
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: value
                ? colorScheme.onPrimaryContainer
                : colorScheme.outline,
          ),
        ),
        title: Text(
          title,
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

// =============================================================================
// MARK ALL READ BUTTON
// =============================================================================

/// Button to mark all notifications as read
class MarkAllReadButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool hasUnread;

  const MarkAllReadButton({
    super.key,
    required this.onPressed,
    required this.hasUnread,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasUnread) return const SizedBox.shrink();

    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.done_all, size: 18),
      label: const Text('Mark all read'),
    );
  }
}

// =============================================================================
// NOTIFICATION HEADER WITH UNREAD COUNT
// =============================================================================

/// Section header showing unread count
class NotificationSectionHeader extends StatelessWidget {
  final int unreadCount;
  final VoidCallback? onMarkAllRead;

  const NotificationSectionHeader({
    super.key,
    required this.unreadCount,
    this.onMarkAllRead,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          if (unreadCount > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$unreadCount unread',
                style: AppTypography.labelMedium.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ] else ...[
            Text(
              'All caught up',
              style: AppTypography.labelMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const Spacer(),
          if (unreadCount > 0 && onMarkAllRead != null)
            TextButton(
              onPressed: onMarkAllRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
    );
  }
}
