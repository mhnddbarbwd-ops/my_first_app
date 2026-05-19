import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_first_app/models/user_activity.dart';
import 'package:my_first_app/models/user_profile.dart';
import 'package:my_first_app/screens/dashboard_screen.dart'; // <-- تغيير هنا
import 'package:my_first_app/theme/app_theme.dart';
import 'package:my_first_app/services/notification_service.dart';
import 'package:my_first_app/services/alarm_service.dart';
import 'package:my_first_app/services/database_service.dart';
import 'package:my_first_app/services/pedometer_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  Hive.registerAdapter(UserActivityAdapter());
  Hive.registerAdapter(UserProfileAdapter());
  await Hive.openBox<UserProfile>('profileBox');
  await Hive.openBox('settingsBox');
  await DatabaseService().init();
  await NotificationService().init();
  PedometerService().startListening();
  runApp(const FezApp());
}

class FezApp extends StatefulWidget {
  const FezApp({super.key});

  @override
  State<FezApp> createState() => _FezAppState();
}

class _FezAppState extends State<FezApp> {
  ThemeMode _themeMode = ThemeMode.system;
  String _language = 'ar';

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void toggleLanguage() {
    setState(() {
      _language = _language == 'ar' ? 'en' : 'ar';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AlarmService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'فِـز',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        locale: Locale(_language),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: DashboardScreen(), // <-- تغيير هنا
      ),
    );
  }
}