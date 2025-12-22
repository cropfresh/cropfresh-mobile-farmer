import 'package:flutter/material.dart';
import 'dart:async';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../services/match_notification_service.dart';

/// In-App Match Notification Banner - Story 3.5 (AC: 5.4)
/// 
/// Shows a slide-down notification banner when a new match arrives
/// while the app is open. Taps navigate to match details.
class MatchNotificationBanner extends StatefulWidget {
  final MatchNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final Duration duration;

  const MatchNotificationBanner({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
    this.duration = const Duration(seconds: 5),
  });

  @override
  State<MatchNotificationBanner> createState() => _MatchNotificationBannerState();
}

class _MatchNotificationBannerState extends State<MatchNotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // Start animation
    _controller.forward();

    // Auto-dismiss after duration
    _autoDismissTimer = Timer(widget.duration, _dismiss);
  }

  void _dismiss() {
    _autoDismissTimer?.cancel();
    _controller.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.notification.type;
    
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(16),
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      type.color.withValues(alpha: 0.95),
                      type.color.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: type.color.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    _dismiss();
                    widget.onTap?.call();
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        // Icon with pulse animation
                        _PulsingIcon(icon: type.icon),
                        const SizedBox(width: AppSpacing.md),
                        
                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                type.title,
                                style: AppTypography.titleMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.notification.message,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        
                        // Dismiss button
                        IconButton(
                          onPressed: _dismiss,
                          icon: const Icon(Icons.close, color: Colors.white70),
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pulsing icon for notification emphasis
class _PulsingIcon extends StatefulWidget {
  final IconData icon;

  const _PulsingIcon({required this.icon});

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          widget.icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

/// Live Countdown Timer Widget - Story 3.5 (AC: 2)
/// 
/// Animates countdown in real-time with visual urgency indicators.
/// Updates every second for accurate time display.
class LiveCountdownTimer extends StatefulWidget {
  final DateTime expiresAt;
  final bool showIcon;
  final bool compact;
  final VoidCallback? onExpired;

  const LiveCountdownTimer({
    super.key,
    required this.expiresAt,
    this.showIcon = true,
    this.compact = false,
    this.onExpired,
  });

  @override
  State<LiveCountdownTimer> createState() => _LiveCountdownTimerState();
}

class _LiveCountdownTimerState extends State<LiveCountdownTimer>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late Duration _remaining;
  bool _hasExpiredCallbackFired = false;
  
  // Animation for urgent state
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _remaining = widget.expiresAt.difference(DateTime.now());
    
    // Start periodic update
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });

    // Pulse animation for urgent state
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start pulse if already urgent
    _checkPulseAnimation();
  }

  void _updateRemaining() {
    if (!mounted) return;
    
    final newRemaining = widget.expiresAt.difference(DateTime.now());
    
    setState(() {
      _remaining = newRemaining;
    });

    // Trigger expired callback (only once, after setState completes)
    if (_remaining.isNegative && !_hasExpiredCallbackFired && widget.onExpired != null) {
      _hasExpiredCallbackFired = true;
      _timer?.cancel();
      // Schedule callback for next frame to avoid issues
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onExpired?.call();
        }
      });
    }

    _checkPulseAnimation();
  }

  void _checkPulseAnimation() {
    if (!mounted) return;
    
    // Start pulse animation if urgent
    if (_remaining.inMinutes < 30 && !_remaining.isNegative) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isExpired = _remaining.isNegative;
    final isUrgent = !isExpired && _remaining.inMinutes < 30;
    final isWarning = !isExpired && _remaining.inHours < 2;

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
      bgColor = AppColors.primary.withValues(alpha: 0.15);
      textColor = AppColors.primary;
    } else {
      bgColor = colorScheme.surfaceContainerHighest;
      textColor = colorScheme.onSurface;
    }

    final countdownText = _formatCountdown();

    Widget timerWidget = Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.compact ? AppSpacing.sm : AppSpacing.md,
        vertical: widget.compact ? AppSpacing.xxs : AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(widget.compact ? 8 : 16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showIcon) ...[
            Icon(
              isExpired ? Icons.timer_off : Icons.schedule,
              color: textColor,
              size: widget.compact ? 16 : 20,
            ),
            SizedBox(width: widget.compact ? 4 : AppSpacing.xs),
          ],
          Text(
            isExpired ? 'Expired' : (widget.compact ? countdownText : 'Expires in $countdownText'),
            style: (widget.compact ? AppTypography.labelMedium : AppTypography.labelLarge).copyWith(
              color: textColor,
              fontWeight: isUrgent ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    // Apply pulse animation for urgent state
    if (isUrgent && !isExpired) {
      return ScaleTransition(
        scale: _pulseAnimation,
        child: timerWidget,
      );
    }

    return timerWidget;
  }

  String _formatCountdown() {
    if (_remaining.isNegative) return 'Expired';
    
    final hours = _remaining.inHours;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }
}

/// Notification Banner Overlay - Story 3.5 (AC: 5.4)
/// 
/// Manages the display of in-app notification banners using an overlay.
/// Usage: Call `MatchNotificationOverlay.show(context, notification)` to display.
class MatchNotificationOverlay {
  static OverlayEntry? _currentEntry;

  /// Show notification banner
  static void show(
    BuildContext context,
    MatchNotification notification, {
    VoidCallback? onTap,
  }) {
    // Remove existing banner
    dismiss();

    // Create new overlay entry
    _currentEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: MatchNotificationBanner(
          notification: notification,
          onTap: onTap,
          onDismiss: dismiss,
        ),
      ),
    );

    // Insert into overlay
    Overlay.of(context).insert(_currentEntry!);
  }

  /// Dismiss current banner
  static void dismiss() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}
