import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// Profile History Screen - Story 2.7 (AC8)
/// Displays audit log of profile changes with masked sensitive data
class ProfileHistoryScreen extends StatefulWidget {
  const ProfileHistoryScreen({super.key});

  @override
  State<ProfileHistoryScreen> createState() => _ProfileHistoryScreenState();
}

class _ProfileHistoryScreenState extends State<ProfileHistoryScreen> {
  bool _isLoading = true;
  List<ProfileChange> _changes = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));
    
    setState(() {
      _isLoading = false;
      _changes = [
        ProfileChange(
          fieldName: 'UPI ID',
          oldValue: 'ram***@okaxis',
          newValue: 'ram***@ybl',
          changedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        ProfileChange(
          fieldName: 'Language Preference',
          oldValue: 'English',
          newValue: 'Kannada',
          changedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        ProfileChange(
          fieldName: 'Crop Types',
          oldValue: 'Vegetables',
          newValue: 'Vegetables, Fruits',
          changedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        ProfileChange(
          fieldName: 'Village',
          oldValue: 'Kodigehalli',
          newValue: 'Sadahalli',
          changedAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
        ProfileChange(
          fieldName: 'Account Created',
          oldValue: '-',
          newValue: 'Initial registration',
          changedAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Change History'),
        backgroundColor: AppColors.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _changes.isEmpty
              ? _buildEmptyState(theme)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _changes.length,
                  itemBuilder: (context, index) {
                    final change = _changes[index];
                    final isFirst = index == 0;
                    final isLast = index == _changes.length - 1;
                    
                    return _ChangeHistoryItem(
                      change: change,
                      isFirst: isFirst,
                      isLast: isLast,
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 64,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No changes yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your profile changes will appear here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// Change History Item with timeline marker
class _ChangeHistoryItem extends StatelessWidget {
  final ProfileChange change;
  final bool isFirst;
  final bool isLast;

  const _ChangeHistoryItem({
    required this.change,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline
          SizedBox(
            width: 32,
            child: Column(
              children: [
                // Top connector
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 16,
                    color: AppColors.outline,
                  ),
                // Dot
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isFirst ? AppColors.primary : AppColors.outline,
                    shape: BoxShape.circle,
                    border: isFirst
                        ? null
                        : Border.all(color: AppColors.outline, width: 2),
                  ),
                ),
                // Bottom connector
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.outline,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isFirst ? AppColors.primary.withValues(alpha: 0.3) : AppColors.outline,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Field name and date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          change.fieldName,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        _formatDate(change.changedAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Old value
                  Row(
                    children: [
                      Icon(
                        Icons.remove_circle_outline,
                        size: 16,
                        color: AppColors.error.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          change.oldValue,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // New value
                  Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        size: 16,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          change.newValue,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Profile Change Model
class ProfileChange {
  final String fieldName;
  final String oldValue;
  final String newValue;
  final DateTime changedAt;

  ProfileChange({
    required this.fieldName,
    required this.oldValue,
    required this.newValue,
    required this.changedAt,
  });
}
