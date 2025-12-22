import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path_lib;
import '../../constants/app_colors.dart';
import '../../models/photo_quality_models.dart';

/// PhotoReviewScreen - Story 3.2 (AC2, AC3, AC4, AC5)
/// 
/// Premium photo review experience with:
/// - High-quality image preview (AC2)
/// - Client-side compression to ≤800KB (AC3)
/// - Quality validation feedback (AC3, AC4)
/// - Upload progress indicator (AC5)
/// - Quality guidance overlays (AC4)
/// 
/// Material Design 3 with smooth animations
class PhotoReviewScreen extends StatefulWidget {
  const PhotoReviewScreen({super.key});

  @override
  State<PhotoReviewScreen> createState() => _PhotoReviewScreenState();
}

class _PhotoReviewScreenState extends State<PhotoReviewScreen>
    with SingleTickerProviderStateMixin {
  // Photo data
  String _photoPath = '';
  File? _originalFile;
  File? _compressedFile;
  
  // Compression stats
  int _originalSizeKb = 0;
  int _compressedSizeKb = 0;
  int _imageWidth = 0;
  int _imageHeight = 0;
  
  // State
  bool _isCompressing = false;
  bool _isValidating = false;
  bool _isUploading = false;
  bool _compressionComplete = false;
  double _uploadProgress = 0.0;
  
  // Quality validation (simulated until backend Phase 2)
  PhotoQualityResult? _qualityResult;
  bool _showQualityGuidance = false;
  
  // Data from previous screen
  String _cropType = '';
  String _cropEmoji = '🌾';
  double _quantity = 0.0;
  String _entryMode = 'voice';
  String _language = 'en';
  int? _listingId;

  // TTS and Animation
  final FlutterTts _tts = FlutterTts();
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
    );
    _initializeTts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadArguments();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _tts.stop();
    super.dispose();
  }

  void _loadArguments() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && _photoPath.isEmpty) {
      _photoPath = args['photoPath'] ?? '';
      _cropType = args['cropType'] ?? '';
      _cropEmoji = args['cropEmoji'] ?? '🌾';
      _quantity = (args['quantity'] ?? 0.0).toDouble();
      _entryMode = args['entryMode'] ?? 'voice';
      _language = args['language'] ?? 'en';
      _listingId = args['listingId'];
      
      if (_photoPath.isNotEmpty) {
        _originalFile = File(_photoPath);
        _processPhoto();
      }
    }
  }

  Future<void> _initializeTts() async {
    try {
      await _tts.setLanguage(_getLanguageCode());
      await _tts.setSpeechRate(0.5);
    } catch (e) {
      debugPrint('TTS init error: $e');
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
    await _tts.speak(text);
  }

  Future<void> _processPhoto() async {
    if (_originalFile == null) return;

    setState(() => _isCompressing = true);

    try {
      // Get original file size
      final originalBytes = await _originalFile!.length();
      _originalSizeKb = (originalBytes / 1024).round();

      // Read and decode image
      final bytes = await _originalFile!.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      _imageWidth = image.width;
      _imageHeight = image.height;

      // Check minimum resolution (AC3: 1024x768)
      final meetsMinResolution = _imageWidth >= 1024 && _imageHeight >= 768;

      // Compress to ≤800KB (AC3)
      Uint8List compressedBytes;
      int quality = 85;
      
      do {
        compressedBytes = Uint8List.fromList(
          img.encodeJpg(image, quality: quality),
        );
        quality -= 5;
      } while (compressedBytes.length > 800 * 1024 && quality > 20);

      // Save compressed file
      final tempDir = await getTemporaryDirectory();
      final compressedPath = path_lib.join(
        tempDir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      _compressedFile = await File(compressedPath).writeAsBytes(compressedBytes);
      _compressedSizeKb = (compressedBytes.length / 1024).round();

      setState(() {
        _isCompressing = false;
        _compressionComplete = true;
      });

      // Validate quality (simulated - will connect to backend in Phase 2)
      await _validateQuality(meetsMinResolution);
      
    } catch (e) {
      setState(() => _isCompressing = false);
      _showErrorSnackBar('Failed to process photo: $e');
    }
  }

  Future<void> _validateQuality(bool meetsMinResolution) async {
    setState(() => _isValidating = true);

    // Simulate validation delay (Phase 2 will call actual API)
    await Future.delayed(const Duration(seconds: 1));

    // Simulated quality check
    final issues = <PhotoQualityIssue>[];
    
    if (!meetsMinResolution) {
      issues.add(PhotoQualityIssue(
        type: QualityIssueType.lowResolution,
        message: 'Photo resolution is too low',
        suggestion: 'Move closer to the produce for a clearer photo',
      ));
    }

    // Random simulation of other issues (will be real AI in Phase 2)
    // For demo, always pass
    
    setState(() {
      _isValidating = false;
      _qualityResult = PhotoQualityResult(
        isValid: issues.isEmpty,
        qualityScore: issues.isEmpty ? 0.92 : 0.45,
        issues: issues,
      );
      
      if (!_qualityResult!.isValid) {
        _showQualityGuidance = true;
        _speakQualityGuidance();
      }
    });

    _progressController.forward();
  }

  void _speakQualityGuidance() {
    if (_qualityResult == null || _qualityResult!.issues.isEmpty) return;
    
    final issue = _qualityResult!.issues.first;
    String message;
    
    switch (_language) {
      case 'kn':
        message = issue.type == QualityIssueType.tooDark
            ? 'ಫೋಟೋ ತುಂಬಾ ಡಾರ್ಕ್ ಆಗಿದೆ. ಹೆಚ್ಚಿನ ಬೆಳಕಿನಲ್ಲಿ ಪ್ರಯತ್ನಿಸಿ'
            : 'ಫೋಟೋ ಗುಣಮಟ್ಟ ಸುಧಾರಿಸಿ';
        break;
      case 'hi':
        message = issue.type == QualityIssueType.tooDark
            ? 'फोटो बहुत डार्क है। अधिक रोशनी में प्रयास करें'
            : 'फोटो गुणवत्ता सुधारें';
        break;
      default:
        message = issue.suggestion;
    }
    
    _speak(message);
  }

  Future<void> _uploadPhoto() async {
    if (_compressedFile == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    HapticFeedback.mediumImpact();

    try {
      // Simulate upload progress (Phase 2 will use actual presigned URL)
      for (int i = 0; i <= 100; i += 5) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          setState(() => _uploadProgress = i / 100);
        }
      }

      // Success!
      if (mounted) {
        HapticFeedback.heavyImpact();
        _navigateToNextScreen();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        _showErrorSnackBar('Upload failed: $e');
      }
    }
  }

  void _navigateToNextScreen() {
    // Navigate to AI grading screen (Story 3.3)
    Navigator.pushReplacementNamed(
      context,
      '/grading-results',
      arguments: {
        'cropType': _cropType,
        'cropEmoji': _cropEmoji,
        'quantity': _quantity,
        'entryMode': _entryMode,
        'photoPath': _compressedFile?.path ?? _photoPath,
        'listingId': _listingId,
        'language': _language,
      },
    );
  }

  void _retakePhoto() {
    HapticFeedback.lightImpact();
    Navigator.pop(context);
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildPhotoPreview()),
            _buildInfoPanel(),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      title: const Text(
        'Review Photo',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
        tooltip: 'Go back',
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_cropEmoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                _cropType,
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

  Widget _buildPhotoPreview() {
    if (_originalFile == null) {
      return const Center(
        child: Text(
          'No photo available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Photo
        InteractiveViewer(
          minScale: 0.5,
          maxScale: 3.0,
          child: Image.file(
            _compressedFile ?? _originalFile!,
            fit: BoxFit.contain,
          ),
        ),

        // Quality guidance overlay (AC4)
        if (_showQualityGuidance && _qualityResult != null)
          _buildQualityGuidanceOverlay(),

        // Upload progress overlay (AC5)
        if (_isUploading) _buildUploadOverlay(),
      ],
    );
  }

  Widget _buildQualityGuidanceOverlay() {
    return GestureDetector(
      onTap: () => setState(() => _showQualityGuidance = false),
      child: Container(
        color: Colors.black.withValues(alpha: 0.85),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.errorContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 36,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Photo Quality Issue',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 16),
                ..._qualityResult!.issues.map((issue) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(
                        _getIssueIcon(issue.type),
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              issue.message,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.onErrorContainer,
                              ),
                            ),
                            Text(
                              issue.suggestion,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.onErrorContainer.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() => _showQualityGuidance = false);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.onErrorContainer,
                          side: BorderSide(color: AppColors.onErrorContainer),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Continue Anyway'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _retakePhoto,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Retake'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.error,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIssueIcon(QualityIssueType type) {
    switch (type) {
      case QualityIssueType.tooDark:
        return Icons.brightness_low;
      case QualityIssueType.tooBright:
        return Icons.brightness_high;
      case QualityIssueType.blurry:
        return Icons.blur_on;
      case QualityIssueType.noProduce:
        return Icons.do_not_disturb;
      case QualityIssueType.lowResolution:
        return Icons.photo_size_select_small;
    }
  }

  Widget _buildUploadOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular progress
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: _uploadProgress,
                        strokeWidth: 6,
                        backgroundColor: Colors.grey.shade700,
                        color: AppColors.secondary,
                      ),
                    ),
                    Text(
                      '${(_uploadProgress * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Uploading photo...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait',
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

  Widget _buildInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border(
          top: BorderSide(color: Colors.grey.shade800),
        ),
      ),
      child: Column(
        children: [
          // Compression status
          if (_isCompressing)
            _buildStatusRow(
              icon: Icons.compress,
              label: 'Compressing photo...',
              isLoading: true,
            )
          else if (_compressionComplete)
            _buildCompressionStats(),

          // Validation status
          if (_isValidating)
            _buildStatusRow(
              icon: Icons.verified,
              label: 'Validating quality...',
              isLoading: true,
            )
          else if (_qualityResult != null)
            _buildQualityIndicator(),
        ],
      ),
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required String label,
    bool isLoading = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (isLoading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.secondary,
              ),
            )
          else
            Icon(icon, color: AppColors.secondary, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCompressionStats() {
    final reduction = ((_originalSizeKb - _compressedSizeKb) / _originalSizeKb * 100).round();
    
    return FadeTransition(
      opacity: _progressAnimation,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.secondary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Photo optimized',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$_originalSizeKb KB → $_compressedSizeKb KB ($reduction% smaller) • $_imageWidth×$_imageHeight',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
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

  Widget _buildQualityIndicator() {
    final isValid = _qualityResult!.isValid;
    final score = (_qualityResult!.qualityScore * 100).round();
    
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isValid 
                  ? AppColors.secondary.withValues(alpha: 0.2)
                  : AppColors.error.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$score',
                style: TextStyle(
                  color: isValid ? AppColors.secondary : AppColors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isValid ? 'Good quality' : 'Quality issues detected',
                  style: TextStyle(
                    color: isValid ? AppColors.secondary : AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!isValid)
                  GestureDetector(
                    onTap: () => setState(() => _showQualityGuidance = true),
                    child: Text(
                      'Tap to see details',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Quality bar
          Container(
            width: 60,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.shade700,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              widthFactor: _qualityResult!.qualityScore,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: isValid ? AppColors.secondary : AppColors.error,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    final canUpload = _compressionComplete && 
                      !_isCompressing && 
                      !_isValidating && 
                      !_isUploading;
    
    return Container(
      padding: EdgeInsets.fromLTRB(
        24, 16, 24,
        MediaQuery.of(context).padding.bottom + 16,
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
      child: Row(
        children: [
          // Retake button
          Expanded(
            child: SizedBox(
              height: 56,
              child: OutlinedButton.icon(
                onPressed: _isUploading ? null : _retakePhoto,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  'Retake',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  disabledForegroundColor: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Upload button
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed: canUpload ? _uploadPhoto : null,
                icon: const Icon(Icons.cloud_upload),
                label: const Text(
                  'Upload Photo',
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
      ),
    );
  }
}
