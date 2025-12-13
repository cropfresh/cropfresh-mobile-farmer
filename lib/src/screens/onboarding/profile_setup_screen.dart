import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/karnataka_locations.dart';
import '../../widgets/step_progress_indicator.dart';

/// Profile Setup Screen (Story 2.1 - AC5)
/// Collects personal information: name, village, taluk, district, state, pincode
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _villageController = TextEditingController(); // For autocomplete
  
  String? _selectedVillage;
  String? _selectedTaluk;
  String? _selectedDistrict;
  String? _selectedState;
  bool _isLoading = false;

  // Using KarnatakaLocations for comprehensive data
  final List<String> _states = ['Karnataka', 'Tamil Nadu', 'Andhra Pradesh', 'Telangana', 'Maharashtra'];
  
  // Karnataka districts from KarnatakaLocations, others kept minimal
  Map<String, List<String>> get _districts => {
    'Karnataka': KarnatakaLocations.districts,
    'Tamil Nadu': ['Chennai', 'Coimbatore', 'Salem', 'Madurai', 'Trichy'],
    'Andhra Pradesh': ['Guntur', 'Krishna', 'Chittoor', 'Nellore', 'Kurnool'],
    'Telangana': ['Hyderabad', 'Rangareddy', 'Medak', 'Warangal', 'Karimnagar'],
    'Maharashtra': ['Pune', 'Mumbai', 'Nashik', 'Nagpur', 'Aurangabad'],
  };

  // Get talukas based on selected district
  List<String> get _currentTalukas {
    if (_selectedDistrict == null) return [];
    if (_selectedState == 'Karnataka') {
      return KarnatakaLocations.getTalukas(_selectedDistrict!);
    }
    return [];
  }

  // Get villages based on selected taluka
  List<String> get _currentVillages {
    if (_selectedTaluk == null) return [];
    return KarnatakaLocations.getVillages(_selectedTaluk!);
  }


  @override
  void dispose() {
    _nameController.dispose();
    _pincodeController.dispose();
    _villageController.dispose();
    super.dispose();
  }

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
                currentStep: 1,
                totalSteps: 5,
                label: 'Personal Information',
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Full Name
                      _buildTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // State Dropdown
                      _buildDropdown(
                        label: 'State',
                        value: _selectedState,
                        items: _states,
                        hint: 'Select your state',
                        icon: Icons.location_on_outlined,
                        onChanged: (value) {
                          setState(() {
                            _selectedState = value;
                            _selectedDistrict = null;
                            _selectedTaluk = null;
                            _selectedVillage = null;
                          });
                        },
                        validator: (value) {
                          if (value == null) return 'Please select state';
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // District Dropdown
                      _buildDropdown(
                        label: 'District',
                        value: _selectedDistrict,
                        items: _selectedState != null ? _districts[_selectedState] ?? [] : [],
                        hint: 'Select your district',
                        icon: Icons.location_city_outlined,
                        enabled: _selectedState != null,
                        onChanged: (value) {
                          setState(() {
                            _selectedDistrict = value;
                            _selectedTaluk = null;
                            _selectedVillage = null;
                          });
                        },
                        validator: (value) {
                          if (value == null) return 'Please select district';
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Taluk Dropdown
                      _buildDropdown(
                        label: 'Taluk',
                        value: _selectedTaluk,
                        items: _currentTalukas,
                        hint: 'Select your taluk',
                        icon: Icons.my_location_outlined,
                        enabled: _selectedDistrict != null,
                        onChanged: (value) {
                          setState(() {
                            _selectedTaluk = value;
                            _selectedVillage = null;
                            _villageController.clear();
                          });
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Village / Town - Autocomplete with manual entry
                      _buildVillageAutocomplete(),
                      
                      const SizedBox(height: 20),
                      
                      // Pincode
                      _buildTextField(
                        controller: _pincodeController,
                        label: 'Pincode',
                        hint: 'Enter 6-digit pincode',
                        icon: Icons.pin_outlined,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        validator: (value) {
                          if (value != null && value.isNotEmpty && value.length != 6) {
                            return 'Pincode must be 6 digits';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Continue Button
                      FilledButton(
                        onPressed: _isLoading ? null : _onContinue,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.onSurfaceVariant),
            filled: true,
            fillColor: Colors.white,
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required String hint,
    required IconData icon,
    bool enabled = true,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(item),
          )).toList(),
          onChanged: enabled ? onChanged : null,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: enabled ? AppColors.onSurfaceVariant : Colors.grey),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the village autocomplete widget with manual entry support
  Widget _buildVillageAutocomplete() {
    final isEnabled = _selectedTaluk != null;
    final villages = _currentVillages;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Village / Town',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (!isEnabled) return const Iterable<String>.empty();
            if (textEditingValue.text.isEmpty) {
              return villages.take(10); // Show first 10 when empty
            }
            // Search in current taluka's villages OR all villages
            final query = textEditingValue.text.toLowerCase();
            final filtered = villages.where(
              (v) => v.toLowerCase().contains(query)
            ).toList();
            
            // If no matches in taluka, search all villages
            if (filtered.isEmpty) {
              return KarnatakaLocations.searchVillages(textEditingValue.text).take(10);
            }
            return filtered.take(10);
          },
          onSelected: (String selection) {
            setState(() {
              _selectedVillage = selection;
              _villageController.text = selection;
            });
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            // Sync the controller
            if (_villageController.text.isNotEmpty && controller.text.isEmpty) {
              controller.text = _villageController.text;
            }
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              enabled: isEnabled,
              onChanged: (value) {
                _villageController.text = value;
                _selectedVillage = value;
              },
              decoration: InputDecoration(
                hintText: isEnabled ? 'Type or select your village' : 'Select taluk first',
                prefixIcon: Icon(
                  Icons.home_outlined, 
                  color: isEnabled ? AppColors.onSurfaceVariant : Colors.grey,
                ),
                filled: true,
                fillColor: isEnabled ? Colors.white : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                suffixIcon: isEnabled && controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          controller.clear();
                          setState(() {
                            _selectedVillage = null;
                            _villageController.clear();
                          });
                        },
                      )
                    : null,
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  width: MediaQuery.of(context).size.width - 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        title: Text(option),
                        onTap: () => onSelected(option),
                        leading: const Icon(Icons.location_on_outlined, size: 20),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        if (isEnabled)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Type to search or enter manually',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
      ],
    );
  }

  void _onContinue() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // Prepare profile data - use villageController for manual entries
      final profileData = {
        'fullName': _nameController.text,
        'village': _villageController.text.isNotEmpty ? _villageController.text : _selectedVillage,
        'taluk': _selectedTaluk,
        'district': _selectedDistrict,
        'state': _selectedState,
        'pincode': _pincodeController.text,
      };
      
      // Navigate to Farm Profile
      Navigator.pushNamed(context, '/farm-profile', arguments: profileData);
    }
  }
}

