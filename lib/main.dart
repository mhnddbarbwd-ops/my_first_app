import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hijri_date/hijri_date.dart';
import 'package:nafahat/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar', null);
  HijriDate.setLocal('ar');
  runApp(const NafahatApp());
}

class NafahatApp extends StatelessWidget {
  const NafahatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'نفحات',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF1B5E20),
        scaffoldBackgroundColor: const Color(0xFFF5F0E8),
        textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.ibmPlexSansArabic(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: const Color(0xFF1B5E20),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF1B5E20),
        textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
