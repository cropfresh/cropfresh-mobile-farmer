import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../services/voice_service.dart';
import 'otp_verification_screen.dart';
import '../../services/auth_repository.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final VoiceService _voiceService = VoiceService();
  String _selectedLanguage = 'English';

  final List<String> _languages = [
    'English',
    'Kannada',
    'Hindi',
    'Tamil',
    'Telugu'
  ];

  @override
  void initState() {
    super.initState();
    _initVoice();
  }

  Future<void> _initVoice() async {
    await _voiceService.init();
    // Delay slightly to ensure UI is built before speaking
    Future.delayed(const Duration(seconds: 1), () {
      _voiceService.speak("Enter your mobile number to get started");
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _voiceService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Logo Placeholder
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.agriculture,
                    size: 48,
                    color: AppColors.green,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Start Farming',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Language Selector
              Text(
                'Select Language / ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: _languages.map((lang) {
                  final isSelected = _selectedLanguage == lang;
                  return ChoiceChip(
                    label: Text(lang),
                    selected: isSelected,
                    selectedColor: AppColors.orange,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.white : AppColors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedLanguage = lang;
                        });
                        // In a real app, we would switch TTS language here
                        _voiceService.speak("Selected $lang");
                      }
                    },
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 40),
              
              // Mobile Number Input
              Text(
                'Mobile Number',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                style: GoogleFonts.outfit(fontSize: 24, letterSpacing: 2),
                decoration: InputDecoration(
                  prefixText: '+91 ',
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  counterText: "",
                ),
              ),
              
              const Spacer(),
              
              // Send OTP Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_phoneController.text.length == 10) {
                      // Request OTP
                      setState(() {
                        // Show loading (simple way for now, ideally use a state variable)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sending OTP...')),
                        );
                      });

                      final authRepo = AuthRepository();
                      authRepo.requestOtp(_phoneController.text).then((success) {
                        if (success) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OtpVerificationScreen(
                                phoneNumber: _phoneController.text,
                              ),
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('OTP Sent!')),
                          );
                        } else {
                          _voiceService.speak("Failed to send OTP. Please try again.");
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to send OTP')),
                          );
                        }
                      });
                    } else {
                      _voiceService.speak("Please enter a valid 10 digit number");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Send OTP',
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
