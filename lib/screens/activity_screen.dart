import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:my_first_app/services/database_service.dart';
import 'package:my_first_app/services/goals_service.dart';
import 'package:my_first_app/models/user_profile.dart';
import 'package:hive/hive.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  List<double> _weeklySteps = [];
  List<double> _weeklyWater = [];
  int _todaySteps = 0;
  int _todayWater = 0;
  double _caloriesBurned = 0;
  double _distanceKm = 0;
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
    final goals = GoalsService();
    goals.recalculateFromProfile();

    // الحصول على الملف الشخصي لحساب السعرات
    final profileBox = Hive.box<UserProfile>('profileBox');
    final profile = profileBox.get('user');

    if (profile != null) {
      // حساب السعرات الحرارية التقريبي (خطوة واحدة ≈ 0.04 سعرة حرارية)
      _caloriesBurned = today.steps * 0.04;
      // حساب المسافة التقريبية (خطوة ≈ 0.7 متر)
      _distanceKm = (today.steps * 0.7) / 1000;
    }

    setState(() {
      _todaySteps = today.steps;
      _todayWater = today.waterCups;
      _weeklySteps = weeklyActivities.map((a) => a.steps.toDouble()).toList();
      _weeklyWater = weeklyActivities.map((a) => a.waterCups.toDouble()).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final goals = GoalsService();
    final stepsGoal = goals.stepsGoal;
    final waterGoal = goals.waterGoal;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          // حلقات التقدم الدائرية
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildProgressRing(
                icon: Icons.directions_run,
                title: 'الخطوات',
                value: _todaySteps.toDouble(),
                goal: stepsGoal.toDouble(),
                color: Colors.green,
                unit: '',
              ),
              _buildProgressRing(
                icon: Icons.water_drop,
                title: 'الماء',
                value: _todayWater.toDouble(),
                goal: waterGoal.toDouble(),
                color: Colors.blue,
                unit: 'كوب',
              ),
              _buildProgressRing(
                icon: Icons.local_fire_department,
                title: 'السعرات',
                value: _caloriesBurned,
                goal: 500, // هدف افتراضي 500 سعرة
                color: Colors.orange,
                unit: '',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ملخص إحصائيات اليوم
          Card(
            elevation: 0,
            color: Theme.of(context).cardTheme.color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(Icons.straighten, 'المسافة', '${_distanceKm.toStringAsFixed(1)} كم'),
                  _buildStatItem(Icons.timer, 'الحركة', '${(_todaySteps / 100).round()} دقيقة'),
                  _buildStatItem(Icons.trending_up, 'الهدف', '${((_todaySteps / stepsGoal) * 100).round()}%'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // رسم بياني تفاعلي للخطوات
          Text('الخطوات - آخر 7 أيام', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: stepsGoal * 1.5,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()} خطوة',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['قبل 6', 'قبل 5', 'قبل 4', 'قبل 3', 'قبل 2', 'أمس', 'اليوم'];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(days[value.toInt() % 7], style: const TextStyle(fontSize: 10)),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                barGroups: _weeklySteps.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value,
                        gradient: LinearGradient(
                          colors: [const Color(0xFF006A6A), const Color(0xFF006A6A).withOpacity(0.5)],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 16,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRing({
    required IconData icon,
    required String title,
    required double value,
    required double goal,
    required Color color,
    required String unit,
  }) {
    final progress = (value / goal).clamp(0.0, 1.0);
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Icon(icon, color: color, size: 28),
          ],
        ),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        Text(
          '${value.toInt()}$unit',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
        ),
        Text(
          '/ ${goal.toInt()}$unit',
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}