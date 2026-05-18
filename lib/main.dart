import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

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
        scaffoldBackgroundColor: const Color(0xFFF8FBFD),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF006A6A),
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: StepCounterScreen(onThemeToggle: _toggleTheme),
    );
  }
}

class StepCounterScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  const StepCounterScreen({super.key, required this.onThemeToggle});

  @override
  State<StepCounterScreen> createState() => _StepCounterScreenState();
}

class _StepCounterScreenState extends State<StepCounterScreen> {
  int _steps = 0;
  bool _hasPermission = false;
  StreamSubscription<StepCount>? _subscription;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.activityRecognition.request();
    if (mounted) {
      setState(() => _hasPermission = status.isGranted);
    }

    if (status.isGranted) {
      try {
        _subscription = Pedometer.stepCountStream.listen(
          (StepCount event) {
            if (mounted) {
              setState(() {
                _steps = event.steps;
              });
            }
          },
          onError: (_) {},
        );
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  double get _distanceKm => (_steps * 0.0007).clamp(0.0, 999.9);
  double get _calories => (_steps * 0.04).clamp(0.0, 9999.9);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goal = 10000;
    final progress = (_steps / goal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('فِـز', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: widget.onThemeToggle,
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // رسالة الصلاحية (تظهر مرة واحدة فقط)
              if (!_hasPermission)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'يلزم منح صلاحية النشاط البدني لحساب الخطوات',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.orange, fontSize: 14),
                  ),
                ),
              const SizedBox(height: 40),

              // عداد الخطوات
              Text(
                '$_steps',
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.primary,
                  height: 1,
                ),
              ),
              Text(
                'خطوة',
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 20),

              // حلقة التقدم
              SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 10,
                      backgroundColor: colorScheme.primary.withOpacity(0.1),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // بطاقات المسافة والسعرات
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildInfoCard(
                    icon: Icons.straighten_rounded,
                    label: 'المسافة',
                    value: '${_distanceKm.toStringAsFixed(2)} كم',
                    color: Colors.blue,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 20),
                  _buildInfoCard(
                    icon: Icons.local_fire_department_rounded,
                    label: 'السعرات',
                    value: '${_calories.toInt()} سعرة',
                    color: Colors.orange,
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}