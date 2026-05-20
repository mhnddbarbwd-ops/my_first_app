import 'package:hive/hive.dart';
import 'package:nafahat/models/reading_goal.dart';

class GoalsService {
  static final GoalsService _instance = GoalsService._internal();
  factory GoalsService() => _instance;
  GoalsService._internal();

  Box<ReadingGoal>? _goalBox;

  Future<void> init() async {
    _goalBox = await Hive.openBox<ReadingGoal>('readingGoals');
  }

  List<ReadingGoal> get goals => _goalBox?.values.toList() ?? [];

  Future<void> addGoal(ReadingGoal goal) async {
    await _goalBox?.put(goal.id, goal);
  }

  Future<void> updateGoal(ReadingGoal goal) async {
    await goal.save();
  }

  Future<void> deleteGoal(String id) async {
    await _goalBox?.delete(id);
  }

  ReadingGoal? getGoalById(String id) {
    return _goalBox?.get(id);
  }
}