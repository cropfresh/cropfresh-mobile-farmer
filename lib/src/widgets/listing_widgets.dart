import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../providers/listings_provider.dart';

/// CropFresh Listing Widgets - Story 3.9
/// 
/// Reusable widgets for listing management:
/// - ListingActionCard: Card with edit/cancel buttons
/// - CancelListingDialog: Confirmation dialog with reason selection
/// - GradeBadge: Quality grade display
/// - EditableQuantityField: Voice + manual quantity input

// ============================================================================
// LISTING ACTION CARD (AC1, AC10)
// ============================================================================

/// ListingActionCard - Enhanced listing card with edit/cancel actions
/// 
/// Features:
/// - 48dp touch targets for edit/cancel buttons (WCAG)
/// - Lock icon for non-editable listings (MATCHED, etc.)
/// - Semantic labels for accessibility
/// - Smooth micro-interactions
class ListingActionCard extends StatelessWidget {
  final CropListing listing;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final VoidCallback? onTap;

  const ListingActionCard({
    super.key,
    required this.listing,
    this.onEdit,
    this.onCancel,
    this.onTap,
  });

  bool get _isEditable => listing.status == ListingStatus.active;
  bool get _isLocked => listing.status == ListingStatus.matched ||
      listing.status == ListingStatus.completed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '${listing.produceName}, ${listing.quantity} ${listing.unit}, '
          'Grade ${listing.qualityGrade}, ${listing.status.name}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: _isLocked
              ? Border.all(color: AppColors.outline.withValues(alpha: 0.2), width: 1)
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  _buildProduceIcon(),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _buildDetails(context)),
                  const SizedBox(width: AppSpacing.sm),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProduceIcon() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: _isLocked ? null : AppColors.successGradient,
        color: _isLocked ? AppColors.outlineVariant : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          listing.produceEmoji,
          style: TextStyle(
            fontSize: 28,
            color: _isLocked ? Colors.grey : null,
          ),
        ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row 1: Name + Status
        Row(
          children: [
            Expanded(
              child: Text(
                listing.produceName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _isLocked ? AppColors.onSurfaceVariant : AppColors.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            StatusBadge(status: listing.status),
          ],
        ),
        const SizedBox(height: 6),
        
        // Row 2: Quantity + Grade
        Row(
          children: [
            Text(
              '${listing.quantity.toStringAsFixed(listing.quantity == listing.quantity.roundToDouble() ? 0 : 1)} ${listing.unit}',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            GradeBadge(grade: listing.qualityGrade),
          ],
        ),
        const SizedBox(height: 4),
        
        // Row 3: Price
        if (listing.estimatedPrice != null)
          Text(
            '₹${listing.estimatedPrice!.toStringAsFixed(0)} estimated',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (_isLocked) {
      return Semantics(
        label: 'Locked, cannot edit or cancel',
        child: Container(
          width: AppSpacing.minTouchTarget,
          height: AppSpacing.minTouchTarget,
          decoration: BoxDecoration(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.lock_outline,
            color: Colors.grey,
            size: 20,
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Edit Button
        _ActionButton(
          icon: Icons.edit_outlined,
          tooltip: 'Edit listing',
          semanticLabel: 'Edit ${listing.produceName} listing',
          onPressed: _isEditable ? onEdit : null,
          color: AppColors.secondary,
        ),
        const SizedBox(height: 8),
        // Cancel Button  
        _ActionButton(
          icon: Icons.close,
          tooltip: 'Cancel listing',
          semanticLabel: 'Cancel ${listing.produceName} listing',
          onPressed: _isEditable ? onCancel : null,
          color: AppColors.error,
        ),
      ],
    );
  }
}

// ============================================================================
// ACTION BUTTON (48dp touch target)
// ============================================================================

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.semanticLabel,
    this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    
    return Semantics(
      button: true,
      enabled: isEnabled,
      label: semanticLabel,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? () {
              HapticFeedback.lightImpact();
              onPressed?.call();
            } : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: AppSpacing.minTouchTarget,
              height: AppSpacing.minTouchTarget,
              decoration: BoxDecoration(
                color: isEnabled 
                    ? color.withValues(alpha: 0.1)
                    : AppColors.disabledOverlay,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isEnabled ? color : AppColors.outline,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// CANCEL LISTING DIALOG (AC7, AC8, AC9, AC10)
// ============================================================================

/// CancelListingResult - Result from cancel dialog
class CancelListingResult {
  final bool confirmed;
  final CancellationReason? reason;

  CancelListingResult({required this.confirmed, this.reason});
}

/// CancelListingDialog - Confirmation with reason selection
/// 
/// Features:
/// - Clear destructive action styling (red)
/// - Optional reason selection for analytics
/// - Voice accessibility support
/// - Restriction message display
class CancelListingDialog extends StatefulWidget {
  final CropListing listing;
  final String? restrictionMessage;

  const CancelListingDialog({
    super.key,
    required this.listing,
    this.restrictionMessage,
  });

  /// Show the dialog and return result
  static Future<CancelListingResult?> show(
    BuildContext context, {
    required CropListing listing,
    String? restrictionMessage,
  }) {
    return showDialog<CancelListingResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CancelListingDialog(
        listing: listing,
        restrictionMessage: restrictionMessage,
      ),
    );
  }

  @override
  State<CancelListingDialog> createState() => _CancelListingDialogState();
}

class _CancelListingDialogState extends State<CancelListingDialog>
    with SingleTickerProviderStateMixin {
  CancellationReason? _selectedReason;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  bool get _isRestricted => widget.restrictionMessage != null;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: _isRestricted 
            ? _buildRestrictedContent()
            : _buildCancelContent(),
      ),
    );
  }

  Widget _buildRestrictedContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.errorContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.block,
            size: 32,
            color: AppColors.error,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Cannot Cancel',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.restrictionMessage!,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Contact support if you need help.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: AppSpacing.recommendedTouchTarget,
          child: FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.secondary,
            ),
            child: const Text('Got it'),
          ),
        ),
      ],
    );
  }

  Widget _buildCancelContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Cancel Listing?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Listing summary
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(widget.listing.produceEmoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${widget.listing.quantity.toStringAsFixed(0)}${widget.listing.unit} ${widget.listing.produceName}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Reason selection (optional)
        Text(
          'Why are you cancelling? (optional)',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ...CancellationReason.values.map((reason) => _buildReasonOption(reason)),
        const SizedBox(height: 24),
        
        // Buttons
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: AppSpacing.recommendedTouchTarget,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(
                    context,
                    CancelListingResult(confirmed: false),
                  ),
                  child: const Text('Keep Listing'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: AppSpacing.recommendedTouchTarget,
                child: FilledButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(
                      context,
                      CancelListingResult(
                        confirmed: true,
                        reason: _selectedReason,
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  child: const Text('Yes, Cancel'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReasonOption(CancellationReason reason) {
    final isSelected = _selectedReason == reason;
    
    return Semantics(
      selected: isSelected,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedReason = isSelected ? null : reason;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.outline,
                    width: 2,
                  ),
                  color: isSelected ? AppColors.primary : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                reason.label,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// GRADE BADGE
// ============================================================================

class GradeBadge extends StatelessWidget {
  final String grade;

  const GradeBadge({super.key, required this.grade});

  Color get _color {
    switch (grade.toUpperCase()) {
      case 'A':
        return const Color(0xFF2E7D32); // Green
      case 'B':
        return const Color(0xFFF57C00); // Orange
      case 'C':
        return const Color(0xFFE65100); // Deep Orange
      case 'D':
        return const Color(0xFFB3261E); // Red
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Grade $grade',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}

// ============================================================================
// STATUS BADGE
// ============================================================================

class StatusBadge extends StatelessWidget {
  final ListingStatus status;

  const StatusBadge({super.key, required this.status});

  (Color, String, IconData?) get _info {
    switch (status) {
      case ListingStatus.draft:
        return (Colors.grey, 'Draft', Icons.edit_note);
      case ListingStatus.active:
        return (const Color(0xFF2E7D32), 'Active', Icons.check_circle_outline);
      case ListingStatus.matched:
        return (const Color(0xFF1976D2), 'Matched', Icons.handshake_outlined);
      case ListingStatus.completed:
        return (const Color(0xFF7B1FA2), 'Done', Icons.verified);
      case ListingStatus.expired:
        return (AppColors.error, 'Expired', Icons.schedule);
      case ListingStatus.cancelled:
        return (AppColors.error, 'Cancelled', Icons.cancel_outlined);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (color, label, icon) = _info;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SUCCESS ANIMATION (AC6, AC9)
// ============================================================================

class SuccessAnimation extends StatefulWidget {
  final String message;
  final String? subMessage;
  final VoidCallback? onComplete;

  const SuccessAnimation({
    super.key,
    required this.message,
    this.subMessage,
    this.onComplete,
  });

  @override
  State<SuccessAnimation> createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<SuccessAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _checkAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1.0)),
    );
    
    _checkAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _controller.forward().then((_) {
      Future.delayed(const Duration(seconds: 2), () {
        widget.onComplete?.call();
      });
    });
    
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _scaleAnim,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.successGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: AnimatedBuilder(
                animation: _checkAnim,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _CheckPainter(_checkAnim.value),
                    size: const Size(100, 100),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              children: [
                Text(
                  widget.message,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (widget.subMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.subMessage!,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  final double progress;

  _CheckPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    
    // Checkmark path
    final start = Offset(center.dx - 18, center.dy);
    final mid = Offset(center.dx - 5, center.dy + 15);
    final end = Offset(center.dx + 20, center.dy - 12);

    if (progress > 0) {
      path.moveTo(start.dx, start.dy);
      if (progress < 0.5) {
        final t = progress * 2;
        final current = Offset.lerp(start, mid, t)!;
        path.lineTo(current.dx, current.dy);
      } else {
        path.lineTo(mid.dx, mid.dy);
        final t = (progress - 0.5) * 2;
        final current = Offset.lerp(mid, end, t)!;
        path.lineTo(current.dx, current.dy);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) => oldDelegate.progress != progress;
}
