import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Language Selection Screen - AC2
/// 5 language options with native scripts
/// Voice prompt auto-play
/// Local storage persistence
class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  String? _selectedLanguage;

  final List<Map<String, String>> _languages = [
    {'code': 'kn', 'name': 'ಕನ್ನಡ', 'display': '🇮🇳 ಕನ್ನಡ (Kannada)'},
    {'code': 'en', 'name': 'English', 'display': '🇮🇳 English'},
    {'code': 'hi', 'name': 'हिंदी', 'display': '🇮🇳 हिंदी (Hindi)'},
    {'code': 'ta', 'name': 'தமிழ்', 'display': '🇮🇳 தமிழ் (Tamil)'},
    {'code': 'te', 'name': 'తెలుగు', 'display': '🇮🇳 తెలుగు (Telugu)'},
  ];

  @override
  void initState() {
    super.initState();
    _playVoicePrompt();
  }

  Future<void> _playVoicePrompt() async {
    try {
      await _flutterTts.setLanguage('en-IN');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.speak('Namaste! Select your language');
    } catch (e) {
      // Voice prompt failed, continue silently
      debugPrint('TTS error: $e');
    }
  }

  Future<void> _selectLanguage(String languageCode) async {
    setState(() {
      _selectedLanguage = languageCode;
    });

    // Store language preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_preference', languageCode);

    // Navigate to registration
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/registration');
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1), // Warm Cream
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const Text(
                'Namaste! 🙏',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF57C00), // Orange
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Your Language\nनिम्म ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 48),

              // Language grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 4,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _languages.length,
                  itemBuilder: (context, index) {
                    final language = _languages[index];
                    final isSelected =
                        _selectedLanguage == language['code'];

                    return FilledButton(
                      onPressed: () => _selectLanguage(language['code']!),
                      style: FilledButton.styleFrom(
                        backgroundColor: isSelected
                            ? const Color(0xFFF57C00) // Orange
                            : Colors.white,
                        foregroundColor: isSelected
                            ? Colors.white
                            : const Color(0xFFF57C00),
                        elevation: isSelected ? 4 : 1,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: const Color(0xFFF57C00),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        // Minimum touch target 48x48dp
                        minimumSize: const Size(0, 48),
                      ),
                      child: Text(
                        language['display']!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
