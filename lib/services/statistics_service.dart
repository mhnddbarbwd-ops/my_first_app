import 'dart:isolate';

class StatisticsService {
  static final StatisticsService _instance = StatisticsService._internal();
  factory StatisticsService() => _instance;
  StatisticsService._internal();

  // حساب نقاط الاستمرارية باستخدام Isolate (حتى لا تتعطل الواجهة)
  Future<double> calculateConsistencyScore(List<bool> dailyAchievements) async {
    final receivePort = ReceivePort();
    await Isolate.spawn(_consistencyIsolate, [receivePort.sendPort, dailyAchievements]);
    final result = await receivePort.first as double;
    receivePort.close();
    return result;
  }

  // كود الـ Isolate: يحسب نسبة الأيام التي تحقق فيها الهدف
  static void _consistencyIsolate(List<dynamic> args) {
    final sendPort = args[0] as SendPort;
    final List<bool> achievements = args[1] as List<bool>;
    if (achievements.isEmpty) {
      sendPort.send(0.0);
      return;
    }
    final achievedDays = achievements.where((day) => day).length;
    final score = (achievedDays / achievements.length) * 100;
    sendPort.send(score);
  }

  // حساب نقاط الاتجاه (Trend Score) بناءً على الأداء الأسبوعي
  double calculateTrendScore(List<int> weeklySteps) {
    if (weeklySteps.length < 2) return 0.0;
    // مقارنة الأسبوع الحالي بالسابق
    final thisWeek = weeklySteps.sublist(0, (weeklySteps.length / 2).ceil()).reduce((a, b) => a + b);
    final lastWeek = weeklySteps.sublist((weeklySteps.length / 2).ceil()).reduce((a, b) => a + b);
    if (lastWeek == 0) return 100.0;
    return ((thisWeek - lastWeek) / lastWeek * 100).clamp(-100.0, 100.0);
  }
}