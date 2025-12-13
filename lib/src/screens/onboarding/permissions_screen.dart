import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../constants/app_colors.dart';
import '../../core/animations/animation_constants.dart';

/// Permissions Screen (Story 2.1 - AC3a)
/// Progressive permission requests: Phone, Notification, Location
/// Separate from Welcome Screen per updated story spec
class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with TickerProviderStateMixin {
  bool _phonePermissionGranted = false;
  bool _notificationPermissionGranted = false;
  bool _locationPermissionGranted = false;
  bool _locationSkipped = false;
  
  late AnimationController _headerController;
  late AnimationController _permissionsController;
  late AnimationController _buttonController;
  
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _buttonFade;
  late Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
    _checkExistingPermissions();
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

    // Permissions animation
    _permissionsController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Button animation
    _buttonController = AnimationController(
      duration: AnimationConstants.durationMedium,
      vsync: this,
    );
    _buttonFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
    );
    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: AnimationConstants.curveEmphasized,
    ));
  }

  void _startAnimations() async {
    _headerController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _permissionsController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) _buttonController.forward();
  }

  Future<void> _checkExistingPermissions() async {
    final phoneStatus = await Permission.phone.status;
    final notificationStatus = await Permission.notification.status;
    final locationStatus = await Permission.location.status;
    
    setState(() {
      _phonePermissionGranted = phoneStatus.isGranted;
      _notificationPermissionGranted = notificationStatus.isGranted;
      _locationPermissionGranted = locationStatus.isGranted;
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _permissionsController.dispose();
    _buttonController.dispose();
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
              const SizedBox(height: 24),
              
              // Animated Header
              SlideTransition(
                position: _headerSlide,
                child: FadeTransition(
                  opacity: _headerFade,
                  child: _buildHeader(),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Animated Permissions Section
              Expanded(
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _permissionsController,
                    curve: Curves.easeOut,
                  ),
                  child: _buildPermissionsSection(),
                ),
              ),
              
              // Animated Continue Button
              SlideTransition(
                position: _buttonSlide,
                child: FadeTransition(
                  opacity: _buttonFade,
                  child: _buildBottomSection(),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Permission icon
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            Icons.security_rounded,
            size: 36,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Enable Permissions',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'These help us give you a better experience',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPermissionsSection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phone Permission (Optional)
          _buildPermissionCard(
            icon: Icons.phone_android_rounded,
            iconColor: AppColors.primary,
            title: 'Phone (OTP auto-read)',
            subtitle: 'Optional • Makes login faster',
            isGranted: _phonePermissionGranted,
            onRequest: _requestPhonePermission,
            badge: 'Optional',
            badgeColor: AppColors.surfaceContainerHigh,
          ),
          
          const SizedBox(height: 16),
          
          // Notification Permission (Recommended)  
          _buildPermissionCard(
            icon: Icons.notifications_active_rounded,
            iconColor: AppColors.secondary,
            title: 'Notifications',
            subtitle: 'Recommended • Payment & pickup alerts',
            isGranted: _notificationPermissionGranted,
            onRequest: _requestNotificationPermission,
            badge: 'Recommended',
            badgeColor: AppColors.secondaryContainer,
          ),
          
          const SizedBox(height: 16),
          
          // Location Permission (Ask Later available)
          _buildPermissionCard(
            icon: Icons.location_on_rounded,
            iconColor: const Color(0xFF1976D2),
            title: 'Location',
            subtitle: 'For nearby drop points & logistics',
            isGranted: _locationPermissionGranted,
            isSkipped: _locationSkipped,
            onRequest: _requestLocationPermission,
            onSkip: _skipLocationPermission,
            badge: 'Ask Later available',
            badgeColor: AppColors.surfaceContainerHigh,
            showAskLater: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isGranted,
    required VoidCallback onRequest,
    required String badge,
    required Color badgeColor,
    bool isSkipped = false,
    VoidCallback? onSkip,
    bool showAskLater = false,
  }) {
    final bool isHandled = isGranted || isSkipped;
    
    return AnimatedContainer(
      duration: AnimationConstants.durationShort,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isGranted 
            ? AppColors.secondaryContainer.withOpacity(0.5)
            : isSkipped 
                ? AppColors.surfaceContainerHigh.withOpacity(0.5)
                : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGranted 
              ? AppColors.secondary 
              : isSkipped
                  ? AppColors.outline.withOpacity(0.5)
                  : AppColors.outlineVariant,
          width: isGranted ? 1.5 : 1,
        ),
        boxShadow: isHandled ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon
              AnimatedContainer(
                duration: AnimationConstants.durationShort,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isGranted
                      ? iconColor.withOpacity(0.2)
                      : iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isGranted ? iconColor : iconColor.withOpacity(0.8),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              
              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSkipped 
                            ? AppColors.onSurfaceVariant 
                            : AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Status indicator
              if (isGranted)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                )
              else if (isSkipped)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Skipped',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          
          // Badge
          if (!isHandled) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
          
          // Action buttons
          if (!isHandled) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: onRequest,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Allow',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                if (showAskLater && onSkip != null) ...[
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: onSkip,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.onSurfaceVariant,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text(
                      'Ask Later',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Column(
      children: [
        // Continue Button
        SizedBox(
          height: 56,
          child: FilledButton(
            onPressed: _onContinue,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              shadowColor: AppColors.primary.withOpacity(0.3),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Not now link for all non-critical permissions
        TextButton(
          onPressed: _onNotNow,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.onSurfaceVariant,
          ),
          child: const Text(
            'Not now',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _requestPhonePermission() async {
    HapticFeedback.lightImpact();
    final status = await Permission.phone.request();
    setState(() {
      _phonePermissionGranted = status.isGranted;
    });
    if (status.isGranted) {
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> _requestNotificationPermission() async {
    HapticFeedback.lightImpact();
    final status = await Permission.notification.request();
    setState(() {
      _notificationPermissionGranted = status.isGranted;
    });
    if (status.isGranted) {
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> _requestLocationPermission() async {
    HapticFeedback.lightImpact();
    final status = await Permission.location.request();
    setState(() {
      _locationPermissionGranted = status.isGranted;
      _locationSkipped = false;
    });
    if (status.isGranted) {
      HapticFeedback.mediumImpact();
    }
  }

  void _skipLocationPermission() {
    HapticFeedback.lightImpact();
    setState(() {
      _locationSkipped = true;
    });
  }

  void _onContinue() {
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(context, '/registration');
  }

  void _onNotNow() {
    HapticFeedback.lightImpact();
    // Skip all remaining permissions and continue
    Navigator.pushNamed(context, '/registration');
  }
}
