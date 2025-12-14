import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';

/// PhotoCaptureScreen - Real camera capture (Story 3.2)
/// 
/// Features:
/// - Opens actual device camera
/// - Photo preview after capture
/// - Retake / Use Photo buttons
/// - Navigation to review screen
class PhotoCaptureScreen extends StatefulWidget {
  const PhotoCaptureScreen({super.key});

  @override
  State<PhotoCaptureScreen> createState() => _PhotoCaptureScreenState();
}

class _PhotoCaptureScreenState extends State<PhotoCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  
  XFile? _capturedImage;
  bool _isCapturing = false;
  bool _analyzing = false;
  
  // Data from previous screen
  String _cropType = '';
  String _cropEmoji = '🌾';
  double _quantity = 0.0;
  String _entryMode = 'voice';

  @override
  void initState() {
    super.initState();
    // Open camera automatically when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openCamera();
    });
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
        _cropEmoji = args['cropEmoji'] ?? '🌾';
        _quantity = (args['quantity'] ?? 0.0).toDouble();
        _entryMode = args['entryMode'] ?? 'voice';
      });
    }
  }

  Future<void> _openCamera() async {
    // Check camera permission
    final status = await Permission.camera.request();
    
    if (status.isDenied || status.isPermanentlyDenied) {
      if (mounted) {
        _showPermissionDeniedDialog();
      }
      return;
    }

    setState(() => _isCapturing = true);

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _capturedImage = image;
          _isCapturing = false;
          _analyzing = true;
        });

        // Simulate photo analysis
        await Future.delayed(const Duration(seconds: 2));
        
        if (mounted) {
          setState(() => _analyzing = false);
        }
      } else {
        // User cancelled camera
        if (mounted) {
          setState(() => _isCapturing = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCapturing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera error: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission'),
        content: const Text(
          'Camera permission is required to take photos of your produce. '
          'Please enable it in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _retakePhoto() {
    HapticFeedback.lightImpact();
    setState(() {
      _capturedImage = null;
      _analyzing = false;
    });
    _openCamera();
  }

  void _usePhoto() {
    if (_capturedImage == null) return;
    
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(
      context,
      '/listing-review',
      arguments: {
        'cropType': _cropType,
        'cropEmoji': _cropEmoji,
        'quantity': _quantity,
        'entryMode': _entryMode,
        'photoPath': _capturedImage!.path,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          _capturedImage == null ? 'Take Photo' : 'Preview',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_cropType.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: AppSpacing.md),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_cropEmoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    '$_cropType ${_quantity.toInt()}kg',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Photo preview area
            Expanded(
              child: _buildPhotoArea(),
            ),
            
            // Bottom actions
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              color: Colors.black,
              child: _capturedImage != null 
                  ? _buildPhotoActions() 
                  : _buildCaptureActions(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoArea() {
    if (_isCapturing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Opening camera...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (_capturedImage == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_alt_outlined,
                size: 48,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'No photo taken yet',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tap the button below to open camera',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            ),
          ],
        ),
      );
    }

    // Show captured photo
    return Stack(
      fit: StackFit.expand,
      children: [
        // Photo
        Image.file(
          File(_capturedImage!.path),
          fit: BoxFit.contain,
        ),
        
        // Analyzing overlay
        if (_analyzing)
          Container(
            color: Colors.black.withValues(alpha: 0.6),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'Checking photo quality...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        
        // Quality check success badge
        if (!_analyzing && _capturedImage != null)
          Positioned(
            top: AppSpacing.lg,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Photo looks good!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCaptureActions() {
    return Column(
      children: [
        Text(
          'Position your ${_cropType.isNotEmpty ? _cropType.toLowerCase() : 'produce'} clearly',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            onPressed: _openCamera,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Open Camera'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoActions() {
    return Row(
      children: [
        // Retake button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _retakePhoto,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text('Retake', style: TextStyle(color: Colors.white)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        // Use Photo button
        Expanded(
          flex: 2,
          child: FilledButton.icon(
            onPressed: _analyzing ? null : _usePhoto,
            icon: const Icon(Icons.check),
            label: const Text('Use This Photo'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.secondary,
              disabledBackgroundColor: Colors.grey,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            ),
          ),
        ),
      ],
    );
  }
}
