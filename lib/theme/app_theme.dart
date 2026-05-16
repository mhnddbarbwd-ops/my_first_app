import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // الألوان الأساسية التي تتغير بناءً على حالة المستخدم
  static const Color calmColor = Color(0xFF006A6A);
  static const Color motivationalColor = Color(0xFFFF7043);

  // وضع النهار الزجاجي (Glass-Neumorphism)
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: calmColor,
    scaffoldBackgroundColor: const Color(0xFFF0F4F8),
    textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(),
    cardTheme: CardThemeData(
      color: Colors.white.withOpacity(0.6),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      shadowColor: Colors.black.withOpacity(0.1),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white.withOpacity(0.7),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.ibmPlexSansArabic(
        fontWeight: FontWeight.w900,
        fontSize: 20,
        color: Colors.black87,
      ),
    ),
  );

  // وضع الـ True Black (لشاشات OLED) مع عناصر زجاجية داكنة
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: calmColor,
    scaffoldBackgroundColor: const Color(0xFF000000), // True Black
    textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(ThemeData.dark().textTheme),
    cardTheme: CardThemeData(
      color: Colors.white.withOpacity(0.05),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      shadowColor: Colors.transparent,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white.withOpacity(0.03),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.ibmPlexSansArabic(
        fontWeight: FontWeight.w900,
        fontSize: 20,
        color: Colors.white,
      ),
    ),
  );
}