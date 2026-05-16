import 'package:hive/hive.dart';
import 'package:my_first_app/models/user_profile.dart';

class GoalsService {
  static final GoalsService _instance = GoalsService._internal();
  factory GoalsService() => _instance;
  GoalsService._internal();

  int waterGoal = 8;
  int stepsGoal = 10000;
  double distanceGoal = 5.0;
  int durationGoal = 30;

  void recalculateFromProfile() {
    final profileBox = Hive.box<UserProfile>('profileBox');
    final profile = profileBox.get('user');
    if (profile != null && profile.profileComplete) {
      // حساب الماء بالملليلتر (30-35 مل لكل كجم)
      final waterMl = profile.weight * 32.0;
      waterGoal = (waterMl / 250.0).ceil(); // كل كوب 250 مل

      // حساب الخطوات (5000-10000 حسب العمر)
      if (profile.age < 30) {
        stepsGoal = 10000;
      } else if (profile.age < 50) {
        stepsGoal = 8000;
      } else {
        stepsGoal = 6000;
      }

      // تعديل المسافة والمدة حسب الوزن
      distanceGoal = (profile.weight * 0.07).clamp(3.0, 15.0);
      durationGoal = (profile.age < 40) ? 30 : 20;
    }
  }
}