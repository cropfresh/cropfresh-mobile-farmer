import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../../widgets/step_progress_indicator.dart';
import '../../services/voice_service.dart';
import '../../services/auth_repository.dart';

/// OTP Verification Screen - AC4: Step 2 of 3
/// 6-digit OTP with auto-focus, countdown timer, shake animation
/// "Change Number" link, auto-submit on completion
class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _otpController = TextEditingController();
  final VoiceService _voiceService = VoiceService();

  Timer? _timer;
  int _start = 600; // 10 minutes
  bool _canResend = false;
  bool _isVerifying = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _initVoice();
    _initShakeAnimation();
  }

  void _initShakeAnimation() {
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.elasticIn,
      ),
    );
  }

  Future<void> _initVoice() async {
    await _voiceService.init();
    Future.delayed(const Duration(milliseconds: 500), () {
      _voiceService.speak("Enter the 6 digit code sent to ${widget.phoneNumber}");
    });
  }

  void _startTimer() {
    setState(() {
      _start = 600;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _timer?.cancel();
          _canResend = true;
        });
      } else {
       setState(() {
          _start--;
        });
      }
    });
  }

  String get _timerText {
    int minutes = _start ~/ 60;
    int seconds = _start % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _triggerShake() {
    _shakeController.forward(from: 0.0);
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) {
      _triggerShake();
      _voiceService.speak("Please enter 6 digits");
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final authRepo = AuthRepository();
      final success = await authRepo.verifyOtp(widget.phoneNumber, _otpController.text);

      if (!mounted) return;

      if (success) {
        _voiceService.speak("Verification successful");
        if (!mounted) return;
        // Navigate to Profile Completion (Step 3)
        Navigator.pushReplacementNamed(context, '/profile-completion');
      } else {
        _triggerShake();
        _voiceService.speak("Invalid code. Please try again.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP. Please try again.')),
        );
        _otpController.clear();
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _voiceService.stop();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Material 3 Pin Theme
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 64,
      textStyle: const TextStyle(
        fontSize: 28,
        color: Colors.black87,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color(0xFFF57C00), width: 2), // Orange
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1), // Warm Cream
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // Step Progress Indicator
              const StepProgressIndicator(currentStep: 2),

              const SizedBox(height: 40),

              // Header
              Text(
                'Verify Your Number',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF57C00), // Orange
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                'Enter OTP sent to +91 ${widget.phoneNumber}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.black87,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // OTP Input with shake animation
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value *
                        ((_shakeController.value * 2 - 1).abs() - 1), 0),
                    child: child,
                  );
                },
                child: Pinput(
                  controller: _otpController,
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  autofocus: true,
                  onCompleted: (pin) {
                    // Auto-submit on 6th digit
                    _verifyOtp();
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Timer
              Text(
                _timerText,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _start < 60 ? Colors.red : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Resend OTP
              if (_canResend)
                TextButton(
                  onPressed: () {
                    _startTimer();
                    _voiceService.speak("Sending new code");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('OTP Resent')),
                    );
                  },
                  child: const Text(
                    'Resend OTP',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFF57C00), // Orange
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              // Change Number link
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Change Number',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              const Spacer(),

              // Verify Button - Material 3 FilledButton
              FilledButton(
                onPressed: _isVerifying ? null : _verifyOtp,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32), // Green
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(0, 56),
                ),
                child: _isVerifying
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Verify & Continue',
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
    );
  }
}
