import 'package:uuid/uuid.dart';

class AlarmModel {
  final String id;
  final String title;
  final String category;
  final int hour;
  final int minute;
  bool isActive;
  final int goal;
  final int waterGoal;
  final int stepsGoal;
  final double distanceGoal;
  final int durationGoal;

  AlarmModel({
    String? id,
    required this.title,
    required this.category,
    required this.hour,
    required this.minute,
    this.isActive = true,
    this.goal = 1,
    this.waterGoal = 8,
    this.stepsGoal = 5000,
    this.distanceGoal = 5.0,
    this.durationGoal = 30,
  }) : id = id ?? const Uuid().v4();

  String get timeString =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}