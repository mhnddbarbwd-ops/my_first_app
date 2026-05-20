import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class QuranChallenge extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  int startPage;

  @HiveField(3)
  int endPage;

  @HiveField(4)
  int totalPages;

  @HiveField(5)
  int completedPages;

  @HiveField(6)
  DateTime startDate;

  @HiveField(7)
  DateTime endDate;

  @HiveField(8)
  bool reminderEnabled;

  @HiveField(9)
  String reminderTime;

  @HiveField(10)
  int streakDays;

  QuranChallenge({
    required this.id,
    required this.title,
    required this.startPage,
    required this.endPage,
    required this.totalPages,
    required this.startDate,
    required this.endDate,
    this.completedPages = 0,
    this.reminderEnabled = false,
    this.reminderTime = "09:00",
    this.streakDays = 0,
  });

  double get progress => totalPages > 0 ? completedPages / totalPages : 0.0;
  int get remainingPages => totalPages - completedPages;
  int get remainingDays => endDate.difference(DateTime.now()).inDays;
  int get pagesPerDay => remainingDays > 0 ? (remainingPages / remainingDays).ceil() : remainingPages;
}

class QuranChallengeAdapter extends TypeAdapter<QuranChallenge> {
  @override
  final int typeId = 1;

  @override
  QuranChallenge read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuranChallenge(
      id: fields[0] as String,
      title: fields[1] as String,
      startPage: fields[2] as int,
      endPage: fields[3] as int,
      totalPages: fields[4] as int,
      completedPages: fields[5] as int,
      startDate: DateTime.fromMillisecondsSinceEpoch(fields[6] as int),
      endDate: DateTime.fromMillisecondsSinceEpoch(fields[7] as int),
      reminderEnabled: fields[8] as bool,
      reminderTime: fields[9] as String,
      streakDays: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, QuranChallenge obj) {
    writer.writeByte(11);
    writer.writeByte(0); writer.write(obj.id);
    writer.writeByte(1); writer.write(obj.title);
    writer.writeByte(2); writer.write(obj.startPage);
    writer.writeByte(3); writer.write(obj.endPage);
    writer.writeByte(4); writer.write(obj.totalPages);
    writer.writeByte(5); writer.write(obj.completedPages);
    writer.writeByte(6); writer.write(obj.startDate.millisecondsSinceEpoch);
    writer.writeByte(7); writer.write(obj.endDate.millisecondsSinceEpoch);
    writer.writeByte(8); writer.write(obj.reminderEnabled);
    writer.writeByte(9); writer.write(obj.reminderTime);
    writer.writeByte(10); writer.write(obj.streakDays);
  }
}