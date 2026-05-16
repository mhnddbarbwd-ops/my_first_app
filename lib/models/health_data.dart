class HealthData {
  final int steps;
  final int waterCups;
  final double sleepHours;
  final double readinessScore; // 0.0 - 1.0
  final String recommendation; // توصية ذكية
  final double weeklyStepsAvg;

  HealthData({
    this.steps = 0,
    this.waterCups = 0,
    this.sleepHours = 0.0,
    this.readinessScore = 0.7,
    this.recommendation = '',
    this.weeklyStepsAvg = 0,
  });
}