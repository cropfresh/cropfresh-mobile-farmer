import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/step_progress_indicator.dart';

/// Payment Setup Screen (Story 2.1 - AC7)
/// Soft-gated payment setup - UPI or Bank account, can skip
class PaymentSetupScreen extends StatefulWidget {
  const PaymentSetupScreen({super.key});

  @override
  State<PaymentSetupScreen> createState() => _PaymentSetupScreenState();
}

class _PaymentSetupScreenState extends State<PaymentSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _upiController = TextEditingController();
  final _accountController = TextEditingController();
  final _ifscController = TextEditingController();
  
  String _paymentType = 'UPI'; // UPI or BANK
  String? _bankName;
  bool _isVerifying = false;
  bool _isVerified = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _upiController.dispose();
    _accountController.dispose();
    _ifscController.dispose();
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
                currentStep: 3,
                totalSteps: 5,
                label: 'Payment Setup',
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: AppColors.secondary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Add payment details to receive instant payments. You can skip and add later.',
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Payment Type Toggle
                      Row(
                        children: [
                          Expanded(
                            child: _buildPaymentTypeButton(
                              type: 'UPI',
                              icon: Icons.account_balance_wallet,
                              label: 'UPI ID',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildPaymentTypeButton(
                              type: 'BANK',
                              icon: Icons.account_balance,
                              label: 'Bank Account',
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // UPI Form
                      if (_paymentType == 'UPI') ...[
                        _buildTextField(
                          controller: _upiController,
                          label: 'UPI ID',
                          hint: 'yourname@upi',
                          icon: Icons.alternate_email,
                          suffix: _isVerified
                              ? const Icon(Icons.check_circle, color: AppColors.secondary)
                              : TextButton(
                                  onPressed: _isVerifying ? null : _verifyUpi,
                                  child: _isVerifying
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Text('Verify'),
                                ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (!value.contains('@')) {
                                return 'Invalid UPI format';
                              }
                            }
                            return null;
                          },
                        ),
                        if (_isVerified)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '✅ UPI ID verified',
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                      
                      // Bank Form
                      if (_paymentType == 'BANK') ...[
                        _buildTextField(
                          controller: _accountController,
                          label: 'Account Number',
                          hint: 'Enter account number',
                          icon: Icons.credit_card,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _ifscController,
                          label: 'IFSC Code',
                          hint: 'e.g., SBIN0001234',
                          icon: Icons.code,
                          textCapitalization: TextCapitalization.characters,
                          onChanged: _lookupBank,
                        ),
                        if (_bankName != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '🏦 $_bankName',
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                      
                      const SizedBox(height: 32),
                      
                      // Save Button
                      FilledButton(
                        onPressed: _isLoading ? null : _onSave,
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
                                'Save & Continue',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Skip Button
                      OutlinedButton(
                        onPressed: _onSkip,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.onSurfaceVariant,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey.shade400),
                        ),
                        child: const Text(
                          'Skip for now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
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

  Widget _buildPaymentTypeButton({
    required String type,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _paymentType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _paymentType = type;
          _isVerified = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.onSurface,
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
    TextCapitalization textCapitalization = TextCapitalization.none,
    Widget? suffix,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
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
          textCapitalization: textCapitalization,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.onSurfaceVariant),
            suffixIcon: suffix,
            filled: true,
            fillColor: Colors.white,
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
          ),
        ),
      ],
    );
  }

  Future<void> _verifyUpi() async {
    if (_upiController.text.isEmpty) return;
    
    setState(() => _isVerifying = true);
    
    // Simulate UPI verification API call
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isVerifying = false;
      _isVerified = true;
    });
  }

  void _lookupBank(String ifsc) {
    // Simulate bank lookup
    if (ifsc.length >= 4) {
      final bankCodes = {
        'SBIN': 'State Bank of India',
        'HDFC': 'HDFC Bank',
        'ICIC': 'ICICI Bank',
        'KKBK': 'Kotak Mahindra Bank',
        'BARB': 'Bank of Baroda',
        'CNRB': 'Canara Bank',
        'PUNB': 'Punjab National Bank',
      };
      
      setState(() {
        _bankName = bankCodes[ifsc.substring(0, 4).toUpperCase()];
      });
    } else {
      setState(() => _bankName = null);
    }
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final paymentData = _paymentType == 'UPI'
          ? {'type': 'UPI', 'upiId': _upiController.text}
          : {
              'type': 'BANK',
              'accountNumber': _accountController.text,
              'ifscCode': _ifscController.text,
              'bankName': _bankName,
            };
      
      Navigator.pushNamed(context, '/pin-setup', arguments: paymentData);
    }
  }

  void _onSkip() {
    Navigator.pushNamed(context, '/pin-setup');
  }
}
