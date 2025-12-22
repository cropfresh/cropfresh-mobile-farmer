import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_typography.dart';
import '../../models/droppoint_models.dart';
import '../../widgets/droppoint_widgets.dart';

/// DropPointAssignmentScreen - Story 3.4 (AC: 1, 3, 4, 5, 7)
/// 
/// Premium drop point assignment experience with:
/// - Large location card: Name, address, distance (AC1)
/// - Static map preview with marker (AC3)
/// - Pickup time window display (AC1)
/// - Crates needed indicator (AC1)
/// - Google Maps directions button (AC3)
/// - Voice announcement of assignment (AC4)
/// - Success animation and confirmation (AC7)
/// 
/// Material Design 3 with 60fps animations, smooth transitions
class DropPointAssignmentScreen extends StatefulWidget {
  const DropPointAssignmentScreen({super.key});

  @override
  State<DropPointAssignmentScreen> createState() => _DropPointAssignmentScreenState();
}

class _DropPointAssignmentScreenState extends State<DropPointAssignmentScreen>
    with TickerProviderStateMixin {
  
  // Route arguments from grading screen
  int? _listingId;
  String _cropType = '';
  String _cropEmoji = '🌾';
  double _quantity = 0.0;
  String? _grade;
  double? _pricePerKg;
  double? _totalEarnings;
  String _language = 'en';

  // Assignment state
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  DropPointAssignment? _assignment;

  // Animation controllers
  late AnimationController _loadingController;
  late AnimationController _revealController;
  late AnimationController _successController;
  late Animation<double> _cardScaleAnimation;
  late Animation<double> _mapSlideAnimation;
  late Animation<double> _actionsSlideAnimation;

  // TTS
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initTts();
  }

  void _initAnimations() {
    // Loading animation
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Content reveal
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _cardScaleAnimation = CurvedAnimation(
      parent: _revealController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
    );

    _mapSlideAnimation = CurvedAnimation(
      parent: _revealController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
    );

    _actionsSlideAnimation = CurvedAnimation(
      parent: _revealController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
    );

    // Success pulse
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
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
    if (args != null && _listingId == null) {
      setState(() {
        _listingId = args['listingId'] as int?;
        _cropType = args['cropType'] as String? ?? '';
        _cropEmoji = args['cropEmoji'] as String? ?? '🌾';
        _quantity = (args['quantity'] ?? 0.0).toDouble();
        _grade = args['grade'] as String?;
        _pricePerKg = (args['price'] as num?)?.toDouble();
        _totalEarnings = (args['totalEarnings'] as num?)?.toDouble();
        _language = args['language'] as String? ?? 'en';
      });

      _fetchAssignment();
    }
  }

  Future<void> _fetchAssignment() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Simulate API call (Phase 2 will call actual Gateway API)
      await Future.delayed(const Duration(milliseconds: 1500));

      // Mock assignment result
      final assignment = DropPointAssignment.mock(
        listingId: _listingId,
        quantityKg: _quantity,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _assignment = assignment;
        });

        // Start reveal animations
        _revealController.forward();
        
        // Haptic feedback
        HapticFeedback.mediumImpact();
        
        // Voice announcement (AC4)
        await Future.delayed(const Duration(milliseconds: 400));
        _announceAssignment();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Failed to assign drop point. Please try again.';
        });
      }
    }
  }

  Future<void> _announceAssignment() async {
    if (_assignment == null) return;

    final dropPoint = _assignment!.dropPoint.name;
    final date = _assignment!.pickupWindow.formattedDate;
    final time = _assignment!.pickupWindow.formattedWindow;

    String message;
    switch (_language) {
      case 'kn':
        message = 'ಡ್ರಾಪ್ ಪಾಯಿಂಟ್ ನಿಯೋಜಿಸಲಾಗಿದೆ. $dropPoint ಗೆ $date, $time ಗೆ ತಲುಪಿಸಿ';
        break;
      case 'hi':
        message = 'ड्रॉप पॉइंट निर्धारित। $date, $time पर $dropPoint पहुंचें';
        break;
      case 'ta':
        message = 'டிராப் பாயிண்ட் ஒதுக்கப்பட்டது. $date, $time க்கு $dropPoint';
        break;
      case 'te':
        message = 'డ్రాప్ పాయింట్ కేటాయించబడింది. $date, $time న $dropPoint';
        break;
      default:
        message = 'Drop point assigned. Deliver to $dropPoint on $date, $time';
    }

    await _tts.speak(message);
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _revealController.dispose();
    _successController.dispose();
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
                : _buildAssignmentContent(isDark),
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
            'Drop Point',
            style: AppTypography.titleMedium.copyWith(
              color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
            ),
          ),
        ],
      ),
      actions: [
        // Voice button to repeat announcement
        if (!_isLoading && _assignment != null)
          IconButton(
            icon: Icon(
              Icons.volume_up,
              color: isDark ? AppColors.darkOnSurface : AppColors.onSurfaceVariant,
            ),
            onPressed: _announceAssignment,
            tooltip: 'Read aloud',
          ),
      ],
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pulsing location icon
          AnimatedBuilder(
            animation: _loadingController,
            builder: (context, child) {
              final scale = 1.0 + (_loadingController.value * 0.1);
              final opacity = 0.5 + (_loadingController.value * 0.5);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: opacity),
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    Icons.location_searching,
                    color: AppColors.secondary,
                    size: 36,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: AppSpacing.xl),

          Text(
            'Finding nearest drop point...',
            style: AppTypography.titleMedium.copyWith(
              color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            'Checking capacity and crate availability',
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
                Icons.location_off,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Assignment Failed',
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
              onPressed: _fetchAssignment,
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

  Widget _buildAssignmentContent(bool isDark) {
    if (_assignment == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success header
          _buildSuccessHeader(isDark),

          const SizedBox(height: AppSpacing.lg),

          // Countdown timer
          Center(
            child: CountdownTimerWidget(
              pickupWindow: _assignment!.pickupWindow,
              isDark: isDark,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Drop point card
          ScaleTransition(
            scale: _cardScaleAnimation,
            child: DropPointCard(
              dropPoint: _assignment!.dropPoint,
              pickupWindow: _assignment!.pickupWindow,
              cratesNeeded: _assignment!.cratesNeeded,
              quantityKg: _quantity,
              onGetDirections: _openDirections,
              isDark: isDark,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Map preview
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(_mapSlideAnimation),
            child: FadeTransition(
              opacity: _mapSlideAnimation,
              child: _buildMapPreview(isDark),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Crate indicator
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(_actionsSlideAnimation),
            child: FadeTransition(
              opacity: _actionsSlideAnimation,
              child: CrateIndicator(
                cratesNeeded: _assignment!.cratesNeeded,
                quantityKg: _quantity,
                isDark: isDark,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // What's next section
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(_actionsSlideAnimation),
            child: FadeTransition(
              opacity: _actionsSlideAnimation,
              child: _buildWhatsNext(isDark),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Done button
          _buildDoneButton(isDark),

          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildSuccessHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withValues(alpha: 0.15),
            AppColors.secondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Drop Point Assigned!',
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Your ${_quantity.toStringAsFixed(0)}kg $_cropType listing is ready',
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

  Widget _buildMapPreview(bool isDark) {
    // Static map placeholder (AC3)
    // In production, use Google Static Maps API or flutter_map
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceContainer : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkOutlineVariant : AppColors.outlineVariant,
        ),
      ),
      child: Stack(
        children: [
          // Map placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.secondary.withValues(alpha: 0.1),
                    AppColors.secondary.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map,
                      size: 48,
                      color: AppColors.secondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Map Preview',
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Location pin overlay
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Icon(
              Icons.location_on,
              size: 48,
              color: AppColors.secondary,
            ),
          ),

          // Tap to open maps
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _openDirections,
                borderRadius: BorderRadius.circular(16),
                child: const SizedBox.expand(),
              ),
            ),
          ),

          // "Tap to open" label
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.touch_app,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Tap to open in Maps',
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsNext(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What happens next?',
            style: AppTypography.titleSmall.copyWith(
              color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildStep(
            number: '1',
            title: 'Prepare your produce',
            subtitle: 'Pack in crates provided or your own containers',
            isDark: isDark,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildStep(
            number: '2',
            title: 'Visit drop point on time',
            subtitle: 'Arrive during your pickup window',
            isDark: isDark,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildStep(
            number: '3',
            title: 'Get paid instantly',
            subtitle: 'Payment sent to your UPI after verification',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDoneButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.recommendedTouchTarget,
      child: FilledButton(
        onPressed: _goToDashboard,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home),
            const SizedBox(width: 8),
            Text(
              'Done - Go to Dashboard',
              style: AppTypography.labelLarge.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Actions
  Future<void> _openDirections() async {
    if (_assignment == null) return;

    HapticFeedback.lightImpact();

    final lat = _assignment!.dropPoint.location.latitude;
    final lng = _assignment!.dropPoint.location.longitude;
    final name = Uri.encodeComponent(_assignment!.dropPoint.name);

    // Try Google Maps first, then Apple Maps
    final googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=$name';
    final appleMapsUrl = 'https://maps.apple.com/?daddr=$lat,$lng&dirflg=d';

    try {
      final googleUri = Uri.parse(googleMapsUrl);
      if (await canLaunchUrl(googleUri)) {
        await launchUrl(googleUri, mode: LaunchMode.externalApplication);
        return;
      }

      final appleUri = Uri.parse(appleMapsUrl);
      if (await canLaunchUrl(appleUri)) {
        await launchUrl(appleUri, mode: LaunchMode.externalApplication);
        return;
      }

      // Fallback: show snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open maps app')),
        );
      }
    } catch (e) {
      debugPrint('Error opening maps: $e');
    }
  }

  void _goToDashboard() {
    HapticFeedback.mediumImpact();

    // Navigate to dashboard, clearing the listing flow stack
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
      arguments: {
        'showDeliveryReminder': true,
        'listingId': _listingId,
      },
    );
  }
}
