import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/step_progress_indicator.dart';

/// Farm Profile Screen (Story 2.1 - AC6)
/// Collects land size, farming types, and main crops
class FarmProfileScreen extends StatefulWidget {
  const FarmProfileScreen({super.key});

  @override
  State<FarmProfileScreen> createState() => _FarmProfileScreenState();
}

class _FarmProfileScreenState extends State<FarmProfileScreen> {
  String? _selectedFarmSize;
  final Set<String> _selectedFarmingTypes = {};
  final Set<String> _selectedCrops = {};
  bool _isLoading = false;

  final List<Map<String, dynamic>> _farmSizes = [
    {
      'id': 'SMALL',
      'label': 'Small Farm',
      'description': '< 2 acres',
      'icon': '🌾',
    },
    {
      'id': 'MEDIUM',
      'label': 'Medium Farm',
      'description': '2-5 acres',
      'icon': '🚜',
    },
    {
      'id': 'LARGE',
      'label': 'Large Farm',
      'description': '> 5 acres',
      'icon': '🏞️',
    },
  ];

  final List<Map<String, String>> _farmingTypes = [
    {'id': 'VEGETABLES', 'label': 'Vegetables', 'icon': '🥬'},
    {'id': 'FRUITS', 'label': 'Fruits', 'icon': '🍎'},
    {'id': 'GRAINS', 'label': 'Grains', 'icon': '🌾'},
    {'id': 'FLOWERS', 'label': 'Flowers', 'icon': '🌸'},
    {'id': 'OTHERS', 'label': 'Others', 'icon': '🌿'},
  ];

  final List<Map<String, String>> _crops = [
    {'id': 'TOMATO', 'label': 'Tomato', 'icon': '🍅'},
    {'id': 'ONION', 'label': 'Onion', 'icon': '🧅'},
    {'id': 'POTATO', 'label': 'Potato', 'icon': '🥔'},
    {'id': 'CHILLI', 'label': 'Chilli', 'icon': '🌶️'},
    {'id': 'BEANS', 'label': 'Beans', 'icon': '🫘'},
    {'id': 'GREENS', 'label': 'Greens', 'icon': '🥬'},
    {'id': 'CARROT', 'label': 'Carrot', 'icon': '🥕'},
    {'id': 'CABBAGE', 'label': 'Cabbage', 'icon': '🥗'},
    {'id': 'BANANA', 'label': 'Banana', 'icon': '🍌'},
    {'id': 'MANGO', 'label': 'Mango', 'icon': '🥭'},
    {'id': 'GRAPES', 'label': 'Grapes', 'icon': '🍇'},
    {'id': 'RICE', 'label': 'Rice', 'icon': '🌾'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: StepProgressIndicator(
                currentStep: 2,
                totalSteps: 5,
                label: 'Farm Information',
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Farm Size Section
                    Text(
                      'What type of farm do you have?',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: _farmSizes.map((size) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: size != _farmSizes.last ? 12 : 0,
                          ),
                          child: _buildFarmSizeCard(size),
                        ),
                      )).toList(),
                    ),
                    
                    const SizedBox(height: 28),
                    
                    // Farming Type Section
                    Text(
                      'What do you grow?',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select all that apply',
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _farmingTypes.map((type) => _buildFarmingTypeChip(type)).toList(),
                    ),
                    
                    const SizedBox(height: 28),
                    
                    // Main Crops Section
                    Text(
                      'Your main crops (select top 3)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _crops.length,
                      itemBuilder: (context, index) => _buildCropCard(_crops[index]),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Continue Button
                    FilledButton(
                      onPressed: _canContinue ? _onContinue : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: Colors.grey.shade300,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmSizeCard(Map<String, dynamic> size) {
    final isSelected = _selectedFarmSize == size['id'];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFarmSize = size['id'];
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(size['icon'], style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(
              size['label'],
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              size['description'],
              style: TextStyle(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmingTypeChip(Map<String, String> type) {
    final isSelected = _selectedFarmingTypes.contains(type['id']);
    
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(type['icon']!, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(type['label']!),
        ],
      ),
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedFarmingTypes.add(type['id']!);
          } else {
            _selectedFarmingTypes.remove(type['id']);
          }
        });
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildCropCard(Map<String, String> crop) {
    final isSelected = _selectedCrops.contains(crop['id']);
    final canSelect = _selectedCrops.length < 3 || isSelected;
    
    return GestureDetector(
      onTap: () {
        if (!canSelect && !isSelected) return;
        
        setState(() {
          if (isSelected) {
            _selectedCrops.remove(crop['id']);
          } else if (_selectedCrops.length < 3) {
            _selectedCrops.add(crop['id']!);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary.withValues(alpha: 0.15) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.secondary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(crop['icon']!, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              crop['label']!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.secondary : AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.secondary, size: 16),
          ],
        ),
      ),
    );
  }

  bool get _canContinue => 
      _selectedFarmSize != null && 
      _selectedFarmingTypes.isNotEmpty && 
      _selectedCrops.isNotEmpty;

  void _onContinue() {
    if (!_canContinue) return;
    
    setState(() => _isLoading = true);
    
    final farmData = {
      'farmSize': _selectedFarmSize,
      'farmingTypes': _selectedFarmingTypes.toList(),
      'mainCrops': _selectedCrops.toList(),
    };
    
    Navigator.pushNamed(context, '/payment-setup', arguments: farmData);
  }
}
