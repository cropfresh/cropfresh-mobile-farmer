import 'package:flutter/material.dart';

/// Reusable Step Progress Indicator Widget
/// Displays "Step X of 3" with Material 3 LinearProgressIndicator
/// Used across Phone Entry (1/3), OTP (2/3), Profile (3/3)
class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
  }) : assert(currentStep > 0 && currentStep <= totalSteps);

  @override
  Widget build(BuildContext context) {
    final progress = currentStep / totalSteps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Step text
        Text(
          'Step $currentStep of $totalSteps',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),

        // Progress bar
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary, // Orange
          ),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }
}
