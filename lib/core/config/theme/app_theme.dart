import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Dark theme: Cosmic tech với màu đen, tím, lam (phù hợp chủ đề vũ trụ tối)
  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.deepPurple,
      scaffoldBackgroundColor: const Color(0xFF121212), // Nền đen sâu
      cardColor: const Color(0xFF1E1E1E), // Card tối
      textTheme: TextTheme(
        bodyLarge: GoogleFonts.inter(  // Thay bodyText1
          fontSize: 16,
          color: Colors.white,
        ),
        bodyMedium: GoogleFonts.inter(  // Thay bodyText2
          fontSize: 14,
          color: Colors.white70,
        ),
        displayLarge: GoogleFonts.orbitron(  // Thay headline1
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.cyanAccent, // Accent xanh lam sáng
        ),
        headlineMedium: GoogleFonts.orbitron(  // Thay headline6
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.deepPurple, // Nút tím
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  // Light theme: Cosmic light với nền sáng, accent tím/lam (vẫn giữ vibe vũ trụ nhưng sáng hơn)
  static ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue, // Accent xanh lam thay vì tím để sáng hơn
      scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Nền xám nhạt (cosmic light)
      cardColor: Colors.white,
      textTheme: TextTheme(
        bodyLarge: GoogleFonts.inter(  // Thay bodyText1
          fontSize: 16,
          color: Colors.black87,
        ),
        bodyMedium: GoogleFonts.inter(  // Thay bodyText2
          fontSize: 14,
          color: Colors.black54,
        ),
        displayLarge: GoogleFonts.orbitron(  // Thay headline1
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1976D2), // Xanh lam đậm (cosmic accent)
        ),
        headlineMedium: GoogleFonts.orbitron(  // Thay headline6
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Color(0xFF1976D2), // Nút xanh lam
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}