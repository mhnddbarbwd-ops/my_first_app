import 'package:flutter/material.dart';
import 'package:my_first_app/services/database_service.dart';
import 'package:my_first_app/widgets/stat_card.dart';
import 'package:my_first_app/widgets/custom_chart_painter.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  int _steps = 0;
  int _water = 0;
  List<double> _weeklySteps = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final db = DatabaseService();
    final today = db.getTodayActivity();
    final weeklyActivities = db.getLastWeekActivities();

    setState(() {
      _steps = today.steps;
      _water = today.waterCups;
      _weeklySteps = weeklyActivities.map((a) => a.steps.toDouble()).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          StatCard(
            icon: Icons.directions_run_rounded,
            title: 'الخطوات اليوم',
            value: '$_steps / 10,000',
            color: Colors.green,
            progress: _steps / 10000,
          ),
          const SizedBox(height: 12),
          StatCard(
            icon: Icons.water_drop_rounded,
            title: 'شرب الماء',
            value: '$_water / 8 أكواب',
            color: Colors.blue,
            progress: _water / 8,
          ),
          const SizedBox(height: 20),
          Text('نشاط آخر 7 أيام', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          // استخدام الرسم البياني الاحترافي مع البيانات الحقيقية
          CustomChartPainter(
            dataPoints: _weeklySteps,
            maxValue: 10000,
          ),
        ],
      ),
    );
  }
}