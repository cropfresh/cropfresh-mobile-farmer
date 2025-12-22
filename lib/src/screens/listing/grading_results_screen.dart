import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_typography.dart';
import '../../models/grading_models.dart';
import '../../widgets/grading_widgets.dart';

/// GradingResultsScreen - Story 3.3 (AC: 1, 2, 3, 4, 5, 6, 7)
/// 
/// Premium AI grading results experience with:
/// - Large quality badge: Grade A/B/C with color coding (AC1)
/// - Confidence score with percentage indicator (AC1)
/// - Quality indicators: freshness, color, size, surface (AC2)
/// - DPLE price breakdown with animations (AC3, AC4)
/// - Accept/Reject actions with voice feedback (AC5, AC6)
/// - Grade explanation in expandable section (AC7)
/// 
/// Material Design 3 with 60fps animations
class GradingResultsScreen extends StatefulWidget {
  const GradingResultsScreen({super.key});

  @override
  State<GradingResultsScreen> createState() => _GradingResultsScreenState();
}

class _GradingResultsScreenState extends State<GradingResultsScreen>
    with TickerProviderStateMixin {
  // Route arguments
  String _cropType = '';
  String _cropEmoji = '🌾';
  double _quantity = 0.0;
  String _photoPath = '';
  int? _listingId;
  String _language = 'en';

  // Grading state
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  GradingResult? _gradingResult;
  PriceBreakdown? _priceBreakdown;

  // UI state
  bool _showRejectOptions = false;
  bool _isConfirming = false;
  bool _showExplanation = false;

  // Animation controllers
  late AnimationController _loadingController;
  late AnimationController _revealController;
  late AnimationController _priceController;
  late Animation<double> _gradeScaleAnimation;
  late Animation<double> _indicatorSlideAnimation;
  late Animation<double> _priceRevealAnimation;

  // TTS
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initTts();
  }

  void _initAnimations() {
    // Loading shimmer
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Content reveal
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _gradeScaleAnimation = CurvedAnimation(
      parent: _revealController,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    );
    
    _indicatorSlideAnimation = CurvedAnimation(
      parent: _revealController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
    );

    // Price reveal
    _priceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _priceRevealAnimation = CurvedAnimation(
      parent: _priceController,
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _initTts() async {
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadArguments();
  }

  void _loadArguments() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && _cropType.isEmpty) {
      setState(() {
        _cropType = args['cropType'] ?? '';
        _cropEmoji = args['cropEmoji'] ?? '🌾';
        _quantity = (args['quantity'] ?? 0.0).toDouble();
        _photoPath = args['photoPath'] ?? '';
        _listingId = args['listingId'];
        _language = args['language'] ?? 'en';
      });
      
      _startGrading();
    }
  }

  Future<void> _startGrading() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Simulate AI grading (Phase 2 will call actual API)
      await Future.delayed(const Duration(milliseconds: 2500));
      
      // Mock grading result (Phase 2: Replace with API call)
      final gradingResult = GradingResult.mock(grade: QualityGrade.A);
      final priceBreakdown = PriceBreakdown.mock(
        grade: gradingResult.grade,
        quantityKg: _quantity,
        marketRate: 30.0,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _gradingResult = gradingResult;
          _priceBreakdown = priceBreakdown;
        });

        // Start reveal animations
        _revealController.forward();
        await Future.delayed(const Duration(milliseconds: 400));
        _priceController.forward();

        // Voice announcement (AC1)
        _announceGrade();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Failed to analyze photo. Please try again.';
        });
      }
    }
  }

  Future<void> _announceGrade() async {
    if (_gradingResult == null) return;

    final grade = _gradingResult!.grade.label;
    final confidence = (_gradingResult!.confidence * 100).round();
    
    String message;
    switch (_language) {
      case 'kn':
        message = 'ನಿಮ್ಮ $_cropType $grade, $confidence ಪ್ರತಿಶತ ವಿಶ್ವಾಸ';
        break;
      case 'hi':
        message = 'आपके $_cropType $grade हैं, $confidence प्रतिशत विश्वास';
        break;
      default:
        message = 'Your $_cropType are $grade, $confidence percent confident';
    }
    
    await _tts.speak(message);
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _revealController.dispose();
    _priceController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      appBar: _buildAppBar(isDark),
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingState(isDark)
            : _hasError
                ? _buildErrorState(isDark)
                : _buildResultsContent(isDark),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
        ),
        onPressed: () => Navigator.pop(context),
        tooltip: 'Go back',
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_cropEmoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            'AI Quality Check',
            style: AppTypography.titleMedium.copyWith(
              color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
            ),
          ),
        ],
      ),
      actions: [
        if (!_isLoading && _gradingResult != null)
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: isDark ? AppColors.darkOnSurface : AppColors.onSurfaceVariant,
            ),
            onPressed: () => setState(() => _showExplanation = !_showExplanation),
            tooltip: 'About grading',
          ),
      ],
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Photo thumbnail
          if (_photoPath.isNotEmpty)
            Container(
              width: 120,
              height: 120,
              margin: const EdgeInsets.only(bottom: AppSpacing.xl),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.file(
                File(_photoPath),
                fit: BoxFit.cover,
              ),
            ),
          
          // Scanning animation
          AnimatedBuilder(
            animation: _loadingController,
            builder: (context, child) {
              return Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    startAngle: 0,
                    endAngle: 3.14 * 2,
                    transform: GradientRotation(_loadingController.value * 3.14 * 2),
                    colors: [
                      AppColors.primary.withValues(alpha: 0.0),
                      AppColors.primary,
                      AppColors.secondary,
                      AppColors.secondary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? AppColors.darkSurface : AppColors.surface,
                  ),
                  child: Icon(
                    Icons.psychology,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          Text(
            'Analyzing your produce...',
            style: AppTypography.titleMedium.copyWith(
              color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
            ),
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          Text(
            'AI is checking quality, freshness & size',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
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
                Icons.error_outline,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Analysis Failed',
              style: AppTypography.headlineSmall.copyWith(
                color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: _startGrading,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(200, AppSpacing.recommendedTouchTarget),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsContent(bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Grade badge section
          _buildGradeBadgeSection(isDark),
          
          // Quality indicators
          _buildQualityIndicators(isDark),
          
          // Grade explanation (expandable)
          if (_showExplanation)
            _buildGradeExplanation(isDark),
          
          // Price breakdown
          _buildPriceBreakdown(isDark),
          
          // Bottom actions
          _buildBottomActions(isDark),
          
          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildGradeBadgeSection(bool isDark) {
    if (_gradingResult == null) return const SizedBox.shrink();
    
    return ScaleTransition(
      scale: _gradeScaleAnimation,
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.lg),
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getGradeColor(_gradingResult!.grade).withValues(alpha: 0.15),
              _getGradeColor(_gradingResult!.grade).withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _getGradeColor(_gradingResult!.grade).withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            // Photo thumbnail
            if (_photoPath.isNotEmpty)
              Container(
                width: 80,
                height: 80,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getGradeColor(_gradingResult!.grade),
                    width: 3,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.file(
                  File(_photoPath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.image,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            
            // Grade badge
            GradeBadge(
              grade: _gradingResult!.grade,
              size: 120,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Confidence
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified,
                    size: 16,
                    color: _getGradeColor(_gradingResult!.grade),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${(_gradingResult!.confidence * 100).round()}% confident',
                    style: AppTypography.labelLarge.copyWith(
                      color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.sm),
            
            Text(
              _gradingResult!.grade.description,
              style: AppTypography.titleMedium.copyWith(
                color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityIndicators(bool isDark) {
    if (_gradingResult == null) return const SizedBox.shrink();
    
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(_indicatorSlideAnimation),
      child: FadeTransition(
        opacity: _indicatorSlideAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceContainer : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.sm,
                  bottom: AppSpacing.sm,
                ),
                child: Text(
                  'Quality Analysis',
                  style: AppTypography.titleSmall.copyWith(
                    color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                  ),
                ),
              ),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _gradingResult!.indicators.map((indicator) {
                  return QualityIndicatorChip(
                    indicator: indicator,
                    isDark: isDark,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradeExplanation(bool isDark) {
    if (_gradingResult == null) return const SizedBox.shrink();
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.darkSurfaceContainerHigh 
            : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkOutline : AppColors.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getGradeColor(_gradingResult!.grade).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lightbulb_outline,
              color: _getGradeColor(_gradingResult!.grade),
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_gradingResult!.grade.label} Means',
                  style: AppTypography.labelLarge.copyWith(
                    color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _gradingResult!.explanation,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(bool isDark) {
    if (_priceBreakdown == null) return const SizedBox.shrink();
    
    return FadeTransition(
      opacity: _priceRevealAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(_priceRevealAnimation),
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.lg),
          child: PriceBreakdownCard(
            priceBreakdown: _priceBreakdown!,
            cropType: _cropType,
            grade: _gradingResult!.grade,
            isDark: isDark,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions(bool isDark) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _showRejectOptions
          ? _buildRejectOptions(isDark)
          : _buildMainActions(isDark),
    );
  }

  Widget _buildMainActions(bool isDark) {
    return Container(
      key: const ValueKey('main-actions'),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          // Accept button
          SizedBox(
            width: double.infinity,
            height: AppSpacing.recommendedTouchTarget,
            child: FilledButton(
              onPressed: _isConfirming ? null : _acceptListing,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isConfirming
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle),
                        const SizedBox(width: 8),
                        Text(
                          'Accept Price',
                          style: AppTypography.labelLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          // Not happy link
          TextButton(
            onPressed: () => setState(() => _showRejectOptions = true),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            ),
            child: Text(
              'Not happy with the offer?',
              style: AppTypography.labelLarge.copyWith(
                color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectOptions(bool isDark) {
    return Container(
      key: const ValueKey('reject-options'),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Other Options',
                style: AppTypography.titleSmall.copyWith(
                  color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                ),
                onPressed: () => setState(() => _showRejectOptions = false),
                constraints: const BoxConstraints(
                  minWidth: AppSpacing.minTouchTarget,
                  minHeight: AppSpacing.minTouchTarget,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          // Retake photo
          _buildRejectOptionButton(
            icon: Icons.camera_alt,
            title: 'Retake Photo',
            subtitle: 'Better lighting might improve grade',
            onTap: _retakePhoto,
            isDark: isDark,
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          // List anyway
          _buildRejectOptionButton(
            icon: Icons.check,
            title: 'List Anyway',
            subtitle: 'Proceed with current grade',
            onTap: _listAnyway,
            isDark: isDark,
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          // Cancel
          _buildRejectOptionButton(
            icon: Icons.cancel_outlined,
            title: 'Cancel Listing',
            subtitle: 'Discard this listing',
            onTap: _cancelListing,
            isDark: isDark,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRejectOptionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
    bool isDestructive = false,
  }) {
    final color = isDestructive 
        ? AppColors.error 
        : (isDark ? AppColors.darkOnSurface : AppColors.onSurface);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDestructive 
                  ? AppColors.error.withValues(alpha: 0.3)
                  : (isDark ? AppColors.darkOutline : AppColors.outlineVariant),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDestructive
                      ? AppColors.error.withValues(alpha: 0.1)
                      : (isDark 
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.05)),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.labelLarge.copyWith(color: color),
                    ),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark 
                            ? AppColors.darkOnSurfaceVariant 
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getGradeColor(QualityGrade grade) {
    switch (grade) {
      case QualityGrade.A:
        return AppColors.secondary; // Green
      case QualityGrade.B:
        return const Color(0xFFFFC107); // Yellow/Amber
      case QualityGrade.C:
        return AppColors.primary; // Orange
    }
  }

  // Actions
  Future<void> _acceptListing() async {
    setState(() => _isConfirming = true);
    HapticFeedback.heavyImpact();

    try {
      // Simulate API call (Phase 2 will call actual API)
      await Future.delayed(const Duration(seconds: 1));
      
      // Voice confirmation (AC5)
      String message;
      switch (_language) {
        case 'kn':
          message = 'ಪಟ್ಟಿ ದೃಢೀಕರಿಸಲಾಗಿದೆ!';
          break;
        case 'hi':
          message = 'लिस्टिंग की पुष्टि हो गई!';
          break;
        default:
          message = 'Listing confirmed!';
      }
      await _tts.speak(message);
      
      if (mounted) {
        // Navigate to drop point assignment (Story 3.4)
        Navigator.pushReplacementNamed(
          context,
          '/drop-point', // Placeholder - Story 3.4 will implement this
          arguments: {
            'listingId': _listingId,
            'cropType': _cropType,
            'cropEmoji': _cropEmoji,
            'quantity': _quantity,
            'grade': _gradingResult?.grade.name,
            'price': _priceBreakdown?.finalPricePerKg,
            'totalEarnings': _priceBreakdown?.totalEarnings,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isConfirming = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to confirm listing: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _retakePhoto() {
    HapticFeedback.lightImpact();
    // Navigate back to camera
    Navigator.popUntil(context, (route) => route.settings.name == '/photo-capture');
  }

  void _listAnyway() {
    HapticFeedback.lightImpact();
    setState(() => _showRejectOptions = false);
    _acceptListing();
  }

  Future<void> _cancelListing() async {
    HapticFeedback.mediumImpact();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Listing?'),
        content: const Text('This will discard your listing. You can create a new one anytime.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Cancel Listing'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && mounted) {
      Navigator.popUntil(context, (route) => route.settings.name == '/home');
    }
  }
}
