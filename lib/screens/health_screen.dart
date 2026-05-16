import 'package:flutter/material.dart';
import 'package:my_first_app/services/database_service.dart';
import 'package:my_first_app/services/goals_service.dart';
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

    // إعادة حساب الأهداف من الملف الشخصي
    GoalsService().recalculateFromProfile();

    setState(() {
      _steps = today.steps;
      _water = today.waterCups;
      _weeklySteps = weeklyActivities.map((a) => a.steps.toDouble()).toList();
      _loading = false;
    });
  }

  void _addWater(int cups) {
    DatabaseService().addWater(cups);
    _loadData();
  }

  void _addSteps(int steps) {
    DatabaseService().addSteps(steps);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final goals = GoalsService();
    final waterGoal = goals.waterGoal;
    final stepsGoal = goals.stepsGoal;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          StatCard(
            icon: Icons.directions_run_rounded,
            title: 'الخطوات اليوم',
            value: '$_steps / $stepsGoal',
            color: Colors.green,
            progress: _steps / stepsGoal.clamp(1, 1000000),
          ),
          const SizedBox(height: 12),
          // أزرار إضافة سريعة للخطوات
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [500, 1000, 2000].map((s) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ActionChip(
                  label: Text('+$s'),
                  onPressed: () => _addSteps(s),
                  backgroundColor: Colors.green.shade50,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          StatCard(
            icon: Icons.water_drop_rounded,
            title: 'شرب الماء',
            value: '$_water / $waterGoal أكواب',
            color: Colors.blue,
            progress: _water / waterGoal.clamp(1, 1000000),
          ),
          const SizedBox(height: 12),
          // أزرار إضافة سريعة للماء
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [1, 2, 3].map((c) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ActionChip(
                  label: Text('+$c كوب'),
                  onPressed: () => _addWater(c),
                  backgroundColor: Colors.blue.shade50,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text('نشاط آخر 7 أيام', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          CustomChartPainter(
            dataPoints: _weeklySteps,
            maxValue: stepsGoal.toDouble(),
          ),
        ],
      ),
    );
  }
}