import 'package:flutter/material.dart';
import 'package:my_first_app/models/health_data.dart';
import 'package:my_first_app/services/health_repository.dart';
import 'package:my_first_app/widgets/gradient_progress_indicator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final HealthRepository _repository = HealthRepository();
  late HealthData _data;

  @override
  void initState() {
    super.initState();
    _data = _repository.getCurrentData();
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
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
              Center(
                child: GradientProgressIndicator(
                  progress: _data.readinessScore,
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
                  'درجة الجاهزية',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActivityRing(
                    icon: Icons.directions_run_rounded,
                    title: 'الخطوات',
                    value: _data.steps,
                    goal: 10000,
                    color: Colors.green,
                  ),
                  _buildActivityRing(
                    icon: Icons.water_drop_rounded,
                    title: 'الماء',
                    value: _data.waterCups,
                    goal: 8,
                    color: Colors.blue,
                  ),
                  _buildActivityRing(
                    icon: Icons.bedtime_rounded,
                    title: 'النوم',
                    value: _data.sleepHours.toInt(),
                    goal: 8,
                    color: Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat('متوسط الخطوات', '${_data.weeklyStepsAvg.toInt()}'),
                    _buildStat('السعرات', '${(_data.steps * 0.04).toInt()}'),
                    _buildStat('المسافة', '${(_data.steps * 0.7 / 1000).toStringAsFixed(1)} كم'),
                  ],
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

  Widget _buildActivityRing({
    required IconData icon,
    required String title,
    required int value,
    required int goal,
    required Color color,
  }) {
    final progress = (value / goal).clamp(0.0, 1.0);
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 6,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Icon(icon, color: color, size: 28),
          ],
        ),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        Text(
          '$value / $goal',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }
}// updated
