import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_first_app/screens/dashboard_screen.dart';

void main() {
  runApp(const FezApp());
}

class FezApp extends StatefulWidget {
  const FezApp({super.key});

  @override
  State<FezApp> createState() => _FezAppState();
}

class _FezAppState extends State<FezApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'فِـز',
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF006A6A),
        scaffoldBackgroundColor: const Color(0xFFF0F4F8),
        textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.ibmPlexSansArabic(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: const Color(0xFF006A6A),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF006A6A),
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(
          ThemeData.dark().textTheme,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.ibmPlexSansArabic(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: const Color(0xFF80CBC4),
          ),
        ),
      ),
      home: DashboardScreen(onThemeToggle: _toggleTheme),
    );
  }
}