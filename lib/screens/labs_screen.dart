import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_first_app/services/database_service.dart';
import 'package:my_first_app/services/prediction_service.dart';
import 'package:my_first_app/services/statistics_service.dart';
import 'package:my_first_app/services/penalty_service.dart';

class LabsScreen extends StatefulWidget {
  const LabsScreen({super.key});

  @override
  State<LabsScreen> createState() => _LabsScreenState();
}

class _LabsScreenState extends State<LabsScreen> {
  final DatabaseService _db = DatabaseService();
  final PredictionService _prediction = PredictionService();
  final StatisticsService _statistics = StatisticsService();
  final PenaltyService _penalty = PenaltyService();

  double _probability = 0.0;
  double _consistencyScore = 0.0;
  double _trendScore = 0.0;
  int _frozenPoints = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _calculateAnalytics();
  }

  Future<void> _calculateAnalytics() async {
    final activities = _db.getLastWeekActivities();
    if (activities.isEmpty) {
      setState(() => _loading = false);
      return;
    }

    final stepsData = activities.map((a) => a.steps).toList();
    final achievements = activities.map((a) => a.goalAchieved).toList();
    final today = _db.getTodayActivity();

    // حساب احتمالية النجاح
    _probability = _prediction.predictSuccessProbability(stepsData, 10000);

    // حساب نقاط الاستمرارية (باستخدام Isolate)
    _consistencyScore = await _statistics.calculateConsistencyScore(achievements);

    // حساب نقاط الاتجاه
    _trendScore = _statistics.calculateTrendScore(stepsData);

    // حساب العقوبات
    if (_penalty.shouldApplyPenalty(today.steps, 10000, today.waterCups, 8)) {
      _frozenPoints = _penalty.applyFreeze(1);
    } else {
      _frozenPoints = _penalty.freezePoints;
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        title: const Text('المختبر'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            _buildLabCard(
              context,
              icon: Icons.psychology,
              title: 'احتمالية النجاح اليوم',
              value: '${(_probability * 100).toStringAsFixed(0)}%',
              color: _probability > 0.7 ? Colors.green : Colors.orange,
              subtitle: 'بناءً على أدائك في آخر 7 أيام',
            ),
            const SizedBox(height: 12),
            _buildLabCard(
              context,
              icon: Icons.trending_up,
              title: 'نقاط الاستمرارية',
              value: '${_consistencyScore.toStringAsFixed(1)}%',
              color: _consistencyScore > 70 ? Colors.green : Colors.red,
              subtitle: 'معدل تحقيق الأهداف اليومية',
            ),
            const SizedBox(height: 12),
            _buildLabCard(
              context,
              icon: Icons.trending_down,
              title: 'نقاط الاتجاه (Trend)',
              value: '${_trendScore > 0 ? "+" : ""}${_trendScore.toStringAsFixed(1)}%',
              color: _trendScore >= 0 ? Colors.green : Colors.red,
              subtitle: 'مقارنة بالأسبوع الماضي',
            ),
            const SizedBox(height: 20),
            Divider(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
            const SizedBox(height: 10),
            Text('العقوبات (Penalty System)',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'نقاط مجمدة حالياً: $_frozenPoints',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 4),
            Text(
              _frozenPoints > 0
                  ? _penalty.getMotivationalMessage(1) // رسالة تحفيزية قاسية
                  : 'أنت على المسار الصحيح، استمر!',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}