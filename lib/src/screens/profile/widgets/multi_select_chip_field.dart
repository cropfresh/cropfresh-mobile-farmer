import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

/// Multi-Select Chip Field Widget - Story 2.7
/// Chip-based multi-select with M3 styling for crop types, days, etc.
class MultiSelectChipField extends StatelessWidget {
  final String label;
  final List<String> options;
  final List<String> selectedValues;
  final ValueChanged<List<String>>? onChanged;
  final bool isRequired;
  final int? maxSelections;

  const MultiSelectChipField({
    super.key,
    required this.label,
    required this.options,
    required this.selectedValues,
    this.onChanged,
    this.isRequired = false,
    this.maxSelections,
  });

  void _toggleSelection(String option) {
    if (onChanged == null) return;
    
    final newSelection = List<String>.from(selectedValues);
    if (newSelection.contains(option)) {
      newSelection.remove(option);
    } else {
      if (maxSelections != null && newSelection.length >= maxSelections!) {
        return; // Max reached
      }
      newSelection.add(option);
    }
    onChanged!(newSelection);
  }

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
              if (maxSelections != null)
                Text(
                  ' (max $maxSelections)',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Chips wrap
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = selectedValues.contains(option);
              return AnimatedScale(
                scale: isSelected ? 1.0 : 0.95,
                duration: const Duration(milliseconds: 150),
                child: FilterChip(
                  label: Text(
                    option,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) => _toggleSelection(option),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  checkmarkColor: AppColors.onPrimary,
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.outline,
                    width: isSelected ? 0 : 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  visualDensity: VisualDensity.compact,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
