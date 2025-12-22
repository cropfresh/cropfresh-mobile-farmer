import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../core/animations/animation_constants.dart';
import '../../widgets/step_progress_indicator.dart';
import '../../services/voice_service.dart';
import '../../services/auth_repository.dart';
import 'otp_verification_screen.dart';

/// Registration Screen - AC4 (Story 2.1)
/// Phone Number Entry with auto-formatting and M3 styling
/// Progress indicator, +91 prefix, voice prompt, validation
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with TickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  final VoiceService _voiceService = VoiceService();
  bool _isLoading = false;
  bool _isValid = false;
  
  late AnimationController _contentController;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initVoice();
    _phoneController.addListener(_validatePhone);
  }

  void _setupAnimations() {
    _contentController = AnimationController(
      duration: AnimationConstants.durationMedium,
      vsync: this,
    );
    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: AnimationConstants.curveEmphasized,
    ));
    
    _contentController.forward();
  }

  Future<void> _initVoice() async {
    await _voiceService.init();
    Future.delayed(const Duration(milliseconds: 800), () {
      _voiceService.speak("Enter your 10 digit mobile number");
    });
  }

  void _validatePhone() {
    final phone = _phoneController.text.replaceAll(' ', '');
    setState(() {
      _isValid = phone.length == 10 && RegExp(r'^[6-9]\d{9}$').hasMatch(phone);
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    _voiceService.stop();
    _contentController.dispose();
    super.dispose();
  }

  void _sendOtp() async {
    final phoneNumber = _phoneController.text.replaceAll(' ', '').trim();

    if (!_isValid) {
      _voiceService.speak("Please enter a valid 10 digit number");
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      final authRepo = AuthRepository();
      final success = await authRepo.requestOtp(phoneNumber);

      if (!mounted) return;

      if (success) {
        // Navigate to OTP screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(
              phoneNumber: phoneNumber,
            ),
          ),
        );
      } else {
        _voiceService.speak("Failed to send OTP. Please try again.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to send OTP. Please try again.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SlideTransition(
          position: _contentSlide,
          child: FadeTransition(
            opacity: _contentFade,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Step Progress Indicator
                  const StepProgressIndicator(currentStep: 1),
                  
                  const SizedBox(height: 48),

                  // Header
                  _buildHeader(),
                  
                  const SizedBox(height: 48),

                  // Phone Input
                  _buildPhoneInput(),
                  
                  const SizedBox(height: 12),
                  
                  // Helper text
                  _buildHelperText(),

                  const Spacer(),

                  // Send OTP Button
                  _buildSendOtpButton(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Phone icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.phone_android_rounded,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "Let's Get Started",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your mobile number to continue',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _phoneFocusNode.hasFocus
              ? AppColors.primary
              : AppColors.outlineVariant,
          width: _phoneFocusNode.hasFocus ? 2 : 1,
        ),
        boxShadow: _phoneFocusNode.hasFocus
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Country code prefix
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  '🇮🇳',
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Text(
                  '+91',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Container(
            width: 1,
            height: 30,
            color: AppColors.outlineVariant,
          ),
          // Phone number input
          Expanded(
            child: TextField(
              controller: _phoneController,
              focusNode: _phoneFocusNode,
              keyboardType: TextInputType.phone,
              maxLength: 12, // 10 digits + 2 spaces
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                letterSpacing: 2,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _PhoneNumberFormatter(),
              ],
              decoration: const InputDecoration(
                hintText: '98765 43210',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  letterSpacing: 2,
                ),
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              ),
              onTap: () => setState(() {}),
              onChanged: (_) => setState(() {}),
            ),
          ),
          // Clear button
          if (_phoneController.text.isNotEmpty)
            IconButton(
              onPressed: () {
                _phoneController.clear();
                setState(() {});
              },
              icon: Icon(
                Icons.cancel_rounded,
                color: AppColors.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHelperText() {
    final phone = _phoneController.text.replaceAll(' ', '');
    
    if (phone.isEmpty) {
      return Text(
        'We will send you a 6-digit OTP',
        style: TextStyle(
          fontSize: 14,
          color: AppColors.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      );
    } else if (phone.length < 10) {
      return Text(
        '${10 - phone.length} more digits needed',
        style: TextStyle(
          fontSize: 14,
          color: AppColors.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      );
    } else if (!_isValid) {
      return Text(
        'Please enter a valid Indian mobile number',
        style: TextStyle(
          fontSize: 14,
          color: AppColors.error,
        ),
        textAlign: TextAlign.center,
      );
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle_rounded, color: AppColors.secondary, size: 18),
        const SizedBox(width: 6),
        Text(
          'Ready to send OTP',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSendOtpButton() {
    return AnimatedContainer(
      duration: AnimationConstants.durationShort,
      height: 56,
      child: FilledButton(
        onPressed: _isValid && !_isLoading ? _sendOtp : null,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.outlineVariant,
          disabledForegroundColor: AppColors.onSurfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: _isValid ? 2 : 0,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Get OTP',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
      ),
    );
  }
}

/// Custom formatter to add spaces in phone number (XXXXX XXXXX format)
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    
    if (text.length > 10) {
      return oldValue;
    }
    
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 5) buffer.write(' ');
      buffer.write(text[i]);
    }
    
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
