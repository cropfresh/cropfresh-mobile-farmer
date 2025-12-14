import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';

/// ListingConfirmationScreen - Confirm extracted crop + quantity (Story 3.1 AC2, AC3)
/// 
/// Shows:
/// - Extracted crop type and quantity
/// - Visual confirmation with checkmark
/// - Yes/No confirmation buttons
/// - Voice confirmation prompt via TTS
class ListingConfirmationScreen extends StatefulWidget {
  const ListingConfirmationScreen({super.key});

  @override
  State<ListingConfirmationScreen> createState() => _ListingConfirmationScreenState();
}

class _ListingConfirmationScreenState extends State<ListingConfirmationScreen>
    with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  
  late AnimationController _checkController;
  late Animation<double> _checkScale;
  
  String _cropType = '';
  double _quantity = 0.0;
  String _unit = 'kg';
  String _transcribedText = '';
  double _confidence = 0.0;
  String _language = 'en-IN';

  final Map<String, String> _confirmPrompts = {
    'en-IN': 'Is this correct?',
    'kn-IN': 'ಇದು ಸರಿಯೇ?',
    'hi-IN': 'क्या यह सही है?',
    'ta-IN': 'இது சரியா?',
    'te-IN': 'ఇది సరైనదా?',
  };

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initTts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadArguments();
  }

  void _loadArguments() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        _cropType = args['cropType'] ?? '';
        _quantity = (args['quantity'] ?? 0.0).toDouble();
        _unit = args['unit'] ?? 'kg';
        _transcribedText = args['transcribedText'] ?? '';
        _confidence = (args['confidence'] ?? 0.0).toDouble();
        _language = args['language'] ?? 'en-IN';
      });
      
      // Auto-play confirmation prompt
      Future.delayed(const Duration(milliseconds: 500), _speakConfirmation);
    }
  }

  void _setupAnimations() {
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _checkScale = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );
    
    _checkController.forward();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage(_language);
    await _tts.setSpeechRate(0.4);
  }

  Future<void> _speakConfirmation() async {
    await _tts.setLanguage(_language);
    final prompt = _confirmPrompts[_language] ?? _confirmPrompts['en-IN']!;
    await _tts.speak('$_cropType, ${_quantity.toInt()} $_unit. $prompt');
  }

  void _onConfirm() {
    HapticFeedback.mediumImpact();
    
    // TODO: Create draft listing via API
    // For now, navigate to photo capture placeholder
    Navigator.pushNamed(
      context,
      '/photo-capture',
      arguments: {
        'cropType': _cropType,
        'quantity': _quantity,
        'unit': _unit,
      },
    );
  }

  void _onReject() {
    HapticFeedback.lightImpact();
    Navigator.pop(context); // Go back to voice input
  }

  void _onEdit() {
    Navigator.pushNamed(context, '/crop-selection', arguments: {
      'cropType': _cropType,
      'quantity': _quantity,
    });
  }

  @override
  void dispose() {
    _tts.stop();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Confirm Listing'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const Spacer(flex: 1),
              
              // Success icon
              ScaleTransition(
                scale: _checkScale,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondary,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Extracted info card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Column(
                  children: [
                    // Crop type
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getCropEmoji(_cropType),
                          style: const TextStyle(fontSize: 48),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _cropType.isNotEmpty ? _cropType : 'Unknown Crop',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              '${_quantity.toInt()} $_unit',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const Divider(height: AppSpacing.xl),
                    
                    // Original text
                    if (_transcribedText.isNotEmpty)
                      Column(
                        children: [
                          Text(
                            'You said:',
                            style: TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '"$_transcribedText"',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: AppColors.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    
                    if (_confidence > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.signal_cellular_alt,
                              size: 14,
                              color: _confidence > 0.8 ? AppColors.primary : AppColors.outline,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${(_confidence * 100).toInt()}% confidence',
                              style: TextStyle(
                                color: AppColors.outline,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Edit button
              TextButton.icon(
                onPressed: _onEdit,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit details'),
              ),
              
              const Spacer(flex: 2),
              
              // Confirmation prompt
              Text(
                _confirmPrompts[_language] ?? _confirmPrompts['en-IN']!,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Yes/No buttons
              Row(
                children: [
                  // No button
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: _onReject,
                        icon: const Icon(Icons.close),
                        label: const Text('No'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Yes button
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 56,
                      child: FilledButton.icon(
                        onPressed: _onConfirm,
                        icon: const Icon(Icons.check),
                        label: const Text('Yes, Correct'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  String _getCropEmoji(String crop) {
    final emojiMap = {
      'Tomato': '🍅',
      'Potato': '🥔',
      'Onion': '🧅',
      'Cabbage': '🥬',
      'Carrot': '🥕',
      'Beans': '🫛',
      'Pepper': '🌶️',
      'Corn': '🌽',
      'Brinjal': '🍆',
      'Cucumber': '🥒',
    };
    return emojiMap[crop] ?? '🥬';
  }
}
