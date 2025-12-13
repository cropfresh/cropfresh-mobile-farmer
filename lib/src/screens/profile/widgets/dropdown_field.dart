import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

/// Dropdown Field Widget - Story 2.7
/// Animated dropdown with M3 styling
class DropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) displayValue;
  final ValueChanged<T?>? onChanged;
  final IconData? prefixIcon;
  final bool isRequired;
  final String? hint;

  const DropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.displayValue,
    this.onChanged,
    this.prefixIcon,
    this.isRequired = false,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Row(
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isRequired)
                Text(
                  ' *',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.error,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Dropdown
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outline),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                hint: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Row(
                    children: [
                      if (prefixIcon != null) ...[
                        Icon(prefixIcon, color: AppColors.onSurfaceVariant, size: 20),
                        const SizedBox(width: 12),
                      ],
                      Text(
                        hint ?? 'Select $label',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                selectedItemBuilder: (context) => items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        if (prefixIcon != null) ...[
                          Icon(prefixIcon, color: AppColors.onSurfaceVariant, size: 20),
                          const SizedBox(width: 12),
                        ],
                        Text(
                          displayValue(item),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                items: items.map((item) {
                  return DropdownMenuItem<T>(
                    value: item,
                    child: Text(
                      displayValue(item),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
                icon: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                borderRadius: BorderRadius.circular(12),
                dropdownColor: AppColors.surfaceContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
