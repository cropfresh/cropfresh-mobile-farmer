import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

/// Read-Only Field Widget - Story 2.7
/// Displays non-editable fields with lock icon and info tooltip
class ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final IconData? prefixIcon;
  final String? infoMessage;

  const ReadOnlyField({
    super.key,
    required this.label,
    required this.value,
    this.prefixIcon,
    this.infoMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label with lock icon
          Row(
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.lock_outline_rounded,
                size: 14,
                color: AppColors.onSurfaceVariant,
              ),
              if (infoMessage != null) ...[
                const SizedBox(width: 4),
                Tooltip(
                  message: infoMessage!,
                  triggerMode: TooltipTriggerMode.tap,
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          // Value container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.outline.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                if (prefixIcon != null) ...[
                  Icon(
                    prefixIcon,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    value.isNotEmpty ? value : 'Not set',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
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
