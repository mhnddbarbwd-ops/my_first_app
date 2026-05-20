import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hijri_date/hijri_date.dart';
import 'package:nafahat/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar', null);
  HijriDate.setLocal('ar');
  runApp(const NafahatApp());
}

class NafahatApp extends StatefulWidget {
  const NafahatApp({super.key});

  @override
  State<NafahatApp> createState() => _NafahatAppState();
}

class _NafahatAppState extends State<NafahatApp> {
  final ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    // الألوان الملكية الفخمة للتصميم الجديد
    const Color primaryGold = Color(0xFFC5A880);
    const Color deepEmerald = Color(0xFF0B3C18);
    const Color lightBg = Color(0xFFF9F6F0);
    const Color darkBg = Color(0xFF0F1410);
    const Color darkSurface = Color(0xFF18221A);

    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: deepEmerald,
      brightness: Brightness.light,
      primary: deepEmerald,
      secondary: primaryGold,
      surface: const Color(0xFFFFFFFF),
      background: lightBg,
    );

    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: deepEmerald,
      brightness: Brightness.dark,
      primary: primaryGold,
      secondary: const Color(0xFF2E7D32),
      surface: darkSurface,
      background: darkBg,
      onSurface: const Color(0xFFE0E0E0),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'نفحات',
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        scaffoldBackgroundColor: lightBg,
        textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(
          ThemeData.light().textTheme,
        ).apply(
          bodyColor: const Color(0xFF2D312E),
          displayColor: deepEmerald,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: deepEmerald),
          titleTextStyle: GoogleFonts.ibmPlexSansArabic(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            color: deepEmerald,
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        scaffoldBackgroundColor: darkBg,
        textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: const Color(0xFFE0E0E0),
          displayColor: primaryGold,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: primaryGold),
          titleTextStyle: GoogleFonts.ibmPlexSansArabic(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            color: primaryGold,
          ),
        ),
      ),
      home: const OnboardingScreen(),
    );
  }
}
