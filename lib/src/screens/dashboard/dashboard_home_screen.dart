import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';

/// DashboardHomeScreen - Main farmer dashboard home tab
/// 
/// Implements "Hybrid Dashboard" UX direction with:
/// - Greeting header with farmer name
/// - Quick stats row (earnings, listings, pending)
/// - Quick actions grid with "List Crop" CTA
/// - Recent listings carousel (placeholder)
class DashboardHomeScreen extends StatelessWidget {
  const DashboardHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Top App Bar with branding
          SliverAppBar(
            floating: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: Row(
              children: [
                Text(
                  'CropFresh',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '🌱',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            actions: [
              // Profile avatar
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primaryContainer,
                  child: Icon(
                    Icons.person,
                    size: 20,
                    color: AppColors.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPaddingHorizontal,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppSpacing.md),

                // Greeting Section
                const _GreetingHeader(),

                const SizedBox(height: AppSpacing.sectionGap),

                // Earnings Card (Hybrid Dashboard style)
                const _EarningsCard(),

                const SizedBox(height: AppSpacing.sectionGap),

                // Quick Actions Section
                const _QuickActionsSection(),

                const SizedBox(height: AppSpacing.sectionGap),

                // Recent Listings Section
                const _RecentListingsSection(),

                const SizedBox(height: AppSpacing.xxl),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/// Greeting header with time-based greeting and farmer name
class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_getGreeting()}, Farmer! 🙏',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          'Ready to sell your crops today?',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Earnings/Balance card with gradient background
class _EarningsCard extends StatelessWidget {
  const _EarningsCard();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/earnings'),
      borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.secondary, AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Total Earnings',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              '₹ 0',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Quick stats row
            Row(
              children: [
                _MiniStat(icon: Icons.check_circle, label: '0 Sold'),
                const SizedBox(width: AppSpacing.lg),
                _MiniStat(icon: Icons.pending_actions, label: '0 Pending'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniStat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.9)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

/// Quick Actions grid with large touch targets
class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Grid of action cards
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.mic,
                label: 'List Crop',
                subtitle: 'Voice / Photo',
                isPrimary: true,
                onTap: () {
                  // Navigate to voice listing (Story 3.1)
                  Navigator.pushNamed(context, '/voice-listing');
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _ActionCard(
                icon: Icons.trending_up,
                label: 'Market Prices',
                subtitle: 'Check rates',
                onTap: () {
                  // Switch to Markets tab
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.handshake,
                label: 'Matches',
                subtitle: 'View buyers',
                onTap: () {
                  // Navigate to matches screen (Story 3.5 Demo)
                  Navigator.pushNamed(context, '/matches');
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _ActionCard(
                icon: Icons.local_shipping_outlined,
                label: 'My Orders',
                subtitle: 'Track status',
                onTap: () {
                  // Navigate to orders screen (Story 3.6)
                  Navigator.pushNamed(context, '/orders');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? AppColors.secondaryContainer : Colors.white,
      borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
      elevation: isPrimary ? 2 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isPrimary
                      ? AppColors.secondary
                      : AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: isPrimary
                      ? Colors.white
                      : AppColors.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isPrimary
                      ? AppColors.onSecondaryContainer
                      : AppColors.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Recent listings carousel (placeholder for now)
class _RecentListingsSection extends StatelessWidget {
  const _RecentListingsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Listings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: TextStyle(color: AppColors.secondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        // Empty state
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
            border: Border.all(
              color: AppColors.outlineVariant,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: AppColors.outline,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'No listings yet',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Tap "List Crop" to create your first listing',
                style: TextStyle(
                  color: AppColors.outline,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
