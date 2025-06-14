import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_app/colors.dart';
import 'package:rent_app/home_screen.dart';
import 'package:rent_app/onboarding_page.dart';
import 'package:rent_app/profile_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp( // jangan pakai const karena ThemeData tidak const
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: GoogleFonts.poppins().fontFamily,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const OnboardingPage( ), // pastikan HomeScreen ada dan diimpor
    );
  }
}
