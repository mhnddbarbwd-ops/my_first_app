import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hijri_date/hijri_date.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nafahat/screens/splash_screen.dart';
import 'package:nafahat/screens/onboarding_screen.dart';
import 'package:nafahat/screens/login_screen.dart';
import 'package:nafahat/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
  ThemeMode _themeMode = ThemeMode.system;

  void toggleTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    // تعريف الألوان يدويًا للتحكم الكامل في التباين
    const Color seedColor = Color(0xFF1B5E20);
    const Color lightSurface = Color(0xFFF5F0E8);
    const Color darkSurface = Color(0xFF1A1A1A);
    const Color darkBackground = Color(0xFF121212);

    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
      surface: lightSurface,
    );

    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
      surface: darkSurface,
      background: darkBackground,
      onSurface: const Color(0xFFF5F5F5),
      onBackground: const Color(0xFFF5F5F5),
      onPrimary: const Color(0xFF121212),
      onSecondary: const Color(0xFF121212),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'نفحات',
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        scaffoldBackgroundColor: lightColorScheme.surface,
        textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(
          ThemeData.light().textTheme,
        ).apply(
          bodyColor: lightColorScheme.onSurface,
          displayColor: lightColorScheme.onSurface,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.ibmPlexSansArabic(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: lightColorScheme.primary,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          color: lightColorScheme.surface,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: lightColorScheme.surface,
          selectedItemColor: lightColorScheme.primary,
          unselectedItemColor: lightColorScheme.onSurface.withOpacity(0.5),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        scaffoldBackgroundColor: darkColorScheme.background,
        textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: darkColorScheme.onSurface,
          displayColor: darkColorScheme.onSurface,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.ibmPlexSansArabic(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: darkColorScheme.primary,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          color: darkColorScheme.surface,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: darkColorScheme.surface,
          selectedItemColor: darkColorScheme.primary,
          unselectedItemColor: darkColorScheme.onSurface.withOpacity(0.5),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        final user = snapshot.data;
        if (user == null) {
          return const OnboardingScreen();
        }
        return const HomeScreen();
      },
    );
  }
}