import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../core/animations/animation_constants.dart';
import '../../services/auth_repository.dart';

/// Splash Screen - AC1 (Story 2.1) + AC5 (Story 2.2 Session Persistence)
/// Displays CropFresh logo with Material 3 spring animation
/// Shows tagline and Get Started button per UX spec
/// Checks for existing session and auto-navigates to dashboard
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _contentController;
  
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _taglineFade;
  late Animation<Offset> _taglineSlide;
  late Animation<double> _buttonsFade;
  late Animation<Offset> _buttonsSlide;
  
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkSessionAndStart();
  }

  /// Story 2.2 AC5: Check if user has valid session
  Future<void> _checkSessionAndStart() async {
    final authRepo = AuthRepository();
    final isLoggedIn = await authRepo.isLoggedIn();
    
    if (!mounted) return;
    
    if (isLoggedIn) {
      // User has valid session, skip onboarding and go to dashboard
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // No valid session, show splash screen and proceed with onboarding
      setState(() => _checkingSession = false);
      _startAnimations();
    }
  }

  void _setupAnimations() {
    // Logo animation controller (spring-based)
    _logoController = AnimationController(
      duration: AnimationConstants.durationSplash,
      vsync: this,
    );

    // Content animation controller (staggered)
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Logo scale with elastic/spring curve
    _logoScale = Tween<double>(
      begin: AnimationConstants.scaleLogoStart,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
    ));

    // Logo fade
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Tagline fade and slide (staggered after logo)
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
    ));

    // Buttons fade and slide (staggered after tagline)
    _buttonsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );
    _buttonsSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
    ));
  }

  void _startAnimations() {
    _logoController.forward();
    // Start content animation after logo animation begins
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _contentController.forward();
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onGetStarted() {
    Navigator.of(context).pushReplacementNamed('/language-selection');
  }

  void _onChangeLanguage() {
    Navigator.of(context).pushReplacementNamed('/language-selection');
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator during session check
    if (_checkingSession) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.spa_rounded,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              
              // Animated Logo
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoFade.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: child,
                    ),
                  );
                },
                child: _buildLogo(),
              ),
              
              const SizedBox(height: 24),
              
              // Animated Tagline
              SlideTransition(
                position: _taglineSlide,
                child: FadeTransition(
                  opacity: _taglineFade,
                  child: _buildTagline(),
                ),
              ),
              
              const Spacer(flex: 3),
              
              // Animated Buttons
              SlideTransition(
                position: _buttonsSlide,
                child: FadeTransition(
                  opacity: _buttonsFade,
                  child: _buildButtons(),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo placeholder with fallback
        Image.asset(
          'assets/logo/logo-full.png',
          width: 180,
          height: 180,
          errorBuilder: (context, error, stackTrace) {
            // Beautiful fallback if logo not yet added
            return Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.spa_rounded,
                size: 90,
                color: Colors.white,
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        // Brand name
        ShaderMask(
          shaderCallback: (bounds) => AppColors.heroGradient.createShader(bounds),
          child: const Text(
            'CropFresh',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagline() {
    return Column(
      children: [
        Text(
          'Sell your crops directly to buyers.',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Instant payments. No commission.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        // Primary CTA - Get Started
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: _onGetStarted,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              shadowColor: AppColors.primary.withValues(alpha: 0.3),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Language Selector Button
        TextButton(
          onPressed: _onChangeLanguage,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.onSurfaceVariant,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text(
            'Choose Language / ಭಾಷೆ ಆಯ್ಕೆ / भाषा चुनें / மொழி தேர்வு',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
