import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pedometer/pedometer.dart';
import 'package:my_first_app/models/health_data.dart';
import 'package:my_first_app/services/health_repository.dart';
import 'package:my_first_app/services/database_service.dart';
import 'package:my_first_app/widgets/gradient_progress_indicator.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  const DashboardScreen({super.key, required this.onThemeToggle});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final HealthRepository _repository = HealthRepository();
  late HealthData _data;
  StreamSubscription<StepCount>? _stepSubscription;
  bool _permissionGranted = false;
  bool _sensorWorking = false;
  int _liveSteps = 0;

  @override
  void initState() {
    super.initState();
    _data = _repository.getCurrentData();
    _requestPermissionAndListen();
  }

  Future<void> _requestPermissionAndListen() async {
    // طلب صلاحية النشاط البدني
    final status = await Permission.activityRecognition.request();
    if (mounted) {
      setState(() {
        _permissionGranted = status.isGranted;
      });
    }

    if (status.isGranted) {
      // بدء الاستماع للخطوات من المستشعر مباشرة
      try {
        _stepSubscription = Pedometer.stepCountStream.listen(
          (StepCount event) {
            if (mounted) {
              setState(() {
                _sensorWorking = true;
                _liveSteps = event.steps;
              });
              // حفظ في قاعدة البيانات
              DatabaseService().addSteps(event.steps);
            }
          },
          onError: (error) {
            if (mounted) {
              setState(() => _sensorWorking = false);
            }
          },
        );
      } catch (e) {
        if (mounted) {
          setState(() => _sensorWorking = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _stepSubscription?.cancel();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {
        _data = _repository.getCurrentData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true,
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('فِـز', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colorScheme.primary),
            onPressed: _refresh,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // مؤشرات الحالة
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatusChip(
                    icon: _permissionGranted ? Icons.check_circle : Icons.cancel,
                    label: _permissionGranted ? 'الصلاحية ممنوحة' : 'الصلاحية مرفوضة',
                    color: _permissionGranted ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(
                    icon: _sensorWorking ? Icons.sensors : Icons.sensors_off,
                    label: _sensorWorking ? 'المستشعر يعمل' : 'المستشعر متوقف',
                    color: _sensorWorking ? Colors.green : Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                _getGreeting(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _data.recommendation,
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              // عداد الخطوات الحي
              Center(
                child: Column(
                  children: [
                    Text(
                      '$_liveSteps',
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      'خطوة',
                      style: TextStyle(
                        fontSize: 18,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: GradientProgressIndicator(
                  progress: (_liveSteps / 10000).clamp(0.0, 1.0),
                  size: 160,
                  strokeWidth: 12,
                  gradientColors: [
                    colorScheme.primary,
                    colorScheme.tertiary,
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'الهدف: 10,000 خطوة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير';
    if (hour < 17) return 'مساء الخير';
    return 'ليلة سعيدة';
  }

  Widget _buildStatusChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}
