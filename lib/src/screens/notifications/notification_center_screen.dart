import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_typography.dart';
import '../../models/notification_models.dart';
import '../../widgets/notification_widgets.dart';

/// Notification Center Screen - Story 3.8 (Task 8)
///
/// Main notification list with:
/// - Infinite scroll pagination (AC3)
/// - Mark as read, delete gestures (AC3)
/// - TTS announcement of unread count (AC8)
/// - Pull to refresh
/// - Empty state with illustration
///
/// Follows: Material Design 3, Voice-First UX, 48dp touch targets,
/// responsive layout, smooth animations, WCAG 2.2 AA+.

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen>
    with SingleTickerProviderStateMixin {
  // State
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _currentPage = 1;

  // TTS for voice-first UX (AC8)
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  bool _ttsEnabled = true;

  // Scroll controller for infinite scroll
  final ScrollController _scrollController = ScrollController();

  // Animation
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupTts();
    _scrollController.addListener(_onScroll);
    _loadNotifications();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _setupTts() async {
    await _tts.setLanguage('en-IN');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMoreNotifications();
    }
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _currentPage = 1;
    });

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 600));

      final response = NotificationsResponse.mock(count: 15, unread: 5);
      
      setState(() {
        _notifications = response.notifications;
        _unreadCount = response.unreadCount;
        _hasMore = response.hasMore;
        _isLoading = false;
      });

      _fadeController.forward();

      // Announce unread count via TTS (AC8)
      if (_ttsEnabled && _unreadCount > 0) {
        _announceUnreadCount();
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load notifications. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreNotifications() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 400));

      final response = NotificationsResponse.mock(count: 10, unread: 0);
      
      setState(() {
        _notifications.addAll(response.notifications);
        _hasMore = _notifications.length < 50; // Mock limit
        _currentPage++;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _announceUnreadCount() async {
    if (!_ttsEnabled) return;
    
    setState(() => _isSpeaking = true);
    
    final announcement = _unreadCount == 1
        ? 'You have 1 unread notification.'
        : 'You have $_unreadCount unread notifications.';
    
    await _tts.speak(announcement);
  }

  Future<void> _speakNotification(AppNotification notification) async {
    if (!_ttsEnabled) return;
    
    setState(() => _isSpeaking = true);
    await _tts.speak(notification.ttsAnnouncement);
  }

  void _stopSpeaking() async {
    await _tts.stop();
    setState(() => _isSpeaking = false);
  }

  void _onNotificationTap(AppNotification notification) {
    // Mark as read
    if (!notification.isRead) {
      _markAsRead(notification.id);
    }

    // Navigate to deeplink if available
    if (notification.deeplink != null) {
      _navigateToDeeplink(notification.deeplink!);
    } else {
      // Show notification details in a bottom sheet
      _showNotificationDetails(notification);
    }
  }

  void _navigateToDeeplink(String deeplink) {
    // TODO: Implement deep link navigation
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to: $deeplink'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showNotificationDetails(AppNotification notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _NotificationDetailSheet(
        notification: notification,
        onSpeak: () => _speakNotification(notification),
      ),
    );
  }

  void _markAsRead(String notificationId) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1 && !_notifications[index].isRead) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _unreadCount = (_unreadCount - 1).clamp(0, _unreadCount);
      }
    });
    // TODO: Call API to mark as read
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _unreadCount = 0;
    });
    // TODO: Call API to mark all as read
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteNotification(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;

    final deleted = _notifications[index];
    
    setState(() {
      _notifications.removeAt(index);
      if (!deleted.isRead) {
        _unreadCount = (_unreadCount - 1).clamp(0, _unreadCount);
      }
    });
    // TODO: Call API to delete

    // Show undo snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification deleted'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _notifications.insert(index, deleted);
              if (!deleted.isRead) {
                _unreadCount++;
              }
            });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        actions: [
          // Voice toggle button (AC8)
          IconButton(
            onPressed: _isSpeaking ? _stopSpeaking : _announceUnreadCount,
            icon: Icon(_isSpeaking ? Icons.stop : Icons.volume_up),
            tooltip: _isSpeaking ? 'Stop reading' : 'Read unread count',
          ),
          // Mark all as read
          if (_unreadCount > 0)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'mark_all') {
                  _markAllAsRead();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'mark_all',
                  child: Row(
                    children: [
                      Icon(Icons.done_all),
                      SizedBox(width: 8),
                      Text('Mark all as read'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const NotificationListSkeleton();
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(_error!),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: _loadNotifications,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return NotificationEmptyState(
        title: 'No notifications yet',
        message: 'When you receive notifications, they\'ll appear here.',
        onRefresh: _loadNotifications,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Unread count header
            NotificationSectionHeader(
              unreadCount: _unreadCount,
              onMarkAllRead: _unreadCount > 0 ? _markAllAsRead : null,
            ),

            // Notification list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: _notifications.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= _notifications.length) {
                    // Loading more indicator
                    return const Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final notification = _notifications[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: NotificationCard(
                      notification: notification,
                      onTap: () => _onNotificationTap(notification),
                      onMarkRead: () => _markAsRead(notification.id),
                      onDelete: () => _deleteNotification(notification.id),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet showing notification details
class _NotificationDetailSheet extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onSpeak;

  const _NotificationDetailSheet({
    required this.notification,
    this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Header
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: notification.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    notification.icon,
                    color: notification.color,
                    size: 26,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        notification.formattedDate,
                        style: AppTypography.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onSpeak != null)
                  IconButton(
                    onPressed: onSpeak,
                    icon: const Icon(Icons.volume_up),
                    tooltip: 'Read aloud',
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Body
            Text(
              notification.body,
              style: AppTypography.bodyLarge.copyWith(
                color: colorScheme.onSurface,
              ),
            ),

            // Metadata
            if (notification.metadata != null && notification.metadata!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    if (notification.orderId != null)
                      _DetailRow(
                        icon: Icons.tag,
                        label: 'Order ID',
                        value: notification.orderId!,
                      ),
                    if (notification.formattedAmount != null)
                      _DetailRow(
                        icon: Icons.payments,
                        label: 'Amount',
                        value: notification.formattedAmount!,
                      ),
                    if (notification.cropType != null)
                      _DetailRow(
                        icon: Icons.eco,
                        label: 'Crop',
                        value: notification.cropType!,
                      ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.lg),

            // Action button
            if (notification.deeplink != null)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Navigate to deeplink
                  },
                  child: const Text('View Details'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
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
      ),
    );
  }
}
