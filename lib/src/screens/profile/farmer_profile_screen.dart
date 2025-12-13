import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import 'widgets/widgets.dart';

/// Farmer Profile Screen - Story 2.7 (AC1)
/// Complete profile management for farmers with editable fields,
/// validation, and change tracking.
class FarmerProfileScreen extends StatefulWidget {
  const FarmerProfileScreen({super.key});

  @override
  State<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  // Form state
  bool _isEditing = false;
  bool _hasChanges = false;
  bool _isSaving = false;

  // User data (would come from API in production)
  String _userName = 'Ramesh Kumar';
  String _phoneNumber = '+91 98765 43210';
  
  // Editable fields
  String _selectedLanguage = 'Kannada';
  List<String> _selectedCropTypes = ['Vegetables', 'Fruits'];
  String _selectedDistrict = 'Bangalore Rural';
  String _selectedTaluk = 'Devanahalli';
  String _selectedVillage = 'Sadahalli';
  String _upiId = 'ramesh@okaxis';
  String _bankAccount = '';
  String _ifscCode = '';
  String _selectedDropPoint = 'Sadahalli Village Center';

  // Options
  final List<String> _languages = ['Kannada', 'Hindi', 'English', 'Tamil', 'Telugu'];
  final List<String> _cropTypes = ['Vegetables', 'Fruits', 'Grains', 'Flowers', 'Others'];
  final List<String> _districts = ['Bangalore Rural', 'Bangalore Urban', 'Mysore', 'Mandya', 'Tumkur'];
  final List<String> _taluks = ['Devanahalli', 'Hoskote', 'Nelamangala', 'Doddaballapur'];
  final List<String> _villages = ['Sadahalli', 'Kodigehalli', 'Begur', 'Budigere'];
  final List<String> _dropPoints = ['Sadahalli Village Center', 'Kodigehalli Market', 'Devanahalli Hub'];

