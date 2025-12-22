import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_colors.dart';
import '../../core/animations/animation_constants.dart';

/// Language Selection Screen - AC2 (Story 2.1)
/// 5 language options in 2-column grid with speaker icons
/// Voice prompt auto-play, immediate UI switch on selection
class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with TickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  String? _selectedLanguage;
  bool _isNavigating = false;
  
  late AnimationController _staggerController;
  late AnimationController _headerController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  final List<Map<String, String>> _languages = [
    {
      'code': 'kn',
      'name': 'ಕನ್ನಡ',
      'english': 'Kannada',
      'greeting': 'ನಮಸ್ಕಾರ',
    },
    {
      'code': 'hi',
      'name': 'हिंदी',
      'english': 'Hindi',
      'greeting': 'नमस्ते',
    },
    {
      'code': 'ta',
      'name': 'தமிழ்',
      'english': 'Tamil',
      'greeting': 'வணக்கம்',
    },
    {
      'code': 'te',
      'name': 'తెలుగు',
      'english': 'Telugu',
      'greeting': 'నమస్కారం',
    },
    {
      'code': 'en',
      'name': 'English',
      'english': 'English',
      'greeting': 'Hello',
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _playVoicePrompt();
  }

  void _setupAnimations() {
    // Header animation
    _headerController = AnimationController(
      duration: AnimationConstants.durationMedium,
      vsync: this,
    );
    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: AnimationConstants.curveEmphasized,
    ));

    // Stagger animation for language cards
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Start animations
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _staggerController.forward();
    });
  }

  Future<void> _playVoicePrompt() async {
    try {
      await _flutterTts.setLanguage('en-IN');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.speak('Namaste! Please select your language.');
    } catch (e) {
      debugPrint('TTS error: $e');
    }
  }

  Future<void> _playLanguageSample(String languageCode) async {
    HapticFeedback.lightImpact();
    
    final language = _languages.firstWhere((l) => l['code'] == languageCode);
    final greeting = language['greeting'] ?? 'Hello';
    
    try {
      // Map language codes to TTS locales
      final localeMap = {
        'kn': 'kn-IN',
        'hi': 'hi-IN',
        'ta': 'ta-IN',
        'te': 'te-IN',
        'en': 'en-IN',
      };
      
      await _flutterTts.setLanguage(localeMap[languageCode] ?? 'en-IN');
      await _flutterTts.setSpeechRate(0.4);
      await _flutterTts.speak(greeting);
    } catch (e) {
      debugPrint('TTS error: $e');
    }
  }

  Future<void> _selectLanguage(String languageCode) async {
    if (_isNavigating) return;
    
    HapticFeedback.mediumImpact();
    
    setState(() {
      _selectedLanguage = languageCode;
      _isNavigating = true;
    });

    // Store language preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_preference', languageCode);

    // Delay for selection animation
    await Future.delayed(AnimationConstants.durationMedium);

    // Navigate to welcome screen (AC3 split: Welcome → Permissions)
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/welcome');
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _staggerController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              
              // Animated Header
              SlideTransition(
                position: _headerSlide,
                child: FadeTransition(
                  opacity: _headerFade,
                  child: _buildHeader(),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Language Grid
              Expanded(
                child: _buildLanguageGrid(),
              ),
              
              // Helper text
              FadeTransition(
                opacity: _headerFade,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'You can change language later in Settings',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Greeting with emoji
        const Text(
          'Namaste! 🙏',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Select Your Language',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'ನಿಮ್ಮ ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageGrid() {
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
          ),
          itemCount: _languages.length,
          itemBuilder: (context, index) {
            // Calculate staggered animation for each item
            final startTime = index * 0.15;
            final endTime = startTime + 0.4;
            
            final itemAnimation = Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(
                parent: _staggerController,
                curve: Interval(
                  startTime.clamp(0, 1),
                  endTime.clamp(0, 1),
                  curve: AnimationConstants.curveEmphasized,
                ),
              ),
            );
            
            return FadeTransition(
              opacity: itemAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(itemAnimation),
                child: _buildLanguageCard(_languages[index]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLanguageCard(Map<String, String> language) {
    final isSelected = _selectedLanguage == language['code'];
    
    return GestureDetector(
      onTap: () => _selectLanguage(language['code']!),
      child: AnimatedContainer(
        duration: AnimationConstants.durationShort,
        curve: AnimationConstants.curveStandard,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Native language name
                  Text(
                    language['name']!,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // English name
                  Text(
                    language['english']!,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected
                          ? AppColors.onPrimaryContainer
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            
            // Speaker icon button (top right)
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _playLanguageSample(language['code']!),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.surfaceContainerHigh,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.volume_up_rounded,
                      size: 20,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
            
            // Selection checkmark (bottom right)
            if (isSelected)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
