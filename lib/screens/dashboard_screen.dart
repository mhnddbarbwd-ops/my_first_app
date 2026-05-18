import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:my_first_app/widgets/gradient_progress_indicator.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  const DashboardScreen({super.key, required this.onThemeToggle});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _steps = 0;
  bool _hasPermission = false;
  StreamSubscription<StepCount>? _subscription;

  @override
  void initState() {
    super.initState();
    _requestPermissionAndListen();
  }

  Future<void> _requestPermissionAndListen() async {
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
        title:
            const Text('فِـز', style: TextStyle(fontWeight: FontWeight.w900)),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 30),
              // بطاقة عداد الخطوات
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withOpacity(isDark ? 0.3 : 0.1),
                      colorScheme.secondary.withOpacity(isDark ? 0.2 : 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border:
                      Border.all(color: colorScheme.primary.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'خطوات اليوم',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$_steps',
                      style: TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.w900,
                          color: colorScheme.primary,
                          height: 1),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'الهدف: ١٠,٠٠٠ خطوة',
                      style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withOpacity(0.5)),
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor:
                            colorScheme.primary.withOpacity(0.15),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // بطاقات المسافة والسعرات
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.straighten_rounded,
                      title: 'المسافة',
                      value: '${_distanceKm.toStringAsFixed(2)}',
                      unit: 'كم',
                      color: Colors.blue,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.local_fire_department_rounded,
                      title: 'السعرات',
                      value: '${_calories.toInt()}',
                      unit: 'سعرة',
                      color: Colors.orange,
                      isDark: isDark,
                    ),
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
    required String title,
    required String value,
    required String unit,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: color.withOpacity(isDark ? 0.15 : 0.08),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            unit,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }
}