import 'dart:math';

class PredictionService {
  static final PredictionService _instance = PredictionService._internal();
  factory PredictionService() => _instance;
  PredictionService._internal();

  // نموذج بسيط للتنبؤ باحتمالية تحقيق هدف اليوم بناءً على أداء الأيام الماضية
  double predictSuccessProbability(List<int> last7DaysSteps, int todayTarget) {
    if (last7DaysSteps.isEmpty) return 0.5; // احتمال متساوٍ إذا لم توجد بيانات

    // حساب متوسط الخطوات في آخر 7 أيام
    final averageSteps = last7DaysSteps.reduce((a, b) => a + b) / last7DaysSteps.length;

    // حساب الانحراف المعياري
    final variance = last7DaysSteps.map((s) => pow(s - averageSteps, 2)).reduce((a, b) => a + b) / last7DaysSteps.length;
    final stdDev = sqrt(variance);

    // إذا كان الهدف أقل من المتوسط، احتمال النجاح عالي
    if (todayTarget <= averageSteps) return 0.9;

    // إذا كان الهدف أعلى بكثير، يقل الاحتمال
    final zScore = (todayTarget - averageSteps) / (stdDev + 1); // +1 لتجنب القسمة على صفر
    final probability = 1.0 / (1.0 + exp(-(-zScore + 1.0))); // دالة لوجستية معدلة

    return probability.clamp(0.0, 1.0);
  }

  // يُرجع أفضل وقت مقترح للتذكير بناءً على نشاط المستخدم (تبسيط)
  DateTime suggestReminderTime(List<DateTime> successfulCheckins) {
    if (successfulCheckins.isEmpty) return DateTime.now().add(const Duration(hours: 2));

    // يحسب متوسط ساعة النجاح
    final totalHours = successfulCheckins.map((d) => d.hour).reduce((a, b) => a + b);
    final averageHour = totalHours ~/ successfulCheckins.length;

    return DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, averageHour);
  }
}