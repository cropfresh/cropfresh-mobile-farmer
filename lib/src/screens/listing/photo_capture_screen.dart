import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../constants/app_colors.dart';

/// PhotoCaptureScreen - Story 3.2 (AC1, AC2)
/// 
/// A premium camera capture experience with:
/// - Live camera preview with produce outline overlay (AC1)
/// - Voice prompts in selected language (AC1)
/// - Example photo guide in corner (AC1)
/// - Portrait orientation for single-hand use (AC1)
/// - Capture with Retake/Use buttons (AC2)
/// - Voice confirmation after capture (AC2)
/// - Analyzing state with spinner (AC2)
/// 
/// Material Design 3 compliant with WCAG accessibility
class PhotoCaptureScreen extends StatefulWidget {
  const PhotoCaptureScreen({super.key});

  @override
  State<PhotoCaptureScreen> createState() => _PhotoCaptureScreenState();
}

class _PhotoCaptureScreenState extends State<PhotoCaptureScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  // Camera Controller
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isCameraError = false;
  String _cameraErrorMessage = '';

  // TTS for voice prompts
  final FlutterTts _tts = FlutterTts();
  bool _ttsInitialized = false;

  // Capture state
  XFile? _capturedImage;
  bool _isCapturing = false;
  bool _isAnalyzing = false;
  bool _showExamplePhoto = true;

  // Data from previous screen
  String _cropType = '';
  String _cropEmoji = '🌾';
  double _quantity = 0.0;
  String _entryMode = 'voice';
  String _language = 'en';
  int? _listingId;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _overlayFadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _overlayFadeAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize animations
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _overlayFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _overlayFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _overlayFadeController, curve: Curves.easeOut),
    );

    // Initialize camera and TTS
    _initializeCamera();
    _initializeTts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadArguments();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _tts.stop();
    _pulseController.dispose();
    _overlayFadeController.dispose();
    super.dispose();
  }

  void _loadArguments() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        _cropType = args['cropType'] ?? '';
        _cropEmoji = args['cropEmoji'] ?? '🌾';
        _quantity = (args['quantity'] ?? 0.0).toDouble();
        _entryMode = args['entryMode'] ?? 'voice';
        _language = args['language'] ?? 'en';
        _listingId = args['listingId'];
      });
    }
  }

  Future<void> _initializeTts() async {
    try {
      await _tts.setLanguage(_getLanguageCode());
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      setState(() => _ttsInitialized = true);
    } catch (e) {
      debugPrint('TTS initialization error: $e');
    }
  }

  String _getLanguageCode() {
    switch (_language) {
      case 'kn': return 'kn-IN';
      case 'hi': return 'hi-IN';
      case 'ta': return 'ta-IN';
      case 'te': return 'te-IN';
      default: return 'en-IN';
    }
  }

  Future<void> _speak(String text) async {
    if (_ttsInitialized) {
      await _tts.speak(text);
    }
  }

  Future<void> _initializeCamera() async {
    // Request camera permission
    final status = await Permission.camera.request();
    
    if (status.isDenied || status.isPermanentlyDenied) {
      if (mounted) {
        setState(() {
          _isCameraError = true;
          _cameraErrorMessage = 'Camera permission denied';
        });
        _showPermissionDeniedDialog();
      }
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _isCameraError = true;
          _cameraErrorMessage = 'No cameras available';
        });
        return;
      }

      // Use back camera
      final backCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high, // 1024x768 minimum for AC3
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();
      
      // Lock to portrait orientation for single-hand use (AC1)
      await _cameraController!.lockCaptureOrientation(DeviceOrientation.portraitUp);

      if (mounted) {
        setState(() => _isCameraInitialized = true);
        _overlayFadeController.forward();
        
        // Speak instructions (AC1)
        await Future.delayed(const Duration(milliseconds: 500));
        _speak(_getPositionInstructions());
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCameraError = true;
          _cameraErrorMessage = 'Camera initialization failed: $e';
        });
      }
    }
  }

  String _getPositionInstructions() {
    final crop = _cropType.isNotEmpty ? _cropType.toLowerCase() : 'produce';
    switch (_language) {
      case 'kn':
        return 'ನಿಮ್ಮ $crop ಅನ್ನು ಫ್ರೇಮ್‌ನಲ್ಲಿ ಇರಿಸಿ';
      case 'hi':
        return 'अपना $crop फ्रेम में रखें';
      case 'ta':
        return 'உங்கள் $crop ஐ சட்டத்தில் வைக்கவும்';
      case 'te':
        return 'మీ $crop ను ఫ్రేమ్‌లో ఉంచండి';
      default:
        return 'Position your $crop in the frame';
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.camera_alt, color: AppColors.primary),
            const SizedBox(width: 12),
            const Text('Camera Permission'),
          ],
        ),
        content: const Text(
          'Camera permission is required to take photos of your produce for quality grading. '
          'Please enable it in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            icon: const Icon(Icons.settings),
            label: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || 
        !_cameraController!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _isCapturing = true;
      _showExamplePhoto = false;
    });

    try {
      final XFile image = await _cameraController!.takePicture();
      
      setState(() {
        _capturedImage = image;
        _isCapturing = false;
        _isAnalyzing = true;
      });

      // Voice confirmation (AC2)
      _speak(_getVoiceConfirmation());

      // Simulate quality analysis (will connect to backend in Phase 2)
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCapturing = false);
        _showErrorSnackBar('Failed to capture photo: $e');
      }
    }
  }

  String _getVoiceConfirmation() {
    switch (_language) {
      case 'kn':
        return 'ಫೋಟೋ ಚೆನ್ನಾಗಿದೆ. ಗುಣಮಟ್ಟ ಪರಿಶೀಲಿಸಲಾಗುತ್ತಿದೆ';
      case 'hi':
        return 'फोटो अच्छी है। गुणवत्ता जांच रहे हैं';
      case 'ta':
        return 'புகைப்படம் நன்றாக இருக்கிறது. தரம் சரிபார்க்கப்படுகிறது';
      case 'te':
        return 'ఫోటో బాగుంది. నాణ్యత తనిఖీ చేస్తోంది';
      default:
        return 'Photo looks good. Checking quality';
    }
  }

  void _retakePhoto() {
    HapticFeedback.lightImpact();
    setState(() {
      _capturedImage = null;
      _isAnalyzing = false;
      _showExamplePhoto = true;
    });
    _overlayFadeController.forward();
    _speak(_getPositionInstructions());
  }

  void _usePhoto() {
    if (_capturedImage == null) return;
    
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(
      context,
      '/photo-review',
      arguments: {
        'cropType': _cropType,
        'cropEmoji': _cropEmoji,
        'quantity': _quantity,
        'entryMode': _entryMode,
        'photoPath': _capturedImage!.path,
        'language': _language,
        'listingId': _listingId,
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildCameraArea()),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Close camera',
        ),
      ),
      actions: [
        if (_cropType.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_cropEmoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  '$_cropType ${_quantity.toInt()}kg',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCameraArea() {
    // Show captured image in review mode
    if (_capturedImage != null) {
      return _buildCapturedImageView();
    }

    // Show camera preview
    if (_isCameraInitialized && _cameraController != null) {
      return _buildCameraPreview();
    }

    // Show error state
    if (_isCameraError) {
      return _buildErrorState();
    }

    // Show loading state
    return _buildLoadingState();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Initializing camera...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_alt_outlined,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Camera Unavailable',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _cameraErrorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _initializeCamera,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview
        ClipRect(
          child: OverflowBox(
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _cameraController!.value.previewSize!.height,
                height: _cameraController!.value.previewSize!.width,
                child: CameraPreview(_cameraController!),
              ),
            ),
          ),
        ),

        // Produce outline overlay (AC1)
        FadeTransition(
          opacity: _overlayFadeAnimation,
          child: _buildProduceOverlay(),
        ),

        // Example photo hint (AC1)
        if (_showExamplePhoto)
          Positioned(
            top: 80,
            right: 16,
            child: _buildExamplePhotoHint(),
          ),

        // Position instruction (AC1)
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: _buildPositionInstruction(),
        ),
      ],
    );
  }

  Widget _buildProduceOverlay() {
    return Center(
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.8),
              width: 3,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            children: [
              // Corner markers
              ..._buildCornerMarkers(),
              // Center hint
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _cropEmoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCornerMarkers() {
    const markerSize = 24.0;
    const markerWidth = 4.0;
    final color = AppColors.secondary;

    return [
      // Top-left
      Positioned(
        top: 0, left: 0,
        child: Container(
          width: markerSize, height: markerWidth,
          color: color,
        ),
      ),
      Positioned(
        top: 0, left: 0,
        child: Container(
          width: markerWidth, height: markerSize,
          color: color,
        ),
      ),
      // Top-right
      Positioned(
        top: 0, right: 0,
        child: Container(
          width: markerSize, height: markerWidth,
          color: color,
        ),
      ),
      Positioned(
        top: 0, right: 0,
        child: Container(
          width: markerWidth, height: markerSize,
          color: color,
        ),
      ),
      // Bottom-left
      Positioned(
        bottom: 0, left: 0,
        child: Container(
          width: markerSize, height: markerWidth,
          color: color,
        ),
      ),
      Positioned(
        bottom: 0, left: 0,
        child: Container(
          width: markerWidth, height: markerSize,
          color: color,
        ),
      ),
      // Bottom-right
      Positioned(
        bottom: 0, right: 0,
        child: Container(
          width: markerSize, height: markerWidth,
          color: color,
        ),
      ),
      Positioned(
        bottom: 0, right: 0,
        child: Container(
          width: markerWidth, height: markerSize,
          color: color,
        ),
      ),
    ];
  }

  Widget _buildExamplePhotoHint() {
    return GestureDetector(
      onTap: () => setState(() => _showExamplePhoto = false),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.secondary, width: 2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(_cropEmoji, style: const TextStyle(fontSize: 32)),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Good photo',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionInstruction() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.center_focus_strong,
            color: AppColors.secondary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              _getPositionInstructions(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 10),
          // Speaker icon for voice repeat
          GestureDetector(
            onTap: () => _speak(_getPositionInstructions()),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.volume_up,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapturedImageView() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Captured image
        Image.file(
          File(_capturedImage!.path),
          fit: BoxFit.contain,
        ),

        // Analyzing overlay (AC2)
        if (_isAnalyzing) _buildAnalyzingOverlay(),

        // Success badge
        if (!_isAnalyzing) _buildSuccessBadge(),
      ],
    );
  }

  Widget _buildAnalyzingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Analyzing photo quality...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Checking focus, lighting, and clarity',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessBadge() {
    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              const Text(
                'Photo looks great!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: _capturedImage != null
          ? _buildReviewActions()
          : _buildCaptureButton(),
    );
  }

  Widget _buildCaptureButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Capture button (large, centered)
        GestureDetector(
          onTap: _isCameraInitialized && !_isCapturing ? _capturePhoto : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              color: _isCapturing
                  ? Colors.grey.shade600
                  : Colors.white.withValues(alpha: 0.2),
            ),
            child: _isCapturing
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 36,
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _isCapturing ? 'Capturing...' : 'Tap to capture',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewActions() {
    return Row(
      children: [
        // Retake button (AC2)
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: _retakePhoto,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Retake',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Use Photo button (AC2)
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: _isAnalyzing ? null : _usePhoto,
              icon: const Icon(Icons.check),
              label: const Text(
                'Use This Photo',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                disabledBackgroundColor: Colors.grey.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
