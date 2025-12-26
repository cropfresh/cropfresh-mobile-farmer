import 'dart:async';
import 'package:flutter/foundation.dart';
// import 'package:speech_to_text/speech_to_text.dart';

/// VoiceInputService - Story 3.9 (AC3, AC10)
/// 
/// Handles voice input for quantity updates with:
/// - Speech-to-text conversion
/// - Number extraction from voice ("30 kilos" → 30)
/// - Multi-language support (English, Kannada, Hindi)
/// - Voice confirmation ("confirm" / "cancel")
/// 
/// Note: Actual speech_to_text integration requires device permissions
/// and is platform-dependent. This service provides the abstraction layer.
class VoiceInputService extends ChangeNotifier {
  // final SpeechToText _speech = SpeechToText();
  
  bool _isListening = false;
  bool _isAvailable = false;
  String _lastResult = '';
  String _currentLocale = 'en-IN';
  double? _extractedNumber;

  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;
  String get lastResult => _lastResult;
  double? get extractedNumber => _extractedNumber;

  /// Supported locales for voice input
  static const Map<String, String> supportedLocales = {
    'en-IN': 'English (India)',
    'kn-IN': 'Kannada',
    'hi-IN': 'Hindi',
    'ta-IN': 'Tamil',
    'te-IN': 'Telugu',
  };

  /// Initialize the speech recognition service
  Future<bool> initialize() async {
    try {
      // _isAvailable = await _speech.initialize(
      //   onStatus: _onStatus,
      //   onError: _onError,
      // );
      
      // Simulate availability for demo
      _isAvailable = true;
      notifyListeners();
      return _isAvailable;
    } catch (e) {
      debugPrint('Voice input init error: $e');
      _isAvailable = false;
      notifyListeners();
      return false;
    }
  }

  /// Start listening for voice input
  /// 
  /// Returns a Future that completes when listening stops
  Future<VoiceInputResult> listen({
    Duration timeout = const Duration(seconds: 10),
    String? locale,
  }) async {
    if (!_isAvailable) {
      await initialize();
    }

    if (!_isAvailable) {
      return VoiceInputResult(
        success: false,
        error: 'Voice input not available on this device',
      );
    }

    _currentLocale = locale ?? _currentLocale;
    _isListening = true;
    _lastResult = '';
    _extractedNumber = null;
    notifyListeners();

    final completer = Completer<VoiceInputResult>();

    try {
      // Simulate voice recognition for demo
      // In real implementation:
      // await _speech.listen(
      //   onResult: (result) => _onResult(result, completer),
      //   localeId: _currentLocale,
      //   listenFor: timeout,
      // );
      
      // Demo: Return after timeout
      Timer(timeout, () {
        if (!completer.isCompleted) {
          _stopListening();
          completer.complete(VoiceInputResult(
            success: false,
            error: 'Listening timed out',
          ));
        }
      });

    } catch (e) {
      _isListening = false;
      notifyListeners();
      return VoiceInputResult(
        success: false,
        error: 'Voice input error: $e',
      );
    }

    return completer.future;
  }

  /// Manually set result (for testing or demo)
  void setResult(String result) {
    _lastResult = result;
    _extractedNumber = extractNumber(result);
    notifyListeners();
  }

  /// Stop listening
  void _stopListening() {
    // _speech.stop();
    _isListening = false;
    notifyListeners();
  }

  /// Cancel listening
  void cancel() {
    // _speech.cancel();
    _isListening = false;
    _lastResult = '';
    _extractedNumber = null;
    notifyListeners();
  }

  /// Extract number from voice text
  /// 
  /// Handles patterns like:
  /// - "30 kilos" → 30
  /// - "thirty kg" → 30
  /// - "50" → 50
  /// - Kannada numbers (placeholder)
  static double? extractNumber(String text) {
    if (text.isEmpty) return null;

    final cleanText = text.toLowerCase().trim();

    // Try direct number extraction
    final directNumber = RegExp(r'(\d+\.?\d*)').firstMatch(cleanText);
    if (directNumber != null) {
      return double.tryParse(directNumber.group(1)!);
    }

    // Word to number mapping (English)
    final wordNumbers = <String, double>{
      'zero': 0, 'one': 1, 'two': 2, 'three': 3, 'four': 4,
      'five': 5, 'six': 6, 'seven': 7, 'eight': 8, 'nine': 9,
      'ten': 10, 'eleven': 11, 'twelve': 12, 'thirteen': 13,
      'fourteen': 14, 'fifteen': 15, 'sixteen': 16, 'seventeen': 17,
      'eighteen': 18, 'nineteen': 19, 'twenty': 20, 'thirty': 30,
      'forty': 40, 'fifty': 50, 'sixty': 60, 'seventy': 70,
      'eighty': 80, 'ninety': 90, 'hundred': 100,
    };

    // Check for word numbers
    for (final entry in wordNumbers.entries) {
      if (cleanText.contains(entry.key)) {
        return entry.value;
      }
    }

    // Kannada number words (common ones)
    final kannadaNumbers = <String, double>{
      'ಒಂದು': 1, 'ಎರಡು': 2, 'ಮೂರು': 3, 'ನಾಲ್ಕು': 4, 'ಐದು': 5,
      'ಆರು': 6, 'ಏಳು': 7, 'ಎಂಟು': 8, 'ಒಂಬತ್ತು': 9, 'ಹತ್ತು': 10,
      'ಇಪ್ಪತ್ತು': 20, 'ಮೂವತ್ತು': 30, 'ನಲವತ್ತು': 40, 'ಐವತ್ತು': 50,
    };

    for (final entry in kannadaNumbers.entries) {
      if (cleanText.contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  /// Check if text indicates confirmation
  static bool isConfirmation(String text) {
    final confirmWords = [
      'confirm', 'yes', 'save', 'okay', 'ok', 'proceed',
      'ಹೌದು', 'ಸರಿ', // Kannada: yes, okay
      'हाँ', 'हां', // Hindi: yes
    ];
    
    final cleanText = text.toLowerCase().trim();
    return confirmWords.any((word) => cleanText.contains(word));
  }

  /// Check if text indicates cancellation
  static bool isCancellation(String text) {
    final cancelWords = [
      'cancel', 'no', 'stop', 'back', 'nevermind',
      'ಬೇಡ', 'ರದ್ದು', // Kannada: no, cancel
      'नहीं', 'रद्द', // Hindi: no, cancel
    ];
    
    final cleanText = text.toLowerCase().trim();
    return cancelWords.any((word) => cleanText.contains(word));
  }
}

/// Result from voice input
class VoiceInputResult {
  final bool success;
  final String? text;
  final double? number;
  final String? error;
  final bool isConfirmation;
  final bool isCancellation;

  VoiceInputResult({
    required this.success,
    this.text,
    this.number,
    this.error,
    this.isConfirmation = false,
    this.isCancellation = false,
  });

  factory VoiceInputResult.fromText(String text) {
    return VoiceInputResult(
      success: true,
      text: text,
      number: VoiceInputService.extractNumber(text),
      isConfirmation: VoiceInputService.isConfirmation(text),
      isCancellation: VoiceInputService.isCancellation(text),
    );
  }
}
