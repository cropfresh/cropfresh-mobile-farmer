import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../core/animations/animation_constants.dart';
import '../../services/voice_service.dart';
import '../../services/auth_repository.dart';

/// Login Screen (Story 2.2 - AC1, AC2)
/// "Welcome Back" screen for returning farmers with phone input
/// Matches Material 3 styling from registration_screen.dart
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  final VoiceService _voiceService = VoiceService();
  bool _isLoading = false;
  bool _isValid = false;
  String? _errorMessage;
  
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
      _voiceService.speak("Enter your mobile number to login");
    });
  }

  void _validatePhone() {
    final phone = _phoneController.text.replaceAll(' ', '');
    setState(() {
      _isValid = phone.length == 10 && RegExp(r'^[6-9]\d{9}$').hasMatch(phone);
      _errorMessage = null; // Clear error on change
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

  void _sendLoginOtp() async {
    final phoneNumber = _phoneController.text.replaceAll(' ', '').trim();

    if (!_isValid) {
      _voiceService.speak("Please enter a valid 10 digit number");
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authRepo = AuthRepository();
      final result = await authRepo.requestLoginOtp(phoneNumber);

      if (!mounted) return;

      if (result['success'] == true) {
        // Navigate to OTP screen in login mode
        Navigator.pushNamed(
          context,
          '/otp-verification',
          arguments: {
            'phoneNumber': phoneNumber,
            'isLoginFlow': true,
          },
        );
      } else {
        // Handle errors
        final errorCode = result['errorCode'];
        if (errorCode == 'PHONE_NOT_REGISTERED') {
          setState(() {
            _errorMessage = 'Number not found. Register now?';
          });
          _voiceService.speak("Number not registered. Please register first.");
        } else if (errorCode == 'ACCOUNT_LOCKED') {
          final lockedUntil = result['lockedUntil'];
          setState(() {
            _errorMessage = 'Account locked. Try again later.';
          });
          _voiceService.speak("Account temporarily locked.");
          _showLockedDialog(lockedUntil);
        } else {
          setState(() {
            _errorMessage = 'Failed to send code. Try again.';
          });
          _voiceService.speak("Failed to send code. Please try again.");
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showLockedDialog(String? lockedUntil) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Icon(Icons.lock_clock_rounded, size: 48, color: AppColors.error),
        title: const Text('Account Temporarily Locked'),
        content: Text(
          'Too many failed attempts. Please wait 30 minutes before trying again.',
          style: TextStyle(color: AppColors.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToRegister() {
    HapticFeedback.lightImpact();
    // Navigate to registration flow via Welcome screen
    Navigator.pushReplacementNamed(context, '/welcome');
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
        actions: [
          // Language selector
          IconButton(
            icon: const Icon(Icons.language_rounded, color: AppColors.onSurfaceVariant),
            onPressed: () => Navigator.pushNamed(context, '/language-selection'),
            tooltip: 'Change Language',
          ),
        ],
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
                  const SizedBox(height: 24),

                  // Header
                  _buildHeader(),
                  
                  const SizedBox(height: 48),

                  // Phone Input
                  _buildPhoneInput(),
                  
                  const SizedBox(height: 12),
                  
                  // Error / Helper text
                  _buildHelperText(),

                  const Spacer(),

                  // Send Code Button
                  _buildSendCodeButton(),
                  
                  const SizedBox(height: 20),
                  
                  // Register link
                  _buildRegisterLink(),

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
        // Welcome back icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.waving_hand_rounded,
            size: 40,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome Back!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your mobile number to login',
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
          color: _errorMessage != null 
              ? AppColors.error
              : _phoneFocusNode.hasFocus
                  ? AppColors.secondary  // Orange for login
                  : AppColors.outlineVariant,
          width: _phoneFocusNode.hasFocus || _errorMessage != null ? 2 : 1,
        ),
        boxShadow: _phoneFocusNode.hasFocus
            ? [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.1),
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
    // Error message takes priority
    if (_errorMessage != null) {
      return Column(
        children: [
          Text(
            _errorMessage!,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.error,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          if (_errorMessage!.contains('Register'))
            TextButton(
              onPressed: _navigateToRegister,
              child: Text(
                'Register Now →',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      );
    }
    
    final phone = _phoneController.text.replaceAll(' ', '');
    
    if (phone.isEmpty) {
      return Text(
        'We will send you a login code via SMS',
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
          'Ready to login',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSendCodeButton() {
    return AnimatedContainer(
      duration: AnimationConstants.durationShort,
      height: 56,
      child: FilledButton(
        onPressed: _isValid && !_isLoading ? _sendLoginOtp : null,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.secondary, // Orange for login
          foregroundColor: AppColors.onSecondary,
          disabledBackgroundColor: AppColors.outlineVariant,
          disabledForegroundColor: AppColors.onSurfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: _isValid ? 2 : 0,
          shadowColor: AppColors.secondary.withValues(alpha: 0.3),
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
                    'Send Login Code',
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

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            fontSize: 15,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: _navigateToRegister,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Register',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
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
