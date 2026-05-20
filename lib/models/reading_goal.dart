import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class ReadingGoal extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String type;

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
  String reminderTime;

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

// محول يدوي لـ Hive
class ReadingGoalAdapter extends TypeAdapter<ReadingGoal> {
  @override
  final int typeId = 0;

  @override
  ReadingGoal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReadingGoal(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as String,
      totalPages: fields[3] as int,
      completedPages: fields[4] as int,
      startDate: DateTime.fromMillisecondsSinceEpoch(fields[5] as int),
      endDate: DateTime.fromMillisecondsSinceEpoch(fields[6] as int),
      reminderEnabled: fields[7] as bool,
      reminderTime: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ReadingGoal obj) {
    writer.writeByte(9);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.name);
    writer.writeByte(2);
    writer.write(obj.type);
    writer.writeByte(3);
    writer.write(obj.totalPages);
    writer.writeByte(4);
    writer.write(obj.completedPages);
    writer.writeByte(5);
    writer.write(obj.startDate.millisecondsSinceEpoch);
    writer.writeByte(6);
    writer.write(obj.endDate.millisecondsSinceEpoch);
    writer.writeByte(7);
    writer.write(obj.reminderEnabled);
    writer.writeByte(8);
    writer.write(obj.reminderTime);
  }
}