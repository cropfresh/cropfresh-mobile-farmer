import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';

/// VoiceListingScreen - Voice-to-Text Crop Listing (Story 3.1 AC1, AC6)
/// 
/// Implements voice input with:
/// - Animated microphone icon with pulsing effect
/// - Voice prompt in selected language
/// - Language selector (Kannada/Hindi/Tamil/Telugu/English)
/// - Real-time transcription preview
/// - Fallback keyboard option
class VoiceListingScreen extends StatefulWidget {
  const VoiceListingScreen({super.key});

  @override
  State<VoiceListingScreen> createState() => _VoiceListingScreenState();
}

class _VoiceListingScreenState extends State<VoiceListingScreen>
    with TickerProviderStateMixin {
  // Speech recognition
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  
  bool _isListening = false;
  bool _speechAvailable = false;
  String _transcribedText = '';
  double _confidence = 0.0;
  int _failedAttempts = 0;
  
  // Selected language
  String _selectedLanguage = 'en-IN';
  
  // Animation controllers
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  // Supported languages (AC6)
  final List<Map<String, String>> _languages = [
    {'code': 'en-IN', 'name': 'English', 'native': 'English'},
    {'code': 'kn-IN', 'name': 'Kannada', 'native': 'ಕನ್ನಡ'},
    {'code': 'hi-IN', 'name': 'Hindi', 'native': 'हिंदी'},
    {'code': 'ta-IN', 'name': 'Tamil', 'native': 'தமிழ்'},
    {'code': 'te-IN', 'name': 'Telugu', 'native': 'తెలుగు'},
  ];

  // Voice prompts per language
  final Map<String, String> _voicePrompts = {
    'en-IN': 'What do you want to sell?',
    'kn-IN': 'ನೀವು ಏನು ಮಾರಾಟ ಮಾಡಲು ಬಯಸುತ್ತೀರಿ?',
    'hi-IN': 'आप क्या बेचना चाहते हैं?',
    'ta-IN': 'நீங்கள் என்ன விற்க விரும்புகிறீர்கள்?',
    'te-IN': 'మీరు ఏమి అమ్మాలనుకుంటున్నారు?',
  };

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();
    _setupAnimations();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _pulseController.repeat(reverse: true);
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: _onSpeechStatus,
      onError: _onSpeechError,
    );
    setState(() {});
  }

  Future<void> _initTts() async {
    await _tts.setLanguage(_selectedLanguage);
    await _tts.setSpeechRate(0.4);
    await _tts.setVolume(1.0);
  }

  void _onSpeechStatus(String status) {
    if (status == 'notListening' && _isListening) {
      setState(() => _isListening = false);
      if (_transcribedText.isNotEmpty) {
        _processTranscription();
      }
    }
  }

  void _onSpeechError(dynamic error) {
    setState(() {
      _isListening = false;
      _failedAttempts++;
    });
    
    if (_failedAttempts >= 3) {
      _showFallbackOption();
    } else {
      _showErrorSnackbar();
    }
  }

  void _showErrorSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Sorry, I didn't catch that. Try again?"),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: _startListening,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showFallbackOption() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Having trouble? Try manual selection'),
        action: SnackBarAction(
          label: 'Manual',
          onPressed: () => Navigator.pushNamed(context, '/crop-selection'),
        ),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _startListening() async {
    if (!_speechAvailable) {
      _showErrorSnackbar();
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _isListening = true;
      _transcribedText = '';
    });

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _transcribedText = result.recognizedWords;
          _confidence = result.confidence;
        });
      },
      localeId: _selectedLanguage,
      listenMode: ListenMode.confirmation,
      partialResults: true,
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _speakPrompt() async {
    await _tts.setLanguage(_selectedLanguage);
    await _tts.speak(_voicePrompts[_selectedLanguage] ?? _voicePrompts['en-IN']!);
  }

  void _processTranscription() {
    if (_transcribedText.isEmpty) return;
    
    // Simple NLP extraction (crop + quantity)
    // This is placeholder - will be enhanced with backend NLP
    final extracted = _extractCropAndQuantity(_transcribedText);
    
    Navigator.pushNamed(
      context,
      '/listing-confirmation',
      arguments: {
        'transcribedText': _transcribedText,
        'cropType': extracted['crop'] ?? _transcribedText,
        'quantity': extracted['quantity'] ?? 0.0,
        'unit': extracted['unit'] ?? 'kg',
        'confidence': _confidence,
        'language': _selectedLanguage,
      },
    );
  }

  Map<String, dynamic> _extractCropAndQuantity(String text) {
    // Simple regex-based extraction (placeholder)
    // Will be replaced with server-side NLP
    final lowerText = text.toLowerCase();
    
    // Common crops
    final crops = ['tomato', 'potato', 'onion', 'cabbage', 'carrot', 'beans'];
    String? foundCrop;
    
    for (final crop in crops) {
      if (lowerText.contains(crop)) {
        foundCrop = crop[0].toUpperCase() + crop.substring(1);
        break;
      }
    }
    
    // Extract number
    final numberMatch = RegExp(r'(\d+(?:\.\d+)?)\s*(kg|kilo|kilos|quintal|quintals)?')
        .firstMatch(lowerText);
    
    double quantity = 0.0;
    String unit = 'kg';
    
    if (numberMatch != null) {
      quantity = double.tryParse(numberMatch.group(1) ?? '0') ?? 0.0;
      final unitMatch = numberMatch.group(2);
      if (unitMatch != null && unitMatch.contains('quintal')) {
        quantity *= 100; // Convert quintal to kg
        unit = 'kg';
      }
    }
    
    return {
      'crop': foundCrop,
      'quantity': quantity,
      'unit': unit,
    };
  }

  void _onLanguageChanged(String? languageCode) {
    if (languageCode != null) {
      setState(() => _selectedLanguage = languageCode);
      _initTts();
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('List Your Crop'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Language selector
          PopupMenuButton<String>(
            initialValue: _selectedLanguage,
            onSelected: _onLanguageChanged,
            itemBuilder: (context) => _languages.map((lang) {
              return PopupMenuItem(
                value: lang['code'],
                child: Row(
                  children: [
                    Text(lang['native']!),
                    const SizedBox(width: 8),
                    Text(
                      lang['name']!,
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.language, color: AppColors.secondary),
                  const SizedBox(width: 4),
                  Text(
                    _languages.firstWhere((l) => l['code'] == _selectedLanguage)['native']!,
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),
            
            // Voice prompt text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                children: [
                  Text(
                    _voicePrompts[_selectedLanguage] ?? _voicePrompts['en-IN']!,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _isListening ? 'Listening...' : 'Tap the microphone to speak',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Transcription preview
            if (_transcribedText.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(Icons.format_quote, color: AppColors.outline),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _transcribedText,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            const Spacer(flex: 2),
            
            // Animated microphone button
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isListening ? _pulseAnimation.value : 1.0,
                  child: GestureDetector(
                    onTap: _isListening ? _stopListening : _startListening,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: _isListening
                              ? [AppColors.error, Colors.red.shade700]
                              : [AppColors.secondary, AppColors.primary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_isListening ? AppColors.error : AppColors.secondary)
                                .withValues(alpha: 0.4),
                            blurRadius: _isListening ? 24 : 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.stop : Icons.mic,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Status indicator
            if (_isListening)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Recording',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            
            const Spacer(flex: 2),
            
            // Bottom actions
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  // TTS button to hear prompt
                  OutlinedButton.icon(
                    onPressed: _speakPrompt,
                    icon: const Icon(Icons.volume_up),
                    label: const Text('Hear prompt'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Manual entry fallback
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/crop-selection'),
                    child: Text(
                      'Or select crop manually',
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
