import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hijri_date/hijri_date.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:nafahat/models/user_progress.dart';
import 'package:nafahat/models/challenge_model.dart';
import 'package:nafahat/models/reading_goal.dart';
import 'package:nafahat/models/quran_challenge.dart';
import 'package:nafahat/providers/user_progress_provider.dart';
import 'package:nafahat/screens/onboarding_screen.dart';
import 'package:nafahat/services/goals_service.dart';
import 'package:nafahat/services/reminder_service.dart';
import 'package:nafahat/services/quran_challenge_service.dart';

final ValueNotifier<ThemeMode> appThemeNotifier = ValueNotifier(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(UserProgressAdapter());
  Hive.registerAdapter(ChallengeModelAdapter());
  Hive.registerAdapter(ReadingGoalAdapter());
  Hive.registerAdapter(QuranChallengeAdapter());

  await Hive.openBox<UserProgress>('userProgress');
  await Hive.openBox<ChallengeModel>('challenges');

  await GoalsService().init();
  await QuranChallengeService().init();
  await ReminderService().init();

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
  @override
  Widget build(BuildContext context) {
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
    );

    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: deepEmerald,
      brightness: Brightness.dark,
      primary: primaryGold,
      secondary: const Color(0xFF2E7D32),
      surface: darkSurface,
      onSurface: const Color(0xFFE0E0E0),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProgressProvider()),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: appThemeNotifier,
        builder: (context, currentMode, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'نفحات',
            themeMode: currentMode,
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
        },
      ),
    );
  }
}
