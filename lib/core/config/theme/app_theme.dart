import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  // Dark theme: 8-Bit Retro Space
  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.deepPurple,
      scaffoldBackgroundColor: const Color(0xFF050510), // Deep space black
      cardColor: const Color(0xFF1A1A2E), // Dark blue-grey

      // Define default font family to ensure it applies everywhere
      fontFamily: GoogleFonts.vt323().fontFamily,

      textTheme: TextTheme(
        bodyLarge: GoogleFonts.vt323(
          fontSize: 20, // Pixel fonts need to be slightly larger
          color: Colors.white,
        ),
        bodyMedium: GoogleFonts.vt323(
          fontSize: 18,
          color: Colors.white70,
        ),
        displayLarge: GoogleFonts.pressStart2p(
          fontSize: 24, // Chunky header
          color: Colors.cyanAccent,
          height: 1.5,
        ),
        headlineMedium: GoogleFonts.pressStart2p(
          fontSize: 16,
          color: Colors.white,
          height: 1.5,
        ),
        titleLarge: GoogleFonts.pressStart2p(
          fontSize: 14,
          color: Colors.yellowAccent,
        ),
      ),

      // Retro Button Styling
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const BeveledRectangleBorder(), // Angular borders
          textStyle:
              GoogleFonts.vt323(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),

      // Retro Card Styling
      cardTheme: const CardThemeData(
        shape: BeveledRectangleBorder(
          side: BorderSide(color: Colors.white24, width: 1),
        ),
        elevation: 0,
        color: Color(0xFF1A1A2E),
      ),

      iconTheme: const IconThemeData(
        color: Colors.white,
        size: 24,
      ),
    );
  }

  // Light theme: Cosmic light (kept for compatibility but updated fonts)
  static ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: AppColors.lightBackground,
      cardColor: AppColors.lightSurface,
      fontFamily: GoogleFonts.vt323().fontFamily,
      textTheme: TextTheme(
        bodyLarge: GoogleFonts.vt323(
          fontSize: 20,
          color: Colors.black87,
        ),
        bodyMedium: GoogleFonts.vt323(
          fontSize: 18,
          color: Colors.black54,
        ),
        displayLarge: GoogleFonts.pressStart2p(
          fontSize: 24,
          color: const Color(0xFF1976D2),
        ),
        headlineMedium: GoogleFonts.pressStart2p(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          shape: const BeveledRectangleBorder(),
          textStyle:
              GoogleFonts.vt323(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
