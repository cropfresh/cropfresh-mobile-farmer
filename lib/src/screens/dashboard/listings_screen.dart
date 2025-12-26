import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../providers/listings_provider.dart';
import '../../widgets/listing_widgets.dart';
import '../listings/edit_listing_screen.dart';

/// ListingsScreen - Farmer's crop listings tab
/// 
/// Shows all listings with status badges (Active, Draft, Matched)
/// Empty state with CTA to create first listing
class ListingsScreen extends StatefulWidget {
  const ListingsScreen({super.key});

  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  @override
  void initState() {
    super.initState();
    // Load listings when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListingsProvider>().loadListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ListingsProvider>().loadListings(),
          ),
        ],
      ),
      body: Consumer<ListingsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!provider.hasListings) {
            return _buildEmptyState(context);
          }

          return _buildListingsList(context, provider.listings);
        },
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
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 56,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No Listings Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your crop listings will appear here.\nTap the mic button to create your first listing!',
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
                    'Tap the center mic button',
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

  Widget _buildListingsList(BuildContext context, List<CropListing> listings) {
    return RefreshIndicator(
      onRefresh: () => context.read<ListingsProvider>().loadListings(),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: listings.length,
        itemBuilder: (context, index) {
          final listing = listings[index];
          return ListingActionCard(
            listing: listing,
            onTap: () => _showListingDetails(listing),
            onEdit: () => _handleEdit(listing),
            onCancel: () => _handleCancel(context, listing),
          );
        },
      ),
    );
  }

  void _showListingDetails(CropListing listing) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${listing.produceName} - ${listing.quantity} ${listing.unit} • Grade ${listing.qualityGrade}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleEdit(CropListing listing) async {
    HapticFeedback.lightImpact();
    final result = await EditListingScreen.show(context, listing);
    if (result == true && mounted) {
      context.read<ListingsProvider>().loadListings();
    }
  }

  Future<void> _handleCancel(BuildContext ctx, CropListing listing) async {
    HapticFeedback.lightImpact();
    final provider = ctx.read<ListingsProvider>();
    
    // Capture references before async
    final navigator = Navigator.of(ctx);
    final messenger = ScaffoldMessenger.of(ctx);
    
    // Check restrictions
    String? restrictionMessage;
    if (listing.status == ListingStatus.matched) {
      restrictionMessage = 'This listing is already matched with a buyer.';
    }
    
    final result = await CancelListingDialog.show(
      ctx,
      listing: listing,
      restrictionMessage: restrictionMessage,
    );

    if (result?.confirmed == true && mounted) {
      try {
        showDialog(
          context: navigator.context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );
        
        await provider.cancelListing(listing.id, result!.reason);
        
        if (mounted) navigator.pop();
        if (mounted) {
          HapticFeedback.heavyImpact();
          messenger.showSnackBar(
            SnackBar(
              content: const Text('Listing cancelled successfully'),
              backgroundColor: AppColors.secondary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
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

