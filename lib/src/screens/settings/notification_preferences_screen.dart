import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_typography.dart';
import '../../models/notification_models.dart';
import '../../widgets/notification_widgets.dart';

/// Notification Preferences Screen - Story 3.8 (Task 9)
///
/// Configurable notification settings with:
/// - SMS/Push toggles (AC4)
/// - Quiet hours time pickers (AC4)
/// - Notification level selector (AC4)
/// - Per-category toggles (AC4)
/// - Auto-sync preferences with backend
///
/// Follows: Material Design 3, Voice-First UX, 48dp touch targets,
/// responsive layout, smooth animations, WCAG 2.2 AA+.

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  // State
  NotificationPreferences _preferences = NotificationPreferences.defaults();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  // TTS for voice-first UX
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  // Track changes for undo
  NotificationPreferences? _previousPreferences;

  @override
  void initState() {
    super.initState();
    _setupTts();
    _loadPreferences();
  }

  Future<void> _setupTts() async {
    await _tts.setLanguage('en-IN');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  Future<void> _loadPreferences() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _preferences = NotificationPreferences.defaults();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load preferences.';
        _isLoading = false;
      });
    }
  }

  Future<void> _savePreferences() async {
    setState(() => _isSaving = true);

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preferences saved'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save preferences'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _savePreferences,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _updatePreference(NotificationPreferences newPreferences) {
    _previousPreferences = _preferences;
    setState(() {
      _preferences = newPreferences;
    });
    _savePreferences();
  }

  Future<void> _speakSettings() async {
    setState(() => _isSpeaking = true);
    await _tts.speak(_preferences.ttsAnnouncement);
  }

  void _stopSpeaking() async {
    await _tts.stop();
    setState(() => _isSpeaking = false);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        centerTitle: true,
        actions: [
          // Voice toggle button
          IconButton(
            onPressed: _isSpeaking ? _stopSpeaking : _speakSettings,
            icon: Icon(_isSpeaking ? Icons.stop : Icons.volume_up),
            tooltip: _isSpeaking ? 'Stop reading' : 'Read settings aloud',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
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
              onPressed: _loadPreferences,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // =============================================
        // DELIVERY METHODS SECTION
        // =============================================
        _SectionHeader(
          icon: Icons.send,
          title: 'Delivery Methods',
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              children: [
                _ToggleListTile(
                  icon: Icons.sms_outlined,
                  title: 'SMS Notifications',
                  subtitle: 'Receive critical alerts via SMS',
                  value: _preferences.smsEnabled,
                  onChanged: (value) {
                    _updatePreference(_preferences.copyWith(smsEnabled: value));
                  },
                ),
                const Divider(height: 1),
                _ToggleListTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'Push Notifications',
                  subtitle: 'Receive alerts on your device',
                  value: _preferences.pushEnabled,
                  onChanged: (value) {
                    _updatePreference(_preferences.copyWith(pushEnabled: value));
                  },
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // =============================================
        // QUIET HOURS SECTION
        // =============================================
        _SectionHeader(
          icon: Icons.bedtime,
          title: 'Quiet Hours',
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ToggleListTile(
                  icon: Icons.do_not_disturb_on_outlined,
                  title: 'Enable Quiet Hours',
                  subtitle: 'No push notifications during this time',
                  value: _preferences.quietHoursEnabled,
                  onChanged: (value) {
                    _updatePreference(_preferences.copyWith(quietHoursEnabled: value));
                  },
                ),
                if (_preferences.quietHoursEnabled) ...[
                  const Divider(height: AppSpacing.lg),
                  Text(
                    'Time Range',
                    style: AppTypography.labelMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  QuietHoursTimePicker(
                    startTime: _preferences.quietHoursStart,
                    endTime: _preferences.quietHoursEnd,
                    enabled: _preferences.quietHoursEnabled,
                    onStartChanged: (time) {
                      _updatePreference(_preferences.copyWith(quietHoursStart: time));
                    },
                    onEndChanged: (time) {
                      _updatePreference(_preferences.copyWith(quietHoursEnd: time));
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Current status indicator
                  if (_preferences.isQuietHoursNow)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.nightlight_round,
                            size: 18,
                            color: colorScheme.onTertiaryContainer,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Quiet hours are currently active',
                            style: AppTypography.bodySmall.copyWith(
                              color: colorScheme.onTertiaryContainer,
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

        const SizedBox(height: AppSpacing.xl),

        // =============================================
        // NOTIFICATION LEVEL SECTION
        // =============================================
        _SectionHeader(
          icon: Icons.tune,
          title: 'Notification Level',
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose which notifications to receive',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                NotificationLevelSelector(
                  selected: _preferences.level,
                  onChanged: (level) {
                    _updatePreference(_preferences.copyWith(level: level));
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _preferences.level.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // =============================================
        // CATEGORIES SECTION
        // =============================================
        _SectionHeader(
          icon: Icons.category,
          title: 'Categories',
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              children: [
                NotificationCategoryToggle(
                  icon: Icons.local_shipping,
                  title: 'Order Updates',
                  subtitle: 'Pickup, delivery, and tracking alerts',
                  value: _preferences.orderUpdates,
                  onChanged: (value) {
                    _updatePreference(_preferences.copyWith(orderUpdates: value));
                  },
                ),
                const Divider(height: 1),
                NotificationCategoryToggle(
                  icon: Icons.payments,
                  title: 'Payment Alerts',
                  subtitle: 'Payment received and pending alerts',
                  value: _preferences.paymentAlerts,
                  onChanged: (value) {
                    _updatePreference(_preferences.copyWith(paymentAlerts: value));
                  },
                ),
                const Divider(height: 1),
                NotificationCategoryToggle(
                  icon: Icons.lightbulb_outline,
                  title: 'Educational Content',
                  subtitle: 'Tips, guides, and farming advice',
                  value: _preferences.educationalContent,
                  onChanged: (value) {
                    _updatePreference(_preferences.copyWith(educationalContent: value));
                  },
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // =============================================
        // INFO SECTION
        // =============================================
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Critical notifications like match confirmations and payments '
                  'will always be delivered, regardless of your settings.',
                  style: AppTypography.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Saving indicator
        if (_isSaving)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text('Saving...'),
                ],
              ),
            ),
          ),

        // Bottom padding
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

/// Section header with icon
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// Toggle list tile with icon
class _ToggleListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleListTile({
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
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      ),
    );
  }
}
