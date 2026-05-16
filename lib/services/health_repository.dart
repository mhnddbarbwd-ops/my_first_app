import 'package:my_first_app/models/health_data.dart';
import 'package:my_first_app/services/database_service.dart';
import 'package:my_first_app/services/goals_service.dart';

class HealthRepository {
  static final HealthRepository _instance = HealthRepository._internal();
  factory HealthRepository() => _instance;
  HealthRepository._internal();

  final DatabaseService _db = DatabaseService();
  final GoalsService _goals = GoalsService();

  HealthData getCurrentData() {
    final today = _db.getTodayActivity();
    final weekly = _db.getLastWeekActivities();
    final avgSteps = weekly.isEmpty
        ? 0.0
        : weekly.map((a) => a.steps).reduce((a, b) => a + b) / weekly.length;

    final stepsProgress = (today.steps / _goals.stepsGoal).clamp(0.0, 1.0);
    final waterProgress = (today.waterCups / _goals.waterGoal).clamp(0.0, 1.0);
    final readiness = (stepsProgress + waterProgress) / 2.0;

    String recommendation;
    if (readiness > 0.8) {
      recommendation = 'أداء ممتاز! يمكنك زيادة النشاط اليوم.';
    } else if (readiness > 0.5) {
      recommendation = 'أنت على المسار الصحيح، استمر.';
    } else {
      recommendation = 'جسمك يحتاج راحة اليوم، خذ قسطاً من الاسترخاء.';
    }

    final sleepHours = 7.0 + (readiness - 0.5);

    return HealthData(
      steps: today.steps,
      waterCups: today.waterCups,
      sleepHours: sleepHours.clamp(4.0, 10.0),
      readinessScore: readiness,
      recommendation: recommendation,
      weeklyStepsAvg: avgSteps,
    );
  }
}