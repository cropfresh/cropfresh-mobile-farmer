import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../core/animations/animation_constants.dart';
import '../../core/animations/micro_animations.dart';

/// Onboarding Complete Screen (Story 2.1 - AC9)
/// Success screen with animated checkmark and confetti effect
/// Personalized welcome message and CTA buttons
class OnboardingCompleteScreen extends StatefulWidget {
  const OnboardingCompleteScreen({super.key});

  @override
  State<OnboardingCompleteScreen> createState() => _OnboardingCompleteScreenState();
}

class _OnboardingCompleteScreenState extends State<OnboardingCompleteScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _contentController;
  late AnimationController _confettiController;
  
  late Animation<double> _checkScale;
  late Animation<double> _checkFade;
  late Animation<double> _ringScale;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;
  
  String _farmerName = 'Farmer';
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _loadFarmerName();
    _setupAnimations();
    _startAnimations();
  }

  void _loadFarmerName() {
    // TODO: Get from SharedPreferences or state management
    // For now, using placeholder
    _farmerName = 'Farmer';
  }

  void _setupAnimations() {
    // Checkmark animation (1.5s total)
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Ring scale animation (expands then contracts)
    _ringScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]).animate(_checkController);

    // Checkmark scale (bounces in)
    _checkScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.0),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 35,
      ),
    ]).animate(_checkController);

    _checkFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );

    // Content animation
    _contentController = AnimationController(
      duration: AnimationConstants.durationMedium,
      vsync: this,
    );

    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: AnimationConstants.curveEmphasized,
    ));

    // Confetti controller
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
  }

  void _startAnimations() async {
    // Haptic feedback and check animation
    HapticFeedback.heavyImpact();
    _checkController.forward();
    
    // Start confetti after ring animation
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _showConfetti = true);
      _confettiController.forward();
    }
    
    // Start content animation
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      HapticFeedback.mediumImpact();
      _contentController.forward();
    }
  }

  @override
  void dispose() {
    _checkController.dispose();
    _contentController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  
                  // Animated Success Icon
                  _buildSuccessIcon(),
                  
                  const SizedBox(height: 40),
                  
                  // Welcome Message
                  SlideTransition(
                    position: _contentSlide,
                    child: FadeTransition(
                      opacity: _contentFade,
                      child: _buildWelcomeMessage(),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Status Summary
                  SlideTransition(
                    position: _contentSlide,
                    child: FadeTransition(
                      opacity: _contentFade,
                      child: _buildStatusSummary(),
                    ),
                  ),
                  
                  const Spacer(flex: 3),
                  
                  // CTA Buttons
                  SlideTransition(
                    position: _contentSlide,
                    child: FadeTransition(
                      opacity: _contentFade,
                      child: _buildButtons(),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
            
            // Confetti overlay
            if (_showConfetti) _buildConfetti(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return AnimatedBuilder(
      animation: _checkController,
      builder: (context, child) {
        return SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring
              Transform.scale(
                scale: _ringScale.value,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.secondary.withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                ),
              ),
              // Inner filled circle
              Transform.scale(
                scale: _ringScale.value,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withOpacity(0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                ),
              ),
              // Animated checkmark
              Opacity(
                opacity: _checkFade.value,
                child: Transform.scale(
                  scale: _checkScale.value,
                  child: AnimatedCheckmark(
                    size: 56,
                    color: Colors.white,
                    show: _checkController.value > 0.3,
                    duration: const Duration(milliseconds: 600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeMessage() {
    return Column(
      children: [
        Text(
          'Welcome to CropFresh!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Hello $_farmerName! 🎉\nYou can now list your crops and get buyers directly.',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatusSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStatusRow(
            icon: '✅',
            iconColor: AppColors.secondary,
            text: 'Profile created',
          ),
          const Divider(height: 24),
          _buildStatusRow(
            icon: '🔐',
            iconColor: AppColors.primary,
            text: 'PIN secured',
          ),
          const Divider(height: 24),
          _buildStatusRow(
            icon: '🌾',
            iconColor: const Color(0xFF795548),
            text: 'Ready to sell crops',
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow({
    required String icon,
    required Color iconColor,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 20)),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
          ),
        ),
        const Spacer(),
        Icon(
          Icons.check_circle_rounded,
          color: AppColors.secondary,
          size: 22,
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        // Primary CTA
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: _onCreateListing,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.onSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              shadowColor: AppColors.secondary.withOpacity(0.3),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline_rounded, size: 22),
                SizedBox(width: 10),
                Text(
                  'Create My First Listing',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Secondary CTA
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: _onGoHome,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.onSurfaceVariant,
              side: BorderSide(color: AppColors.outlineVariant),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home_rounded, size: 22),
                SizedBox(width: 10),
                Text(
                  'Go to Home',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfetti() {
    return AnimatedBuilder(
      animation: _confettiController,
      builder: (context, child) {
        return IgnorePointer(
          child: CustomPaint(
            painter: _ConfettiPainter(
              progress: _confettiController.value,
            ),
            size: MediaQuery.of(context).size,
          ),
        );
      },
    );
  }

  void _onCreateListing() {
    HapticFeedback.mediumImpact();
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/create-listing',
      (route) => false,
    );
  }

  void _onGoHome() {
    HapticFeedback.lightImpact();
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
  }
}

/// Simple confetti painter for celebration effect
class _ConfettiPainter extends CustomPainter {
  final double progress;
  static final List<_Confetti> _confetti = _generateConfetti();

  _ConfettiPainter({required this.progress});

  static List<_Confetti> _generateConfetti() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(30, (i) {
      final seed = random + i * 1000;
      return _Confetti(
        x: (seed % 100) / 100,
        delay: (seed % 30) / 100,
        speed: 0.5 + (seed % 50) / 100,
        rotation: (seed % 360).toDouble(),
        color: [
          AppColors.primary,
          AppColors.secondary,
          const Color(0xFFFFD700),
          const Color(0xFFFF69B4),
        ][seed % 4],
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final confetti in _confetti) {
      final adjustedProgress = (progress - confetti.delay).clamp(0.0, 1.0);
      if (adjustedProgress <= 0) continue;

      final x = confetti.x * size.width;
      final y = adjustedProgress * size.height * confetti.speed * 1.5 - 50;
      
      if (y > size.height) continue;

      final opacity = (1 - adjustedProgress).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = confetti.color.withOpacity(opacity * 0.8);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(confetti.rotation + adjustedProgress * 5);
      canvas.drawRect(
        const Rect.fromLTWH(-4, -4, 8, 8),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      progress != oldDelegate.progress;
}

class _Confetti {
  final double x;
  final double delay;
  final double speed;
  final double rotation;
  final Color color;

  _Confetti({
    required this.x,
    required this.delay,
    required this.speed,
    required this.rotation,
    required this.color,
  });
}
