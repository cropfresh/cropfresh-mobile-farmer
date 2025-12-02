import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'src/constants/app_colors.dart';
import 'src/screens/onboarding/splash_screen.dart';
import 'src/screens/auth/registration_screen.dart';

void main() {
  runApp(const CropFreshFarmerApp());
}

class CropFreshFarmerApp extends StatelessWidget {
  const CropFreshFarmerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CropFresh Farmer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Material Design 3 with brand colors
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF57C00), // Orange primary
          primary: const Color(0xFFF57C00), // Orange
          secondary: const Color(0xFF2E7D32), // Green
          surface: const Color(0xFFFFF8E1), // Warm Cream
        ),
        // Noto Sans for Indic language support
        textTheme: GoogleFonts.notoSansTextTheme(),
        fontFamily: GoogleFonts.notoSans().fontFamily,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/language-selection': (context) => const RegistrationScreen(), // Placeholder until language screen ready
        '/registration': (context) => const RegistrationScreen(),
      },
    );
  }
}
