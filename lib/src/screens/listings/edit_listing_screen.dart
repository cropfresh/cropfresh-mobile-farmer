import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../providers/listings_provider.dart';
import '../../widgets/listing_widgets.dart';

/// EditListingScreen - Story 3.9 (AC2-6, AC10)
/// 
/// Allows farmers to update:
/// - Quantity (voice + manual input)
/// - Photo (retake with AI grading)
/// - Drop-off time window
/// 
/// Features:
/// - Pre-filled form with current values
/// - Real-time earnings recalculation
/// - Voice input support
/// - Confirmation dialog with change summary
/// - WCAG 2.2 AA+ compliance
class EditListingScreen extends StatefulWidget {
  final CropListing listing;

  const EditListingScreen({
    super.key,
    required this.listing,
  });

  static Future<bool?> show(BuildContext context, CropListing listing) {
    return Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EditListingScreen(listing: listing),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  late TextEditingController _quantityController;
  late double _originalQuantity;
  late double _currentQuantity;
  late String _currentGrade;
  String? _newPhotoPath;
  String? _selectedTimeSlot;
  bool _isLoading = false;
  bool _hasChanges = false;

  // Calculated values
  double get _pricePerKg => (widget.listing.estimatedPrice ?? 0) / _originalQuantity;
  double get _estimatedEarnings => _currentQuantity * _pricePerKg;

  @override
  void initState() {
    super.initState();
    _originalQuantity = widget.listing.quantity;
    _currentQuantity = widget.listing.quantity;
    _currentGrade = widget.listing.qualityGrade;
    _quantityController = TextEditingController(
      text: _originalQuantity.toStringAsFixed(
        _originalQuantity == _originalQuantity.roundToDouble() ? 0 : 1,
      ),
    );
    _quantityController.addListener(_onQuantityChanged);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _onQuantityChanged() {
    final value = double.tryParse(_quantityController.text) ?? 0;
    setState(() {
      _currentQuantity = value;
      _hasChanges = value != _originalQuantity || 
          _newPhotoPath != null || 
          _selectedTimeSlot != null;
    });
  }

  String? get _quantityError {
    if (_currentQuantity <= 0) {
      return 'Quantity must be greater than 0';
    }
    if (_currentQuantity > _originalQuantity) {
      return 'Cannot increase beyond ${_originalQuantity.toStringAsFixed(0)} ${widget.listing.unit}';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _handleBack(),
          tooltip: 'Cancel editing',
        ),
        title: Text(
          'Edit Listing',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_hasChanges && _quantityError == null)
            TextButton.icon(
              onPressed: _isLoading ? null : _handleSave,
              icon: const Icon(Icons.check),
              label: const Text('Save'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildListingHeader(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildQuantitySection(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildPhotoSection(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTimeSlotSection(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildEarningsSummary(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildListingHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: AppColors.successGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                widget.listing.produceEmoji,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.listing.produceName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    GradeBadge(grade: _currentGrade),
                    const SizedBox(width: 8),
                    StatusBadge(status: widget.listing.status),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySection() {
    return _SectionCard(
      title: 'Quantity',
      subtitle: 'Original: ${_originalQuantity.toStringAsFixed(0)} ${widget.listing.unit}',
      icon: Icons.scale,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _quantityController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    suffix: Text(
                      widget.listing.unit,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorText: _quantityError,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Voice input button
              Semantics(
                button: true,
                label: 'Voice input for quantity',
                child: Material(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: _handleVoiceInput,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: AppSpacing.recommendedTouchTarget,
                      height: AppSpacing.recommendedTouchTarget,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.mic,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_currentQuantity != _originalQuantity && _quantityError == null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Quantity changed from ${_originalQuantity.toStringAsFixed(0)} to ${_currentQuantity.toStringAsFixed(0)} ${widget.listing.unit}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return _SectionCard(
      title: 'Photo',
      subtitle: 'Retake to update quality grade',
      icon: Icons.camera_alt,
      child: Column(
        children: [
          if (_newPhotoPath != null)
            Container(
              height: 120,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.photo, size: 48, color: Colors.grey),
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: AppSpacing.recommendedTouchTarget,
            child: OutlinedButton.icon(
              onPressed: _handleRetakePhoto,
              icon: const Icon(Icons.camera_alt_outlined),
              label: Text(_newPhotoPath == null ? 'Retake Photo' : 'Take Another'),
            ),
          ),
          if (_newPhotoPath != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'New photo will be graded by AI',
                      style: TextStyle(fontSize: 13, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeSlotSection() {
    // Mock time slots - in real app, fetch from API
    final timeSlots = [
      '07:00 - 09:00',
      '09:00 - 11:00',
      '11:00 - 13:00',
      '14:00 - 16:00',
    ];

    return _SectionCard(
      title: 'Drop-off Time',
      subtitle: 'Select a new time window',
      icon: Icons.schedule,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: timeSlots.map((slot) {
          final isSelected = _selectedTimeSlot == slot;
          
          return Semantics(
            button: true,
            selected: isSelected,
            label: 'Time slot $slot',
            child: Material(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedTimeSlot = isSelected ? null : slot;
                    _hasChanges = _currentQuantity != _originalQuantity ||
                        _newPhotoPath != null ||
                        _selectedTimeSlot != null;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.outline,
                    ),
                  ),
                  child: Text(
                    slot,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.onSurface,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEarningsSummary() {
    final hasQuantityChange = _currentQuantity != _originalQuantity;
    final originalEarnings = widget.listing.estimatedPrice ?? 0;
    final earningsChange = _estimatedEarnings - originalEarnings;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estimated Earnings',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              Text(
                '₹${_estimatedEarnings.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (hasQuantityChange && _quantityError == null) ...[
            const Divider(color: Colors.white24, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Change',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  '${earningsChange >= 0 ? '+' : ''}₹${earningsChange.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: earningsChange >= 0 ? Colors.white : Colors.redAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: AppSpacing.recommendedTouchTarget,
          child: FilledButton(
            onPressed: _hasChanges && _quantityError == null ? _handleSave : null,
            child: const Text('Save Changes'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: AppSpacing.recommendedTouchTarget,
          child: OutlinedButton(
            onPressed: () => _handleBack(),
            child: const Text('Cancel'),
          ),
        ),
      ],
    );
  }

  Future<void> _handleVoiceInput() async {
    HapticFeedback.lightImpact();
    // TODO: Implement voice input with speech_to_text
    // For now, show a placeholder dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice input: Say the quantity (e.g., "30 kilos")'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleRetakePhoto() async {
    HapticFeedback.lightImpact();
    // TODO: Implement camera flow from Story 3.2
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Camera will open to retake photo'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleBack() async {
    if (_hasChanges) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text('You have unsaved changes. Are you sure you want to go back?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep Editing'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Discard'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }
    if (mounted) Navigator.pop(context, false);
  }

  Future<void> _handleSave() async {
    // Show confirmation dialog
    final changes = <String>[];
    if (_currentQuantity != _originalQuantity) {
      changes.add('Quantity: ${_originalQuantity.toStringAsFixed(0)} → ${_currentQuantity.toStringAsFixed(0)} ${widget.listing.unit}');
    }
    if (_newPhotoPath != null) {
      changes.add('Photo: Updated (pending AI grading)');
    }
    if (_selectedTimeSlot != null) {
      changes.add('Drop-off: $_selectedTimeSlot');
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Listing?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Changes:'),
            const SizedBox(height: 8),
            ...changes.map((c) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(c, style: const TextStyle(fontSize: 14))),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Call API to update listing
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      HapticFeedback.heavyImpact();
      
      if (mounted) {
        // Show success and pop
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Listing updated successfully!'),
            backgroundColor: AppColors.secondary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// ============================================================================
// SECTION CARD HELPER
// ============================================================================

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
