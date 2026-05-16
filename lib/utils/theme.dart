import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FezTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFF006A6A),
    brightness: Brightness.light,
    textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white.withOpacity(0.6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    scaffoldBackgroundColor: const Color(0xFFF0F4F8),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFF006A6A),
    brightness: Brightness.dark,
    textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(ThemeData.dark().textTheme),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.black.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
  );
}