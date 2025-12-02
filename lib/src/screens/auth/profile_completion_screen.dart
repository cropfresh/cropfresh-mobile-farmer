import 'package:flutter/material.dart';
import '../../widgets/step_progress_indicator.dart';

/// Profile Completion Screen - AC5: Step 3 of 3
/// Form with Name, Address, Land Size categories, Crops, UPI
/// Material 3 SegmentedButton for land size selection
/// Validates required fields before submission
class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _upiController = TextEditingController();

  String? _selectedLandSize;
  final Set<String> _selectedCrops = {};

  final List<Map<String, String>> _landSizeOptions = [
    {
      'value': 'SMALL_FARM',
      'title': 'Small Farm',
      'range': '1-2 acres',
      'desc': 'Kitchen garden to small yields',
      'icon': '🌾'
    },
    {
      'value': 'MEDIUM_FARM',
      'title': 'Medium Farm',
      'range': '3-5 acres',
      'desc': 'Regular market supply',
      'icon': '🚜'
    },
    {
      'value': 'LARGE_FARM',
      'title': 'Large Farm',
      'range': '5+ acres',
      'desc': 'Bulk produce and wholesale',
      'icon': '🏞️'
    },
  ];

  final List<String> _cropTypes = [
    'Rice',
    'Wheat',
    'Sugarcane',
    'Cotton',
    'Vegetables',
    'Fruits',
    'Pulses',
    'Spices',
  ];

  bool _isLoading = false;

void _submitProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLandSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your land size category')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call (will be implemented with actual backend)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Success message with farmer's name
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Welcome ${_nameController.text}! Your profile is complete.',
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: const Color(0xFF2E7D32), // Green
        duration: const Duration(seconds: 3),
      ),
    );

    // Navigate to Dashboard (placeholder)
    // TODO: Navigate to farmer dashboard
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1), // Warm Cream
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                // Step Progress Indicator
                const StepProgressIndicator(currentStep: 3),

                const SizedBox(height: 40),

                // Header
                Text(
                  'Tell Us About Yourself',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF57C00), // Orange
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  'Complete your profile to start listing crops',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Full Name (Required)
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name *',
                    hintText: 'Enter your full name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFF57C00),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Address (Required, Multiline)
                TextFormField(
                  controller: _addressController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Complete Address *',
                    hintText: 'Village, District, State',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFF57C00),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 28),

                // Land Size Category (Required) - Material 3 Segmented Button equivalent
                Text(
                  'Land Size Category *',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                ),

                const SizedBox(height: 16),

                ..._landSizeOptions.map((option) {
                  final isSelected = _selectedLandSize == option['value'];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedLandSize = option['value'];
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFF57C00).withOpacity(0.1)
                              : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFF57C00)
                                : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              option['icon']!,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option['title']!,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? const Color(0xFFF57C00)
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${option['range']} • ${option['desc']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFFF57C00),
                                size: 28,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 28),

                // Crop Types (Optional, Multi-select)
                Text(
                  'Crop Types (Optional)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _cropTypes.map((crop) {
                    final isSelected = _selectedCrops.contains(crop);

                    return FilterChip(
                      label: Text(crop),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCrops.add(crop);
                          } else {
                            _selectedCrops.remove(crop);
                          }
                        });
                      },
                      selectedColor: const Color(0xFFF57C00).withOpacity(0.3),
                      checkmarkColor: const Color(0xFFF57C00),
                      labelStyle: TextStyle(
                        color: isSelected ? const Color(0xFFF57C00) : Colors.black87,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // UPI ID (Optional)
                TextFormField(
                  controller: _upiController,
                  decoration: InputDecoration(
                    labelText: 'UPI ID (Optional)',
                    hintText: 'yourname@upi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFF57C00),
                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Complete Registration Button
                FilledButton(
                  onPressed: _isLoading ? null : _submitProfile,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32), // Green
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(0, 56),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Complete Registration',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
