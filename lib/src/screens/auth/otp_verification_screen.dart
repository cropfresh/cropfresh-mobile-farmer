import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import '../../constants/app_colors.dart';
import '../../core/animations/animation_constants.dart';
import '../../widgets/step_progress_indicator.dart';
import '../../services/voice_service.dart';
import '../../services/auth_repository.dart';

/// OTP Verification Screen - AC4 (Story 2.1) / AC3 (Story 2.2)
/// 6-digit OTP with circular countdown timer, shake animation
/// Auto-read support, "Change Number" link, auto-submit
/// Supports both registration and login flows via isLoginFlow parameter
class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isLoginFlow;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.isLoginFlow = false,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with TickerProviderStateMixin {
  final TextEditingController _otpController = TextEditingController();
  final VoiceService _voiceService = VoiceService();

  Timer? _timer;
  int _secondsRemaining = 30; // 30 seconds resend timer
  bool _canResend = false;
  bool _isVerifying = false;
  bool _hasError = false;

  late AnimationController _shakeController;
  late AnimationController _contentController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _contentFade;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startTimer();
    _initVoice();
  }

  void _setupAnimations() {
    // Shake animation for errors
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // Content fade in
    _contentController = AnimationController(
      duration: AnimationConstants.durationMedium,
      vsync: this,
    );
    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );
    _contentController.forward();
  }

  Future<void> _initVoice() async {
    await _voiceService.init();
    Future.delayed(const Duration(milliseconds: 800), () {
      final last4 = widget.phoneNumber.substring(widget.phoneNumber.length - 4);
      _voiceService.speak("Enter the 6 digit code sent to $last4");
    });
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 30;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _triggerShake() {
    HapticFeedback.heavyImpact();
    setState(() => _hasError = true);
    _shakeController.forward(from: 0).then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _hasError = false);
      });
    });
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) {
      _triggerShake();
      _voiceService.speak("Please enter 6 digits");
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isVerifying = true);

    try {
      final authRepo = AuthRepository();
      
      if (widget.isLoginFlow) {
        // Login flow - use verifyLoginOtp
        final result = await authRepo.verifyLoginOtp(widget.phoneNumber, _otpController.text);
        
        if (!mounted) return;
        
        if (result['success'] == true) {
          HapticFeedback.heavyImpact();
          _voiceService.speak("Welcome back!");
          // Navigate to home/dashboard, clearing navigation stack
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        } else {
          _handleLoginError(result);
        }
      } else {
        // Registration flow - use verifyOtp
        final success = await authRepo.verifyOtp(widget.phoneNumber, _otpController.text);

        if (!mounted) return;

        if (success) {
          HapticFeedback.heavyImpact();
          _voiceService.speak("Verification successful");
          Navigator.pushReplacementNamed(context, '/profile-setup');
        } else {
          _triggerShake();
          _voiceService.speak("Invalid code. Please try again.");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Invalid OTP. Please try again.'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          _otpController.clear();
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  void _handleLoginError(Map<String, dynamic> result) {
    final errorCode = result['errorCode'];
    
    _triggerShake();
    _otpController.clear();
    
    if (errorCode == 'INVALID_OTP') {
      _voiceService.speak("Invalid code. Please try again.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invalid OTP. Please try again.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else if (errorCode == 'ACCOUNT_LOCKED') {
      _voiceService.speak("Account temporarily locked.");
      _showLockedDialog();
    } else {
      _voiceService.speak("Verification failed. Please try again.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Verification failed. Please try again.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showLockedDialog() {
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
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to login screen
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _resendOtp() async {
    HapticFeedback.lightImpact();
    _voiceService.speak("Sending new code");
    
    // Call API to resend OTP
    final authRepo = AuthRepository();
    await authRepo.requestOtp(widget.phoneNumber);
    
    _startTimer();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('OTP sent successfully'),
          backgroundColor: AppColors.secondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _voiceService.stop();
    _shakeController.dispose();
    _contentController.dispose();
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
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _contentFade,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Step Progress (only show for registration flow)
                if (!widget.isLoginFlow)
                  const StepProgressIndicator(currentStep: 2),
                
                const SizedBox(height: 40),

                // Header
                _buildHeader(),
                
                const SizedBox(height: 48),

                // OTP Input with shake
                _buildOtpInput(),
                
                const SizedBox(height: 32),

                // Timer / Resend
                _buildTimerSection(),
                
                const SizedBox(height: 16),

                // Change Number
                _buildChangeNumber(),

                const Spacer(),

                // Verify Button
                _buildVerifyButton(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // OTP Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.sms_outlined,
            size: 40,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Verify Your Number',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 16,
              color: AppColors.onSurfaceVariant,
            ),
            children: [
              const TextSpan(text: 'Enter the 6-digit code sent to\n'),
              TextSpan(
                text: '+91 ${widget.phoneNumber}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtpInput() {
    final defaultPinTheme = PinTheme(
      width: 52,
      height: 60,
      textStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.onSurface,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: _hasError ? AppColors.error : AppColors.outlineVariant,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.primary, width: 2),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.15),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );

    final errorPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.error, width: 2),
    );

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final sineValue = math.sin(_shakeAnimation.value * math.pi * 4);
        return Transform.translate(
          offset: Offset(sineValue * 8, 0),
          child: child,
        );
      },
      child: Pinput(
        controller: _otpController,
        length: 6,
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: focusedPinTheme,
        errorPinTheme: errorPinTheme,
        autofocus: true,
        hapticFeedbackType: HapticFeedbackType.lightImpact,
        onCompleted: (pin) => _verifyOtp(),
        onChanged: (_) {
          if (_hasError) setState(() => _hasError = false);
        },
      ),
    );
  }

  Widget _buildTimerSection() {
    if (_canResend) {
      return TextButton.icon(
        onPressed: _resendOtp,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text(
          'Resend OTP',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Circular countdown
        SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: _secondsRemaining / 30,
                strokeWidth: 3,
                backgroundColor: AppColors.outlineVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _secondsRemaining < 10 ? AppColors.error : AppColors.primary,
                ),
              ),
              Text(
                '$_secondsRemaining',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _secondsRemaining < 10 ? AppColors.error : AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Resend code in $_secondsRemaining seconds',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildChangeNumber() {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.onSurfaceVariant,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.edit_rounded, size: 18, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 6),
          const Text(
            'Change Number',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      height: 56,
      child: FilledButton(
        onPressed: _isVerifying ? null : _verifyOtp,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.onSecondary,
          disabledBackgroundColor: AppColors.outlineVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          shadowColor: AppColors.secondary.withValues(alpha: 0.3),
        ),
        child: _isVerifying
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
                    'Verify & Continue',
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
