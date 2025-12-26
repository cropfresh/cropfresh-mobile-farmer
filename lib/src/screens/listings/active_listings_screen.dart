import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../providers/listings_provider.dart';
import '../../widgets/listing_widgets.dart';
import 'edit_listing_screen.dart';

/// ActiveListingsScreen - Story 3.9 (AC1, AC10)
/// 
/// Displays farmer's active listings with edit/cancel functionality.
/// 
/// Features:
/// - Pull-to-refresh
/// - Empty state with CTA
/// - TTS announcements for accessibility
/// - Edit/Cancel buttons on each listing card
/// - Lock icon for non-editable listings (MATCHED, etc.)
/// - Smooth animations and micro-interactions
class ActiveListingsScreen extends StatefulWidget {
  const ActiveListingsScreen({super.key});

  @override
  State<ActiveListingsScreen> createState() => _ActiveListingsScreenState();
}

class _ActiveListingsScreenState extends State<ActiveListingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _refreshIconController;

  @override
  void initState() {
    super.initState();
    _refreshIconController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Load listings on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadListings();
    });
  }

  @override
  void dispose() {
    _refreshIconController.dispose();
    super.dispose();
  }

  Future<void> _loadListings() async {
    _refreshIconController.repeat();
    try {
      await context.read<ListingsProvider>().loadListings();
    } finally {
      _refreshIconController.stop();
      _refreshIconController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(context),
      body: Consumer<ListingsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return _buildLoadingState();
          }

          final activeListings = provider.listings.where((l) => 
            l.status == ListingStatus.active ||
            l.status == ListingStatus.matched
          ).toList();

          if (activeListings.isEmpty) {
            return _buildEmptyState(context);
          }

          return _buildListingsView(context, activeListings, provider);
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'Active Listings',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),
      actions: [
        RotationTransition(
          turns: _refreshIconController,
          child: IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadListings,
            tooltip: 'Refresh listings',
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading your listings...',
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppColors.successGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 56,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No Active Listings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your active crop listings will appear here.\nTap the mic button to create a listing!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_downward, color: AppColors.secondary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Create your first listing',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingsView(
    BuildContext context,
    List<CropListing> listings,
    ListingsProvider provider,
  ) {
    return RefreshIndicator(
      onRefresh: _loadListings,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: listings.length + 1, // +1 for header
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildHeader(listings.length);
          }
          
          final listing = listings[index - 1];
          return _buildListingCard(context, listing, provider);
        },
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Text(
            '$count listing${count != 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, size: 14, color: AppColors.secondary),
                const SizedBox(width: 4),
                Text(
                  'Tap to view details',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListingCard(
    BuildContext context,
    CropListing listing,
    ListingsProvider provider,
  ) {
    return ListingActionCard(
      listing: listing,
      onTap: () => _showListingDetails(listing),
      onEdit: () => _handleEdit(listing),
      onCancel: () => _handleCancel(context, listing, provider),
    );
  }

  void _showListingDetails(CropListing listing) {
    // TODO: Navigate to listing details screen
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${listing.produceName} - ${listing.quantity} ${listing.unit}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleEdit(CropListing listing) async {
    HapticFeedback.lightImpact();
    
    final result = await EditListingScreen.show(context, listing);
    
    if (result == true) {
      // Refresh listings after successful edit
      _loadListings();
    }
  }

  Future<void> _handleCancel(
    BuildContext context,
    CropListing listing,
    ListingsProvider provider,
  ) async {
    HapticFeedback.lightImpact();
    
    // Capture context references before any async operations
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    
    // Check cancellation restrictions
    String? restrictionMessage;
    
    if (listing.status == ListingStatus.matched) {
      restrictionMessage = 'This listing is already matched with a buyer.';
    }
    // TODO: Check 2-hour time restriction with actual drop-off time
    
    final result = await CancelListingDialog.show(
      context,
      listing: listing,
      restrictionMessage: restrictionMessage,
    );

    if (result?.confirmed == true && mounted) {
      try {
        // Show loading indicator using navigator's context (avoids async context warning)
        if (mounted) {
          showDialog(
            context: navigator.context,
            barrierDismissible: false,
            builder: (ctx) => const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Cancel the listing
        await provider.cancelListing(listing.id, result!.reason);
        
        // Close loading dialog
        if (mounted) navigator.pop();
        
        // Show success message
        if (mounted) {
          HapticFeedback.heavyImpact();
          messenger.showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Listing cancelled successfully'),
                ],
              ),
              backgroundColor: AppColors.secondary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        // Close loading dialog
        if (mounted) navigator.pop();
        
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('Failed to cancel: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}
