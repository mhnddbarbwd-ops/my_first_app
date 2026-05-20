import 'package:hive/hive.dart';

part 'reading_goal.g.dart';

@HiveType(typeId: 0)
class ReadingGoal extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String type; // "khatm", "hifz", "custom"

  @HiveField(3)
  int totalPages;

  @HiveField(4)
  int completedPages;

  @HiveField(5)
  DateTime startDate;

  @HiveField(6)
  DateTime endDate;

  @HiveField(7)
  bool reminderEnabled;

  @HiveField(8)
  String reminderTime; // "HH:mm"

  ReadingGoal({
    required this.id,
    required this.name,
    required this.type,
    required this.totalPages,
    required this.startDate,
    required this.endDate,
    this.completedPages = 0,
    this.reminderEnabled = false,
    this.reminderTime = "09:00",
  });

  double get progress => totalPages > 0 ? completedPages / totalPages : 0.0;

  int get remainingPages => totalPages - completedPages;
}