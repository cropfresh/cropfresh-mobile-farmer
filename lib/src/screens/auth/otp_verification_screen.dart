import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import '../../constants/app_colors.dart';
import '../../services/voice_service.dart';
import '../../services/auth_repository.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final VoiceService _voiceService = VoiceService();
  
  Timer? _timer;
  int _start = 600; // 10 minutes
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _initVoice();
  }

  Future<void> _initVoice() async {
    await _voiceService.init();
    Future.delayed(const Duration(seconds: 1), () {
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

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _voiceService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: GoogleFonts.outfit(
        fontSize: 24,
        color: AppColors.black,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey),
        borderRadius: BorderRadius.circular(12),
        color: AppColors.white,
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.orange, width: 2),
    );

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Verify Mobile',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enter OTP sent to +91 ${widget.phoneNumber}',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              Pinput(
                controller: _otpController,
                length: 6,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                showCursor: true,
                onCompleted: (pin) {
                  // Auto-submit logic can go here
                  _voiceService.speak("Verifying code");
                },
              ),
              
              const SizedBox(height: 32),
              
              Text(
                _timerText,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _start < 60 ? Colors.red : AppColors.black,
                ),
              ),
              
              const SizedBox(height: 16),
              
              if (_canResend)
                TextButton(
                  onPressed: () {
                    _startTimer();
                    _voiceService.speak("Sending new code");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('OTP Resent')),
                    );
                  },
                  child: Text(
                    'Resend OTP',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: AppColors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Text(
                  'Resend OTP in $_timerText',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: AppColors.grey,
                  ),
                ),
                
              const Spacer(),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_otpController.length == 6) {
                      // Verify OTP Logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Verifying...')),
                      );
                      
                      final authRepo = AuthRepository();
                      authRepo.verifyOtp(widget.phoneNumber, _otpController.text).then((success) {
                        if (success) {
                          _voiceService.speak("Verification successful. Welcome to CropFresh.");
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Verification Successful!')),
                          );
                          // Navigate to Dashboard (Placeholder)
                        } else {
                          _voiceService.speak("Invalid code. Please try again.");
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid OTP')),
                          );
                        }
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'Verify & Continue',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
