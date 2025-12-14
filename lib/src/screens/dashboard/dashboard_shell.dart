import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import 'dashboard_home_screen.dart';
import 'listings_screen.dart';
import 'markets_screen.dart';
import 'profile_screen.dart';

/// DashboardShell - Main navigation container with Center FAB
/// 
/// Implements the "Hybrid Dashboard" UX direction with "Magic Mic":
/// - 4 navigation items + Center FAB for listing
/// - 96dp FAB with pulse animation (per UX spec)
/// - Listing mode selector bottom sheet
class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  // Pulse animation for FAB
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Screens for each navigation destination
  final List<Widget> _screens = const [
    DashboardHomeScreen(),
    ListingsScreen(),
    MarketsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _setupPulseAnimation();
  }

  void _setupPulseAnimation() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    // index 2 is the placeholder for the center FAB notch
    if (index == 2) return;
    
    setState(() {
      // Adjust index for items after the center FAB
      _selectedIndex = index > 2 ? index - 1 : index;
    });
  }

  int _getNavIndex() {
    // Map screen index to nav bar index (accounting for center placeholder)
    return _selectedIndex >= 2 ? _selectedIndex + 1 : _selectedIndex;
  }

  void _showListingModeSelector() {
    HapticFeedback.mediumImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const ListingModeSelector(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      // Center FAB with notch
      floatingActionButton: ScaleTransition(
        scale: _pulseAnimation,
        child: SizedBox(
          width: 72,
          height: 72,
          child: FloatingActionButton(
            onPressed: _showListingModeSelector,
            backgroundColor: AppColors.secondary,
            elevation: 8,
            shape: const CircleBorder(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.mic, size: 28, color: Colors.white),
                const SizedBox(height: 2),
                Text(
                  'List',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // Bottom Navigation with notch
      bottomNavigationBar: BottomAppBar(
        height: 80,
        color: Colors.white,
        elevation: 0,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Home
            _NavItem(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              label: 'Home',
              isSelected: _selectedIndex == 0,
              onTap: () => setState(() => _selectedIndex = 0),
            ),
            // Listings
            _NavItem(
              icon: Icons.list_alt_outlined,
              selectedIcon: Icons.list_alt,
              label: 'Listings',
              isSelected: _selectedIndex == 1,
              onTap: () => setState(() => _selectedIndex = 1),
            ),
            // Center spacer for FAB
            const SizedBox(width: 72),
            // Markets
            _NavItem(
              icon: Icons.storefront_outlined,
              selectedIcon: Icons.storefront,
              label: 'Markets',
              isSelected: _selectedIndex == 2,
              onTap: () => setState(() => _selectedIndex = 2),
            ),
            // Profile
            _NavItem(
              icon: Icons.person_outline,
              selectedIcon: Icons.person,
              label: 'Profile',
              isSelected: _selectedIndex == 3,
              onTap: () => setState(() => _selectedIndex = 3),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual navigation item
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 64,
        height: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pill indicator (MD3 style)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primarySelected : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected ? AppColors.secondary : AppColors.onSurfaceVariant,
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.secondary : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet for listing mode selection
class ListingModeSelector extends StatelessWidget {
  const ListingModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Title
              Text(
                'List Your Crop',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Choose how you want to list',
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              // Voice option (Primary - for AI farmers)
              _ListingModeCard(
                icon: Icons.mic,
                iconBackgroundColor: AppColors.secondary,
                title: 'Speak to List',
                subtitle: 'Say crop and quantity',
                isPrimary: true,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/voice-listing');
                },
              ),
              const SizedBox(height: AppSpacing.md),
              
              // Manual option (Secondary - for knowledge farmers)
              _ListingModeCard(
                icon: Icons.edit_note,
                iconBackgroundColor: AppColors.primaryContainer,
                title: 'Type to List',
                subtitle: 'Select crop from list',
                isPrimary: false,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/manual-listing');
                },
              ),
              
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card option for listing mode
class _ListingModeCard extends StatelessWidget {
  final IconData icon;
  final Color iconBackgroundColor;
  final String title;
  final String subtitle;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ListingModeCard({
    required this.icon,
    required this.iconBackgroundColor,
    required this.title,
    required this.subtitle,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? AppColors.secondaryContainer : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(
              color: isPrimary ? AppColors.secondary : AppColors.outlineVariant,
              width: isPrimary ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: isPrimary ? Colors.white : AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
