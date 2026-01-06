import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../core/animations/animation_constants.dart';

/// Welcome Screen (Story 2.1 - AC3)
/// Shows 3 benefits and Register/Login buttons for new and returning users
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _benefitsController;
  late AnimationController _buttonController;
  
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _buttonFade;
  late Animation<Offset> _buttonSlide;

  final List<Map<String, dynamic>> _benefits = [
    {
      'icon': '🌾',
      'title': 'Sell crops directly from your farm',
      'description': 'No middlemen, better prices for you',
      'color': AppColors.secondary,
    },
    {
      'icon': '💳',
      'title': 'Get paid instantly to your bank / UPI',
      'description': 'Money in your account within 24 hours',
      'color': AppColors.primary,
    },
    {
      'icon': '🚛',
      'title': 'We arrange pickup and transport',
      'description': 'Free pickup from your village',
      'color': const Color(0xFF1976D2),
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
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

    // Benefits stagger animation
    _benefitsController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
    if (mounted) _benefitsController.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) _buttonController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _benefitsController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: IntrinsicHeight(
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
                        
                        // Animated Benefits
                        _buildBenefitsList(),
                        
                        const Spacer(),
                        
                        const SizedBox(height: 24),
                        
                        // Animated Buttons Section
                        SlideTransition(
                          position: _buttonSlide,
                          child: FadeTransition(
                            opacity: _buttonFade,
                            child: _buildButtonsSection(),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // CropFresh Logo placeholder
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Text(
              '🌾',
              style: TextStyle(fontSize: 40),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Welcome to CropFresh! 🌱',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Your crops, your price, instant payments',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBenefitsList() {
    return AnimatedBuilder(
      animation: _benefitsController,
      builder: (context, child) {
        return Column(
          children: List.generate(_benefits.length, (index) {
            final startTime = index * 0.2;
            final endTime = startTime + 0.5;
            
            final itemAnimation = Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(
                parent: _benefitsController,
                curve: Interval(
                  startTime.clamp(0, 1),
                  endTime.clamp(0, 1),
                  curve: AnimationConstants.curveEmphasized,
                ),
              ),
            );
            
            return Padding(
              padding: EdgeInsets.only(bottom: index < _benefits.length - 1 ? 16 : 0),
              child: FadeTransition(
                opacity: itemAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.2, 0),
                    end: Offset.zero,
                  ).animate(itemAnimation),
                  child: _buildBenefitCard(_benefits[index]),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildBenefitCard(Map<String, dynamic> benefit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: (benefit['color'] as Color).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                benefit['icon'],
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  benefit['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  benefit['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonsSection() {
    return Column(
      children: [
        // Register Button (Primary) - 56dp height per M3
        SizedBox(
          height: 56,
          child: FilledButton(
            onPressed: _onRegister,
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
                Icon(Icons.person_add_rounded, size: 22),
                SizedBox(width: 10),
                Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Login Button (Secondary/Outlined) - 48dp height per M3
        SizedBox(
          height: 48,
          child: OutlinedButton(
            onPressed: _onLogin,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.login_rounded, size: 20),
                SizedBox(width: 8),
                Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Helper text
        Text(
          'Already have an account? Tap Login',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _onRegister() {
    HapticFeedback.mediumImpact();
    // Navigate to Permissions screen (AC3a) for new users
    Navigator.pushNamed(context, '/permissions');
  }

  void _onLogin() {
    HapticFeedback.lightImpact();
    // Navigate to Story 2.2 - Passwordless OTP Login
    // For now, go to registration which handles both flows
    Navigator.pushNamed(context, '/login');
  }
}
