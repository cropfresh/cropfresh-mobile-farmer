import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

/// Editable Field Widget - Story 2.7
/// Text field with view/edit modes, validation, and M3 styling
class EditableField extends StatelessWidget {
  final String label;
  final String value;
  final String? hint;
  final IconData? prefixIcon;
  final bool isEditing;
  final bool isRequired;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final int maxLines;

  const EditableField({
    super.key,
    required this.label,
    required this.value,
    this.hint,
    this.prefixIcon,
    this.isEditing = false,
    this.isRequired = false,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onTap,
    this.keyboardType,
    this.maxLines = 1,
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
          // Field
          if (isEditing)
            TextFormField(
              controller: controller,
              initialValue: controller == null ? value : null,
              onChanged: onChanged,
              onTap: onTap,
              keyboardType: keyboardType,
              maxLines: maxLines,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurface,
              ),
              decoration: InputDecoration(
                hintText: hint ?? 'Enter $label',
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                prefixIcon: prefixIcon != null
                    ? Icon(prefixIcon, color: AppColors.onSurfaceVariant)
                    : null,
                errorText: errorText,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.error),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            )
          else
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Row(
                  children: [
                    if (prefixIcon != null) ...[
                      Icon(prefixIcon, color: AppColors.onSurfaceVariant, size: 20),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        value.isNotEmpty ? value : (hint ?? 'Not set'),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: value.isNotEmpty
                              ? AppColors.onSurface
                              : AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    if (onTap != null)
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.onSurfaceVariant,
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
