import 'package:flutter/material.dart';
import 'package:my_first_app/services/goals_service.dart';
import 'package:my_first_app/services/database_service.dart';
import 'package:my_first_app/widgets/gradient_progress_indicator.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final GoalsService _goals = GoalsService();
  late int _waterGoal, _stepsGoal, _durationGoal;
  late double _distanceGoal;

  @override
  void initState() {
    super.initState();
    _goals.recalculateFromProfile();
    _waterGoal = _goals.waterGoal;
    _stepsGoal = _goals.stepsGoal;
    _distanceGoal = _goals.distanceGoal;
    _durationGoal = _goals.durationGoal;
  }

  void _saveGoals() {
    _goals.waterGoal = _waterGoal;
    _goals.stepsGoal = _stepsGoal;
    _goals.distanceGoal = _distanceGoal;
    _goals.durationGoal = _durationGoal;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ الأهداف')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();
    final today = db.getTodayActivity();

    return Scaffold(
      appBar: AppBar(
        title: const Text('أهدافي'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: _saveGoals,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            // نظرة عامة على التقدم
            Card(
              elevation: 0,
              color: Theme.of(context).cardTheme.color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // مؤشر تقدم الماء
                    GradientProgressIndicator(
                      progress: (today.waterCups / _waterGoal).clamp(0.0, 1.0),
                      size: 100,
                      strokeWidth: 8,
                      gradientColors: const [Color(0xFF2196F3), Color(0xFF64B5F6)],
                    ),
                    // مؤشر تقدم الخطوات
                    GradientProgressIndicator(
                      progress: (today.steps / _stepsGoal).clamp(0.0, 1.0),
                      size: 100,
                      strokeWidth: 8,
                      gradientColors: const [Color(0xFF4CAF50), Color(0xFF81C784)],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'تقدم اليوم: ماء ${today.waterCups}/$_waterGoal | خطوات ${today.steps}/$_stepsGoal',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),

            // بطاقات الأهداف
            _buildGoalCard(
              icon: Icons.water_drop,
              title: 'أكواب الماء يومياً',
              value: _waterGoal,
              onDecrement: () => setState(() => _waterGoal = (_waterGoal - 1).clamp(1, 50)),
              onIncrement: () => setState(() => _waterGoal = (_waterGoal + 1).clamp(1, 50)),
              color: Colors.blue,
              subtitle: 'بناءً على وزنك: ${_waterGoal} أكواب',
            ),
            const SizedBox(height: 12),
            _buildGoalCard(
              icon: Icons.directions_run,
              title: 'الخطوات يومياً',
              value: _stepsGoal,
              onDecrement: () => setState(() => _stepsGoal = (_stepsGoal - 500).clamp(1000, 50000)),
              onIncrement: () => setState(() => _stepsGoal = (_stepsGoal + 500).clamp(1000, 50000)),
              color: Colors.green,
              subtitle: 'المسافة التقريبية: ${(_distanceGoal).toStringAsFixed(1)} كم',
            ),
            const SizedBox(height: 12),
            _buildGoalCard(
              icon: Icons.map,
              title: 'المسافة (كم)',
              value: _distanceGoal.toInt(),
              onDecrement: () => setState(() => _distanceGoal = (_distanceGoal - 0.5).clamp(0.5, 50.0)),
              onIncrement: () => setState(() => _distanceGoal = (_distanceGoal + 0.5).clamp(0.5, 50.0)),
              color: Colors.orange,
              subtitle: '${(_distanceGoal * 0.7).toInt()} سعرة تقريباً',
            ),
            const SizedBox(height: 12),
            _buildGoalCard(
              icon: Icons.timer,
              title: 'مدة التمرين (دقيقة)',
              value: _durationGoal,
              onDecrement: () => setState(() => _durationGoal = (_durationGoal - 5).clamp(5, 300)),
              onIncrement: () => setState(() => _durationGoal = (_durationGoal + 5).clamp(5, 300)),
              color: Colors.purple,
              subtitle: 'موصى به: ${_durationGoal} دقيقة يومياً',
            ),
            const SizedBox(height: 20),

            // زر حفظ
            ElevatedButton.icon(
              onPressed: _saveGoals,
              icon: const Icon(Icons.save),
              label: const Text('حفظ الأهداف'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
            const SizedBox(height: 8),

            // زر إعادة التعيين إلى الذكي
            OutlinedButton.icon(
              onPressed: () {
                _goals.recalculateFromProfile();
                setState(() {
                  _waterGoal = _goals.waterGoal;
                  _stepsGoal = _goals.stepsGoal;
                  _distanceGoal = _goals.distanceGoal;
                  _durationGoal = _goals.durationGoal;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تمت إعادة الحساب من بيانات ملفك الشخصي')),
                );
              },
              icon: const Icon(Icons.auto_fix_high),
              label: const Text('إعادة الحساب تلقائياً'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard({
    required IconData icon,
    required String title,
    required int value,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required Color color,
    String? subtitle,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.remove_circle_outline, color: color),
                  onPressed: onDecrement,
                ),
                Text(
                  '$value',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Theme.of(context).colorScheme.onSurface),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline, color: color),
                  onPressed: onIncrement,
                ),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(right: 48),
                child: Text(subtitle, style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}