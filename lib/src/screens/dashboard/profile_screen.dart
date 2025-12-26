import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../ratings/ratings_summary_screen.dart';

/// ProfileScreen - Farmer profile and settings tab
/// 
/// Shows farmer profile info with logout button.
/// Settings and account management will be added in future stories.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
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
            children: [
              const SizedBox(height: AppSpacing.md),
              
              // Profile header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Column(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.primaryContainer,
                      child: Icon(
                        Icons.person,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Name placeholder
                    Text(
                      'Farmer',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    // Phone number placeholder
                    Text(
                      '+91 XXXXX XXXXX',
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Verified badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Verified Farmer',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sectionGap),

              // Menu items
              _ProfileMenuItem(
                icon: Icons.edit_outlined,
                label: 'Edit Profile',
                onTap: () {},
              ),
              _ProfileMenuItem(
                icon: Icons.star_outline,
                label: 'My Ratings',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RatingsSummaryScreen(),
                    ),
                  );
                },
              ),
              _ProfileMenuItem(
                icon: Icons.agriculture_outlined,
                label: 'Farm Details',
                onTap: () {},
              ),
              _ProfileMenuItem(
                icon: Icons.account_balance_outlined,
                label: 'Payment Settings',
                onTap: () {},
              ),
              _ProfileMenuItem(
                icon: Icons.language,
                label: 'Language / ಭಾಷೆ',
                onTap: () {},
              ),
              _ProfileMenuItem(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                onTap: () {},
              ),
              _ProfileMenuItem(
                icon: Icons.help_outline,
                label: 'Help & Support',
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.sectionGap),

              // Logout button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // App version
              Text(
                'CropFresh v1.0.0',
                style: TextStyle(
                  color: AppColors.outline,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to welcome/login screen
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/welcome',
                (route) => false,
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.outlineVariant),
              borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
