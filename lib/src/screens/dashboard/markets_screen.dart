import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';

/// MarketsScreen - Market prices and discovery tab
/// 
/// Placeholder screen showing teaser for market rates feature.
/// Will be fully implemented in future epics.
class MarketsScreen extends StatelessWidget {
  const MarketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Prices'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Live Mandi rates coming soon! Check back for real-time prices.',
                        style: TextStyle(
                          color: AppColors.onPrimaryContainer,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sectionGap),

              // Sample market rates (placeholder data)
              Text(
                'Today\'s Rates (Sample)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Price cards
              _PriceCard(
                cropName: 'Tomato',
                cropEmoji: '🍅',
                price: '₹24/kg',
                trend: '+5%',
                isUp: true,
              ),
              const SizedBox(height: AppSpacing.sm),
              _PriceCard(
                cropName: 'Onion',
                cropEmoji: '🧅',
                price: '₹18/kg',
                trend: '-2%',
                isUp: false,
              ),
              const SizedBox(height: AppSpacing.sm),
              _PriceCard(
                cropName: 'Potato',
                cropEmoji: '🥔',
                price: '₹15/kg',
                trend: '+1%',
                isUp: true,
              ),
              const SizedBox(height: AppSpacing.sm),
              _PriceCard(
                cropName: 'Carrot',
                cropEmoji: '🥕',
                price: '₹30/kg',
                trend: '+8%',
                isUp: true,
              ),
              const SizedBox(height: AppSpacing.sm),
              _PriceCard(
                cropName: 'Cabbage',
                cropEmoji: '🥬',
                price: '₹12/kg',
                trend: '-3%',
                isUp: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final String cropName;
  final String cropEmoji;
  final String price;
  final String trend;
  final bool isUp;

  const _PriceCard({
    required this.cropName,
    required this.cropEmoji,
    required this.price,
    required this.trend,
    required this.isUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          // Crop emoji
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                cropEmoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Crop name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cropName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Kolar Mandi',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Price and trend
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isUp ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 12,
                    color: isUp ? AppColors.primary : AppColors.error,
                  ),
                  Text(
                    trend,
                    style: TextStyle(
                      color: isUp ? AppColors.primary : AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
