import 'package:hive/hive.dart';
import 'package:my_first_app/models/user_activity.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static const String _activityBoxName = 'activityBox';
  late Box<UserActivity> _activityBox;

  Future<void> init() async {
    _activityBox = await Hive.openBox<UserActivity>(_activityBoxName);
  }

  // حفظ نشاط يوم جديد أو تحديثه
  Future<void> saveActivity(UserActivity activity) async {
    final key = activity.date.toIso8601String().split('T')[0];
    await _activityBox.put(key, activity);
  }

  // جلب نشاط تاريخ محدد
  UserActivity? getActivity(DateTime date) {
    final key = date.toIso8601String().split('T')[0];
    return _activityBox.get(key);
  }

  // جلب آخر 7 أيام من النشاط
  List<UserActivity> getLastWeekActivities() {
    final now = DateTime.now();
    final activities = <UserActivity>[];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final activity = getActivity(date) ?? UserActivity(date: date, steps: 0, waterCups: 0);
      activities.add(activity);
    }
    return activities;
  }

  // الحصول على نشاط اليوم الحالي أو إنشاؤه
  UserActivity getTodayActivity() {
    final today = DateTime.now();
    return getActivity(today) ?? UserActivity(date: today, steps: 0, waterCups: 0);
  }

  // إضافة خطوات لليوم الحالي
  Future<void> addSteps(int steps) async {
    final today = getTodayActivity();
    today.steps += steps;
    await saveActivity(today);
  }

  // إضافة أكواب ماء لليوم الحالي
  Future<void> addWater(int cups) async {
    final today = getTodayActivity();
    today.waterCups += cups;
    await saveActivity(today);
  }

  // وضع علامة على الهدف كمحقق
  Future<void> markGoalAchieved() async {
    final today = getTodayActivity();
    today.goalAchieved = true;
    await saveActivity(today);
  }
}