import 'package:hive/hive.dart';

@HiveType(typeId: 2)
class UserProgress extends HiveObject {
  @HiveField(0)
  int totalPagesRead;

  @HiveField(1)
  int currentStreak;

  @HiveField(2)
  int bestStreak;

  @HiveField(3)
  int totalXP;

  @HiveField(4)
  int lastReadDay; // Stores as int: yyyyMMdd

  @HiveField(5)
  int lastReadPage;

  UserProgress({
    this.totalPagesRead = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalXP = 0,
    this.lastReadDay = 0,
    this.lastReadPage = 1,
  });

  void markPageRead(int page) {
    final today = _todayInt();
    if (lastReadDay == today) {
      totalPagesRead++;
    } else if (lastReadDay == 0 || lastReadDay == today - 1) {
      currentStreak++;
      if (currentStreak > bestStreak) bestStreak = currentStreak;
      totalPagesRead++;
      lastReadDay = today;
    } else {
      currentStreak = 1;
      totalPagesRead++;
      lastReadDay = today;
    }
    lastReadPage = page;
    totalXP += 10;
    save();
  }

  int _todayInt() {
    final now = DateTime.now();
    return now.year * 10000 + now.month * 100 + now.day;
  }

  void checkDailyStreak() {
    final today = _todayInt();
    if (lastReadDay > 0 && lastReadDay < today - 1) {
      currentStreak = 0;
      save();
    }
  }
}

class UserProgressAdapter extends TypeAdapter<UserProgress> {
  @override
  final int typeId = 2;

  @override
  UserProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProgress(
      totalPagesRead: fields[0] as int? ?? 0,
      currentStreak: fields[1] as int? ?? 0,
      bestStreak: fields[2] as int? ?? 0,
      totalXP: fields[3] as int? ?? 0,
      lastReadDay: fields[4] as int? ?? 0,
      lastReadPage: fields[5] as int? ?? 1,
    );
  }

  @override
  void write(BinaryWriter writer, UserProgress obj) {
    writer.writeByte(6);
    writer.writeByte(0);
    writer.write(obj.totalPagesRead);
    writer.writeByte(1);
    writer.write(obj.currentStreak);
    writer.writeByte(2);
    writer.write(obj.bestStreak);
    writer.writeByte(3);
    writer.write(obj.totalXP);
    writer.writeByte(4);
    writer.write(obj.lastReadDay);
    writer.writeByte(5);
    writer.write(obj.lastReadPage);
  }
}