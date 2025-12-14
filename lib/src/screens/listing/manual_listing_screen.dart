import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../models/produce_catalog.dart';

/// ManualListingScreen - Enhanced form-based crop listing
/// 
/// Features:
/// - Category tabs (Vegetables, Fruits, Leafy Greens, Flowers, Grains)
/// - 50+ produce items with regional names
/// - Smart units based on selected produce type
/// - Quick quantity buttons per item
class ManualListingScreen extends StatefulWidget {
  const ManualListingScreen({super.key});

  @override
  State<ManualListingScreen> createState() => _ManualListingScreenState();
}

class _ManualListingScreenState extends State<ManualListingScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  
  // Form data
  ProduceItem? _selectedProduce;
  ProduceUnit _selectedUnit = ProduceUnits.kg;
  double _quantity = 0.0;
  DateTime? _harvestDate;
  String _qualityGrade = 'B';
  
  // Category tabs
  late TabController _categoryController;
  ProduceCategory _selectedCategory = ProduceCategory.vegetables;
  
  final TextEditingController _quantityController = TextEditingController();
  final PageController _pageController = PageController();

  final List<ProduceCategory> _categories = [
    ProduceCategory.vegetables,
    ProduceCategory.fruits,
    ProduceCategory.leafyGreens,
    ProduceCategory.flowers,
    ProduceCategory.grains,
  ];

  @override
  void initState() {
    super.initState();
    _categoryController = TabController(length: _categories.length, vsync: this);
    _categoryController.addListener(() {
      setState(() {
        _selectedCategory = _categories[_categoryController.index];
      });
    });
  }

  void _onProduceSelected(ProduceItem produce) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedProduce = produce;
      _selectedUnit = produce.defaultUnit;
      _quantity = 0.0;
      _quantityController.clear();
    });
  }

  void _onQuantityQuickSelect(int qty) {
    HapticFeedback.lightImpact();
    setState(() {
      _quantity = qty.toDouble();
      _quantityController.text = qty.toString();
    });
  }

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    } else {
      _proceedToPhoto();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  void _proceedToPhoto() {
    // Convert to kg if weight-based
    double quantityKg = _quantity;
    if (_selectedUnit.isWeightBased) {
      quantityKg = _quantity * _selectedUnit.toKgFactor;
    }
    
    Navigator.pushNamed(
      context,
      '/photo-capture',
      arguments: {
        'cropType': _selectedProduce?.name ?? '',
        'cropEmoji': _selectedProduce?.emoji ?? '🌾',
        'quantity': quantityKg,
        'displayQuantity': _quantity,
        'unit': _selectedUnit.symbol,
        'harvestDate': _harvestDate?.toIso8601String(),
        'qualityGrade': _qualityGrade,
        'entryMode': 'manual',
        'produceId': _selectedProduce?.id,
      },
    );
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0:
        return _selectedProduce != null;
      case 1:
        return _quantity > 0;
      case 2:
        return true; // Optional step
      default:
        return false;
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _pageController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Create Listing'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _previousStep,
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          _StepIndicator(currentStep: _currentStep, totalSteps: 3),
          
          // Step content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _CropSelectionStep(
                  categories: _categories,
                  categoryController: _categoryController,
                  selectedCategory: _selectedCategory,
                  selectedProduce: _selectedProduce,
                  onProduceSelected: _onProduceSelected,
                ),
                _QuantityStep(
                  controller: _quantityController,
                  quantity: _quantity,
                  selectedUnit: _selectedUnit,
                  selectedProduce: _selectedProduce,
                  onQuantityChanged: (q) => setState(() => _quantity = q),
                  onUnitChanged: (u) => setState(() => _selectedUnit = u),
                  onQuickSelect: _onQuantityQuickSelect,
                ),
                _DetailsStep(
                  harvestDate: _harvestDate,
                  qualityGrade: _qualityGrade,
                  onDateChanged: (d) => setState(() => _harvestDate = d),
                  onGradeChanged: (g) => setState(() => _qualityGrade = g),
                ),
              ],
            ),
          ),
          
          // Bottom action
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _canProceed ? _nextStep : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    disabledBackgroundColor: AppColors.surfaceContainerHigh,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentStep == 2 ? 'Add Photo' : 'Continue',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _currentStep == 2 ? Icons.camera_alt : Icons.arrow_forward,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Step indicator
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepIndicator({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps, (index) {
          final isActive = index <= currentStep;
          return Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.secondary : AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              if (index < totalSteps - 1) const SizedBox(width: 8),
            ],
          );
        }),
      ),
    );
  }
}

/// Step 1: Crop Selection with Category Tabs
class _CropSelectionStep extends StatelessWidget {
  final List<ProduceCategory> categories;
  final TabController categoryController;
  final ProduceCategory selectedCategory;
  final ProduceItem? selectedProduce;
  final Function(ProduceItem) onProduceSelected;

