import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';

/// CropSelectionGrid - Manual fallback for crop selection (Story 3.1 AC4, AC5)
/// 
/// Shows:
/// - Grid of common crops with large image tiles
/// - Quantity input with unit selector (kg/quintal)
/// - Shown when voice recognition fails 3 times
class CropSelectionGrid extends StatefulWidget {
  const CropSelectionGrid({super.key});

  @override
  State<CropSelectionGrid> createState() => _CropSelectionGridState();
}

class _CropSelectionGridState extends State<CropSelectionGrid> {
  String? _selectedCrop;
  double _quantity = 0.0;
  String _unit = 'kg';
  
  final TextEditingController _quantityController = TextEditingController();

  // Supported crops (AC5)
  final List<Map<String, String>> _crops = [
    {'name': 'Tomato', 'emoji': '🍅', 'name_kn': 'ಟೊಮೆಟೊ'},
    {'name': 'Potato', 'emoji': '🥔', 'name_kn': 'ಆಲೂಗಡ್ಡೆ'},
    {'name': 'Onion', 'emoji': '🧅', 'name_kn': 'ಈರುಳ್ಳಿ'},
    {'name': 'Cabbage', 'emoji': '🥬', 'name_kn': 'ಎಲೆಕೋಸು'},
    {'name': 'Carrot', 'emoji': '🥕', 'name_kn': 'ಕ್ಯಾರೆಟ್'},
    {'name': 'Beans', 'emoji': '🫛', 'name_kn': 'ಬೀನ್ಸ್'},
    {'name': 'Brinjal', 'emoji': '🍆', 'name_kn': 'ಬದನೆಕಾಯಿ'},
    {'name': 'Pepper', 'emoji': '🌶️', 'name_kn': 'ಮೆಣಸಿನಕಾಯಿ'},
    {'name': 'Cucumber', 'emoji': '🥒', 'name_kn': 'ಸೌತೆಕಾಯಿ'},
    {'name': 'Corn', 'emoji': '🌽', 'name_kn': 'ಜೋಳ'},
    {'name': 'Spinach', 'emoji': '🥬', 'name_kn': 'ಪಾಲಕ್'},
    {'name': 'Other', 'emoji': '🌿', 'name_kn': 'ಇತರೆ'},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadArguments();
  }

  void _loadArguments() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        _selectedCrop = args['cropType'];
        _quantity = (args['quantity'] ?? 0.0).toDouble();
        _quantityController.text = _quantity > 0 ? _quantity.toString() : '';
      });
    }
  }

  void _onCropSelected(String crop) {
    HapticFeedback.selectionClick();
    setState(() => _selectedCrop = crop);
  }

  void _onContinue() {
    if (_selectedCrop == null || _quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a crop and enter quantity'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    
    // Convert quintal to kg
    final quantityKg = _unit == 'quintal' ? _quantity * 100 : _quantity;
    
    Navigator.pushNamed(
      context,
      '/listing-confirmation',
      arguments: {
        'cropType': _selectedCrop,
        'quantity': quantityKg,
        'unit': 'kg',
        'transcribedText': '',
        'confidence': 1.0, // Manual selection is 100% confident
        'language': 'en-IN',
      },
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Select Crop'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Crop grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 1.0,
                ),
                itemCount: _crops.length,
                itemBuilder: (context, index) {
                  final crop = _crops[index];
                  final isSelected = _selectedCrop == crop['name'];
                  
                  return GestureDetector(
                    onTap: () => _onCropSelected(crop['name']!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppColors.secondaryContainer 
                            : Colors.white,
                        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
                        border: Border.all(
                          color: isSelected 
                              ? AppColors.secondary 
                              : AppColors.outlineVariant,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            crop['emoji']!,
                            style: const TextStyle(fontSize: 36),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            crop['name']!,
                            style: TextStyle(
                              fontWeight: isSelected 
                                  ? FontWeight.w600 
                                  : FontWeight.w500,
                              color: isSelected 
                                  ? AppColors.onSecondaryContainer 
                                  : AppColors.onSurface,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Quantity input section
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selected crop indicator
                  if (_selectedCrop != null)
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
                          Text(
                            _crops.firstWhere((c) => c['name'] == _selectedCrop)['emoji']!,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _selectedCrop!,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  // Quantity input
                  Text(
                    'How much do you want to sell?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  
                  Row(
                    children: [
                      // Quantity field
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _quantityController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: 'Enter quantity',
                            prefixIcon: const Icon(Icons.scale),
                            filled: true,
                            fillColor: AppColors.surfaceContainerHigh,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _quantity = double.tryParse(value) ?? 0.0;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // Unit selector
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _unit,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.surfaceContainerHigh,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'kg', child: Text('kg')),
                            DropdownMenuItem(value: 'quintal', child: Text('quintal')),
                          ],
                          onChanged: (value) {
                            setState(() => _unit = value ?? 'kg');
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: (_selectedCrop != null && _quantity > 0) 
                          ? _onContinue 
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        disabledBackgroundColor: AppColors.surfaceContainerHigh,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
}
