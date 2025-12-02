import 'package:flutter/material.dart';
import '../../widgets/step_progress_indicator.dart';
import '../../services/voice_service.dart';
import 'otp_verification_screen.dart';
import '../../services/auth_repository.dart';

/// Registration Screen - AC3: Step 1 of 3
/// Phone Number Entry with Material 3 OutlinedTextField
/// Progress indicator, +91 prefix, voice prompt, validation
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _phoneController = TextEditingController();
 final VoiceService _voiceService = VoiceService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initVoice();
  }

  Future<void> _initVoice() async {
    await _voiceService.init();
    Future.delayed(const Duration(milliseconds: 500), () {
      _voiceService.speak("Enter your 10 digit mobile number");
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _voiceService.stop();
    super.dispose();
  }

  void _sendOtp() async {
    final phoneNumber = _phoneController.text.trim();

    if (phoneNumber.length != 10) {
      _voiceService.speak("Please enter a valid 10 digit number");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter 10 digits')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authRepo = AuthRepository();
      final success = await authRepo.requestOtp(phoneNumber);

      if (!mounted) return;

      if (success) {
        // Navigate to OTP screen (Step 2)
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
          const SnackBar(content: Text('Failed to send OTP. Please try again.')),
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
      backgroundColor: const Color(0xFFFFF8E1), // Warm Cream
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // Step Progress Indicator
              const StepProgressIndicator(currentStep: 1),

              const SizedBox(height: 40),

              // Header
              Text(
                "Let's Get Started",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF57C00), // Orange
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                'Enter your mobile number to continue',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.black87,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Mobile Number Input - Material 3 Outlined TextField
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                style: const TextStyle(fontSize: 20, letterSpacing: 1.5),
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  hintText: '9876543210',
                  prefixText: '+91 🇮🇳  ',
                  prefixStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFF57C00), // Orange
                      width: 2,
                    ),
                  ),
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),

              const Spacer(),

              // Send OTP Button - Material 3 FilledButton
              FilledButton(
                onPressed: _isLoading ? null : _sendOtp,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFF57C00), // Orange
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(0, 56), // 56dp height
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Send OTP',
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