  const _CropSelectionStep({
    required this.categories,
    required this.categoryController,
    required this.selectedCategory,
    required this.selectedProduce,
    required this.onProduceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What are you selling?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Select category and your produce',
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        
        // Category tabs
        Container(
          color: Colors.white,
          child: TabBar(
            controller: categoryController,
            isScrollable: true,
            labelColor: AppColors.secondary,
            unselectedLabelColor: AppColors.onSurfaceVariant,
            indicatorColor: AppColors.secondary,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            tabs: categories.map((cat) => Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(ProduceCatalog.getCategoryEmoji(cat)),
                  const SizedBox(width: 6),
                  Text(ProduceCatalog.getCategoryLabel(cat)),
                ],
              ),
            )).toList(),
          ),
        ),
        
        // Produce grid
        Expanded(
          child: TabBarView(
            controller: categoryController,
            children: categories.map((cat) {
              final items = ProduceCatalog.getByCategory(cat);
              return GridView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 0.85,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = selectedProduce?.id == item.id;
                  
                  return GestureDetector(
                    onTap: () => onProduceSelected(item),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppColors.secondaryContainer 
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
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
                          Text(item.emoji, style: const TextStyle(fontSize: 32)),
                          const SizedBox(height: 4),
                          Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected 
                                  ? AppColors.onSecondaryContainer 
                                  : AppColors.onSurface,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item.avgPricePerKg != null)
                            Text(
                              '₹${item.avgPricePerKg!.toInt()}/kg',
                              style: TextStyle(
                                fontSize: 9,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Step 2: Quantity with Smart Units
class _QuantityStep extends StatelessWidget {
  final TextEditingController controller;
  final double quantity;
  final ProduceUnit selectedUnit;
  final ProduceItem? selectedProduce;
  final Function(double) onQuantityChanged;
  final Function(ProduceUnit) onUnitChanged;
  final Function(int) onQuickSelect;

  const _QuantityStep({
    required this.controller,
    required this.quantity,
    required this.selectedUnit,
    required this.selectedProduce,
    required this.onQuantityChanged,
    required this.onUnitChanged,
    required this.onQuickSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected produce indicator
          if (selectedProduce != null)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Text(selectedProduce!.emoji, style: const TextStyle(fontSize: 36)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedProduce!.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          selectedProduce!.nameKn,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selectedProduce!.avgPricePerKg != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '₹${selectedProduce!.avgPricePerKg!.toInt()}/kg',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          
          const SizedBox(height: AppSpacing.xl),
          
          Text(
            'How much do you want to sell?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Quantity input + unit selector
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quantity field
              Expanded(
                flex: 2,
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(color: AppColors.outline),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppColors.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppColors.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppColors.secondary, width: 2),
                    ),
                  ),
                  onChanged: (value) {
                    onQuantityChanged(double.tryParse(value) ?? 0.0);
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Unit selector chips
          Text(
            'Unit',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (selectedProduce != null)
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: selectedProduce!.availableUnits.map((unit) {
                final isSelected = selectedUnit.id == unit.id;
                return ChoiceChip(
                  label: Text(unit.name),
                  selected: isSelected,
                  onSelected: (_) => onUnitChanged(unit),
                  selectedColor: AppColors.secondaryContainer,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.secondary : AppColors.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Quick quantity buttons
          Text(
            'Quick select',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (selectedProduce != null)
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: selectedProduce!.quickQuantities.map((qty) {
                return ActionChip(
                  label: Text('$qty ${selectedUnit.symbol}'),
                  onPressed: () => onQuickSelect(qty),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: AppColors.outlineVariant),
                );
              }).toList(),
            ),
          
          // Estimated earnings preview
          if (quantity > 0 && selectedProduce?.avgPricePerKg != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xl),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.secondary, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.payments, color: Colors.white, size: 28),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estimated Earnings',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _calculateEstimatedEarnings(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _calculateEstimatedEarnings() {
    if (selectedProduce == null || selectedProduce!.avgPricePerKg == null) {
      return '₹0';
    }
    
    double quantityInKg = quantity;
    if (selectedUnit.isWeightBased && selectedUnit.toKgFactor > 0) {
      quantityInKg = quantity * selectedUnit.toKgFactor;
    }
    
    final earnings = quantityInKg * selectedProduce!.avgPricePerKg!;
    return '₹${earnings.toStringAsFixed(0)}';
  }
}

/// Step 3: Optional Details
class _DetailsStep extends StatelessWidget {
  final DateTime? harvestDate;
  final String qualityGrade;
  final Function(DateTime?) onDateChanged;
  final Function(String) onGradeChanged;

  const _DetailsStep({
    required this.harvestDate,
    required this.qualityGrade,
    required this.onDateChanged,
    required this.onGradeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Details',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'These are optional but help buyers',
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.xl),
          
          // Harvest date
          Text('When was it harvested?', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: harvestDate ?? DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now(),
              );
              if (date != null) onDateChanged(date);
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: AppColors.secondary),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    harvestDate != null
                        ? '${harvestDate!.day}/${harvestDate!.month}/${harvestDate!.year}'
                        : 'Select date (optional)',
                    style: TextStyle(
                      color: harvestDate != null ? AppColors.onSurface : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Quality self-assessment
          Text('How would you rate quality?', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _GradeChip(grade: 'A', label: 'Excellent', isSelected: qualityGrade == 'A', color: Colors.green, onTap: () => onGradeChanged('A')),
              const SizedBox(width: AppSpacing.sm),
              _GradeChip(grade: 'B', label: 'Good', isSelected: qualityGrade == 'B', color: Colors.orange, onTap: () => onGradeChanged('B')),
              const SizedBox(width: AppSpacing.sm),
              _GradeChip(grade: 'C', label: 'Fair', isSelected: qualityGrade == 'C', color: Colors.red, onTap: () => onGradeChanged('C')),
            ],
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'AI will verify quality from your photo in the next step',
                    style: TextStyle(fontSize: 12, color: AppColors.onPrimaryContainer),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeChip extends StatelessWidget {
  final String grade;
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _GradeChip({
    required this.grade,
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? color : AppColors.outlineVariant, width: isSelected ? 2 : 1),
          ),
          child: Column(
            children: [
              Text(grade, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: isSelected ? color : AppColors.onSurface)),
              Text(label, style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}
