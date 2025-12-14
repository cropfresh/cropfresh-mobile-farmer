import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'src/constants/app_colors.dart';
import 'src/providers/listings_provider.dart';

// Onboarding Screens
import 'src/screens/onboarding/splash_screen.dart';
import 'src/screens/onboarding/language_selection_screen.dart';
import 'src/screens/onboarding/welcome_screen.dart';
import 'src/screens/onboarding/permissions_screen.dart';
import 'src/screens/onboarding/profile_setup_screen.dart';
import 'src/screens/onboarding/farm_profile_screen.dart';
import 'src/screens/onboarding/payment_setup_screen.dart';
import 'src/screens/onboarding/pin_setup_screen.dart';
import 'src/screens/onboarding/onboarding_complete_screen.dart';

// Auth Screens
import 'src/screens/auth/registration_screen.dart';
import 'src/screens/auth/otp_verification_screen.dart';
import 'src/screens/auth/profile_completion_screen.dart';
import 'src/screens/auth/login_screen.dart';

// Dashboard Screens
import 'src/screens/dashboard/dashboard_shell.dart';

// Listing Screens (Story 3.1)
import 'src/screens/listing/voice_listing_screen.dart';
import 'src/screens/listing/listing_confirmation_screen.dart';
import 'src/screens/listing/crop_selection_grid.dart';
import 'src/screens/listing/photo_capture_screen.dart';
import 'src/screens/listing/manual_listing_screen.dart';
import 'src/screens/listing/listing_review_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ListingsProvider(),
      child: const CropFreshFarmerApp(),
    ),
  );
}

class CropFreshFarmerApp extends StatelessWidget {
  const CropFreshFarmerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CropFresh Farmer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Material Design 3 (2025 Edition)
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
        ),
        // Noto Sans for Indic language support (Kannada, Hindi, Tamil, Telugu)
        textTheme: GoogleFonts.notoSansTextTheme(),
        fontFamily: GoogleFonts.notoSans().fontFamily,
        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        // Button themes
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Onboarding Flow (now 11 steps with Welcome screen split)
      // Flow: Splash → Language → Welcome → [Register] → Permissions → Phone → OTP → Profile → Farm → Payment → PIN → Success
      //                                   → [Login] → Story 2.2 (Passwordless OTP Login)
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/language-selection':
        return MaterialPageRoute(builder: (_) => const LanguageSelectionScreen());
      case '/welcome':
        // New Welcome Screen (AC3) - shows benefits + Register/Login buttons
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case '/permissions':
        // Permissions Screen (AC3a) - progressive permission requests only
        return MaterialPageRoute(builder: (_) => const PermissionsScreen());
      case '/registration':
        return MaterialPageRoute(builder: (_) => const RegistrationScreen());
      case '/otp-verification':
        // Handle both String (legacy) and Map (new) arguments
        final args = settings.arguments;
        String phoneNumber = '';
        bool isLoginFlow = false;
        
        if (args is String) {
          phoneNumber = args;
        } else if (args is Map<String, dynamic>) {
          phoneNumber = args['phoneNumber'] ?? '';
          isLoginFlow = args['isLoginFlow'] ?? false;
        }
        
        return MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            phoneNumber: phoneNumber,
            isLoginFlow: isLoginFlow,
          ),
        );
      case '/profile-setup':
        return MaterialPageRoute(builder: (_) => const ProfileSetupScreen());
      case '/farm-profile':
        return MaterialPageRoute(builder: (_) => const FarmProfileScreen());
      case '/payment-setup':
        return MaterialPageRoute(builder: (_) => const PaymentSetupScreen());
      case '/pin-setup':
        return MaterialPageRoute(builder: (_) => const PinSetupScreen());
      case '/onboarding-complete':
        return MaterialPageRoute(builder: (_) => const OnboardingCompleteScreen());
      
      // Login route for returning users (Story 2.2 - Passwordless OTP Login)
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      // Home/Dashboard - Farmer Dashboard with bottom navigation
      case '/home':
        return MaterialPageRoute(builder: (_) => const DashboardShell());
      
      // Story 3.1 - Voice Listing Flow
      case '/voice-listing':
        return MaterialPageRoute(builder: (_) => const VoiceListingScreen());
      case '/listing-confirmation':
        return MaterialPageRoute(builder: (_) => const ListingConfirmationScreen());
      case '/crop-selection':
        return MaterialPageRoute(builder: (_) => const CropSelectionGrid());
      case '/photo-capture':
        return MaterialPageRoute(builder: (_) => const PhotoCaptureScreen());
      
      // Manual Listing Flow
      case '/manual-listing':
        return MaterialPageRoute(builder: (_) => const ManualListingScreen());
      case '/listing-review':
        return MaterialPageRoute(builder: (_) => const ListingReviewScreen());
      
      // Legacy routes (for backward compatibility)
      case '/profile-completion':
        return MaterialPageRoute(builder: (_) => const ProfileCompletionScreen());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
        );
    }
  }
}
