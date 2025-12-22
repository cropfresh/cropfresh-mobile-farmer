import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_typography.dart';
import '../../models/match_models.dart';
import '../../widgets/match_widgets.dart';
import '../../widgets/match_notification_widgets.dart';

/// Match Details Screen - Story 3.5 (AC: 2, 3, 4, 5, 8)
/// 
/// Displays full match details with accept/reject actions.
/// Includes TTS voice announcement for accessibility (AC8).
/// Enhanced with staggered entrance animations per UX spec.
class MatchDetailsScreen extends StatefulWidget {
  final Match match;
  final Future<void> Function(bool acceptPartial)? onAccept;
  final Future<void> Function(RejectionReason reason, String? otherText)? onReject;

  const MatchDetailsScreen({
    super.key,
    required this.match,
    this.onAccept,
    this.onReject,
  });

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen>
    with TickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  bool _isLoading = false;
  bool _ttsAnnounced = false;

  // Staggered animation controllers
  late AnimationController _slideController;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initAnimations();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Create staggered animations for 4 items (timer, price, quantity, buyer)
    _slideAnimations = List.generate(4, (index) {
      final start = index * 0.15;
      final end = start + 0.4;
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOutCubic),
      ));
    });

    _fadeAnimations = List.generate(4, (index) {
      final start = index * 0.15;
      final end = start + 0.4;
      return Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _slideController,
        curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOut),
      ));
    });

    _slideController.forward();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-IN');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    
    // Announce match details after screen loads (AC8)
    if (!_ttsAnnounced) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        await _tts.speak(widget.match.ttsAnnouncement);
        _ttsAnnounced = true;
      }
    }
  }

  @override
  void dispose() {
    _tts.stop();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _handleAccept() async {
    if (widget.match.isPartial) {
      final result = await _showPartialMatchDialog();
      if (result != null && widget.onAccept != null) {
        await _executeWithLoading(() => widget.onAccept!(result));
      }
    } else {
      final confirmed = await _showAcceptConfirmationDialog();
      if (confirmed && widget.onAccept != null) {
        await _executeWithLoading(() => widget.onAccept!(false));
      }
    }
  }

  Future<void> _handleReject() async {
    final result = await _showRejectDialog();
    if (result != null && widget.onReject != null) {
      await _executeWithLoading(() => widget.onReject!(result.$1, result.$2));
    }
  }

  Future<void> _executeWithLoading(Future<void> Function() action) async {
    setState(() => _isLoading = true);
    try {
      await action();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _showAcceptConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.check_circle, color: AppColors.secondary),
            ),
            const SizedBox(width: 12),
            const Text('Accept Match'),
          ],
        ),
        content: Text(
          'Accept this match for ${widget.match.formattedTotal}?\n\n'
          'You will need to deliver to the drop point by the scheduled time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.secondary),
            child: const Text('Accept'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<bool?> _showPartialMatchDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.pie_chart, color: Colors.orange),
            ),
            const SizedBox(width: 12),
            const Text('Partial Match'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The buyer wants ${widget.match.formattedQuantity} of your '
              '${widget.match.listing.quantityKg.toStringAsFixed(0)} kg listing.',
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${widget.match.remainingQuantity.toStringAsFixed(0)} kg will remain active.',
                      style: AppTypography.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.secondary),
            child: Text('Accept ${widget.match.formattedQuantity}'),
          ),
        ],
      ),
    );
  }

  Future<(RejectionReason, String?)?> _showRejectDialog() async {
    RejectionReason? selectedReason;
    final otherController = TextEditingController();

    return await showDialog<(RejectionReason, String?)>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.close, color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(width: 12),
              const Text('Reject Match'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Please select a reason:'),
                const SizedBox(height: AppSpacing.sm),
                ...RejectionReason.values.map((reason) => RadioListTile<RejectionReason>(
                  title: Text(reason.label),
                  value: reason,
                  groupValue: selectedReason,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    setDialogState(() => selectedReason = value);
                  },
                )),
                if (selectedReason == RejectionReason.other) ...[
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: otherController,
                    decoration: InputDecoration(
                      hintText: 'Enter reason...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 2,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: selectedReason != null
                  ? () => Navigator.pop(
                      context,
                      (selectedReason!, 
                       selectedReason == RejectionReason.other 
                         ? otherController.text 
                         : null),
                    )
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Reject'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedItem(int index, Widget child) {
    return SlideTransition(
      position: _slideAnimations[index],
      child: FadeTransition(
        opacity: _fadeAnimations[index],
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Match Details'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
      ),
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPaddingHorizontal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.sm),
                
                // Expiry timer at top (animated) - Uses LIVE countdown
                _buildAnimatedItem(
                  0,
                  Center(
                    child: LiveCountdownTimer(
                      expiresAt: widget.match.expiresAt,
                      showIcon: true,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Price card (animated)
                _buildAnimatedItem(
                  1,
                  PriceCard(
                    totalAmount: widget.match.totalAmount,
                    pricePerKg: widget.match.pricePerKg,
                    quantityKg: widget.match.quantityRequested,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Quantity card (animated)
                _buildAnimatedItem(
                  2,
                  QuantityCard(
                    quantityRequested: widget.match.quantityRequested,
                    listingQuantity: widget.match.listing.quantityKg,
                    cropEmoji: widget.match.listing.cropEmoji,
                    cropName: widget.match.listing.cropType,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Buyer info card (animated)
                _buildAnimatedItem(
                  3,
                  BuyerInfoCard(
                    buyer: widget.match.buyer,
                    deliveryDate: widget.match.deliveryDate,
                  ),
                ),
                
                // Bottom spacing for action buttons
                const SizedBox(height: 130),
              ],
            ),
          ),

          // Action buttons at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Reject button
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: _isLoading || !widget.match.isPending 
                              ? null 
                              : _handleReject,
                          icon: const Icon(Icons.close, size: 20),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.error,
                            side: BorderSide(color: colorScheme.error),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    // Accept button
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 56,
                        child: FilledButton.icon(
                          onPressed: _isLoading || !widget.match.isPending 
                              ? null 
                              : _handleAccept,
                          icon: const Icon(Icons.check, size: 20),
                          label: Text(
                            widget.match.isPartial 
                                ? 'Accept ${widget.match.formattedQuantity}'
                                : 'Accept Match',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