  void _toggleEdit() {
    HapticFeedback.lightImpact();
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _hasChanges = false;
      }
    });
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Future<void> _saveChanges() async {
    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isSaving = false;
      _isEditing = false;
      _hasChanges = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('Profile updated successfully'),
            ],
          ),
          backgroundColor: AppColors.secondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          // Profile Header
          SliverToBoxAdapter(
            child: ProfileHeader(
              name: _userName,
              role: 'Farmer',
              onEditPhoto: () {
                // TODO: Implement photo upload
              },
            ),
          ),
          
          // Action bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _toggleEdit,
                    icon: Icon(
                      _isEditing ? Icons.close_rounded : Icons.edit_rounded,
                      size: 20,
                    ),
                    label: Text(_isEditing ? 'Cancel' : 'Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: _isEditing ? AppColors.error : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contact Information
          SliverToBoxAdapter(
            child: SectionCard(
              title: 'Contact Information',
              icon: Icons.phone_rounded,
              children: [
                ReadOnlyField(
                  label: 'Mobile Number',
                  value: _phoneNumber,
                  prefixIcon: Icons.phone_android_rounded,
                  infoMessage: 'Contact support to change your mobile number',
                ),
                DropdownField<String>(
                  label: 'Language Preference',
                  value: _selectedLanguage,
                  items: _languages,
                  displayValue: (v) => v,
                  prefixIcon: Icons.translate_rounded,
                  onChanged: _isEditing ? (v) {
                    if (v != null) {
                      setState(() => _selectedLanguage = v);
                      _markChanged();
                    }
                  } : null,
                ),
              ],
            ),
          ),

          // Farm Information
          SliverToBoxAdapter(
            child: SectionCard(
              title: 'Farm Information',
              icon: Icons.grass_rounded,
              children: [
                MultiSelectChipField(
                  label: 'Crop Types Grown',
                  options: _cropTypes,
                  selectedValues: _selectedCropTypes,
                  isRequired: true,
                  onChanged: _isEditing ? (values) {
                    setState(() => _selectedCropTypes = values);
                    _markChanged();
                  } : null,
                ),
                DropdownField<String>(
                  label: 'District',
                  value: _selectedDistrict,
                  items: _districts,
                  displayValue: (v) => v,
                  prefixIcon: Icons.location_city_rounded,
                  isRequired: true,
                  onChanged: _isEditing ? (v) {
                    if (v != null) {
                      setState(() => _selectedDistrict = v);
                      _markChanged();
                    }
                  } : null,
                ),
                DropdownField<String>(
                  label: 'Taluk',
                  value: _selectedTaluk,
                  items: _taluks,
                  displayValue: (v) => v,
                  prefixIcon: Icons.location_on_rounded,
                  onChanged: _isEditing ? (v) {
                    if (v != null) {
                      setState(() => _selectedTaluk = v);
                      _markChanged();
                    }
                  } : null,
                ),
                DropdownField<String>(
                  label: 'Village',
                  value: _selectedVillage,
                  items: _villages,
                  displayValue: (v) => v,
                  prefixIcon: Icons.home_rounded,
                  onChanged: _isEditing ? (v) {
                    if (v != null) {
                      setState(() => _selectedVillage = v);
                      _markChanged();
                    }
                  } : null,
                ),
                DropdownField<String>(
                  label: 'Preferred Drop Point',
                  value: _selectedDropPoint,
                  items: _dropPoints,
                  displayValue: (v) => v,
                  prefixIcon: Icons.pin_drop_rounded,
                  onChanged: _isEditing ? (v) {
                    if (v != null) {
                      setState(() => _selectedDropPoint = v);
                      _markChanged();
                    }
                  } : null,
                ),
              ],
            ),
          ),

          // Payment Information
          SliverToBoxAdapter(
            child: SectionCard(
              title: 'Payment Information',
              icon: Icons.payments_rounded,
              children: [
                EditableField(
                  label: 'UPI ID',
                  value: _upiId,
                  hint: 'yourname@upi',
                  prefixIcon: Icons.currency_rupee_rounded,
                  isEditing: _isEditing,
                  onChanged: (v) {
                    _upiId = v;
                    _markChanged();
                  },
                  onTap: _isEditing ? null : () {
                    // Show UPI verification modal
                    _showUpiVerificationModal();
                  },
                ),
                EditableField(
                  label: 'Bank Account Number',
                  value: _bankAccount,
                  hint: 'Enter account number',
                  prefixIcon: Icons.account_balance_rounded,
                  isEditing: _isEditing,
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    _bankAccount = v;
                    _markChanged();
                  },
                ),
                EditableField(
                  label: 'IFSC Code',
                  value: _ifscCode,
                  hint: 'SBIN0001234',
                  prefixIcon: Icons.code_rounded,
                  isEditing: _isEditing,
                  onChanged: (v) {
                    _ifscCode = v.toUpperCase();
                    _markChanged();
                  },
                ),
              ],
            ),
          ),

          // View History Link
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/profile/history');
                },
                icon: Icon(Icons.history_rounded),
                label: Text('View Change History'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ),
          ),

          // Bottom padding for FAB
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
      
      // Save FAB
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: _hasChanges ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _hasChanges ? 1.0 : 0.0,
          child: FloatingActionButton.extended(
            onPressed: _isSaving ? null : _saveChanges,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            icon: _isSaving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onPrimary,
                    ),
                  )
                : Icon(Icons.check_rounded),
            label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
          ),
        ),
      ),
    );
  }

  void _showUpiVerificationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              'Verify UPI ID',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'A ₹1 test payment will be sent to verify your UPI ID. This amount will be refunded.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            // UPI Input
            TextField(
              decoration: InputDecoration(
                labelText: 'New UPI ID',
                hintText: 'yourname@upi',
                prefixIcon: Icon(Icons.currency_rupee_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Verify Button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Implement UPI verification API call
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Verification initiated. Please complete the payment.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: Icon(Icons.verified_rounded),
                label: Text('Verify with ₹1 Payment'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
