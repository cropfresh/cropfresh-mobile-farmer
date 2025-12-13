import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Reusable Step Progress Indicator Widget
/// Displays "Step X of Y" with Material 3 LinearProgressIndicator and optional label
/// Used across all onboarding screens (Story 2.1 - 10-step flow)
class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String? label;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 5,
    this.label,
  }) : assert(currentStep > 0 && currentStep <= totalSteps);

  @override
  Widget build(BuildContext context) {
    final progress = currentStep / totalSteps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Step text with optional label
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step $currentStep of $totalSteps',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (label != null)
              Text(
                label!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
