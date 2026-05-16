import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class UserActivity {
  @HiveField(0)
  DateTime date;
  @HiveField(1)
  int steps;
  @HiveField(2)
  int waterCups;
  @HiveField(3)
  double distanceKm;
  @HiveField(4)
  int activeMinutes;
  @HiveField(5)
  bool goalAchieved;

  UserActivity({
    required this.date,
    this.steps = 0,
    this.waterCups = 0,
    this.distanceKm = 0.0,
    this.activeMinutes = 0,
    this.goalAchieved = false,
  });
}

class UserActivityAdapter extends TypeAdapter<UserActivity> {
  @override
  final int typeId = 0;

  @override
  UserActivity read(BinaryReader reader) {
    final numFields = reader.readByte();
    DateTime date = DateTime.now();
    int steps = 0, waterCups = 0, activeMinutes = 0;
    double distanceKm = 0.0;
    bool goalAchieved = false;

    for (int i = 0; i < numFields; i++) {
      final int key = reader.readByte();
      final int fieldType = reader.readByte();
      switch (key) {
        case 0:
          date = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
          break;
        case 1:
          steps = reader.readInt();
          break;
        case 2:
          waterCups = reader.readInt();
          break;
        case 3:
          distanceKm = reader.readDouble();
          break;
        case 4:
          activeMinutes = reader.readInt();
          break;
        case 5:
          goalAchieved = reader.readBool();
          break;
        default:
          reader.readByte();
          break;
      }
    }
    return UserActivity(
      date: date,
      steps: steps,
      waterCups: waterCups,
      distanceKm: distanceKm,
      activeMinutes: activeMinutes,
      goalAchieved: goalAchieved,
    );
  }

  @override
  void write(BinaryWriter writer, UserActivity obj) {
    writer.writeByte(6);
    writer.writeByte(0);
    writer.writeByte(16);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeByte(1);
    writer.writeInt(obj.steps);
    writer.writeByte(2);
    writer.writeInt(obj.waterCups);
    writer.writeByte(3);
    writer.writeDouble(obj.distanceKm);
    writer.writeByte(4);
    writer.writeInt(obj.activeMinutes);
    writer.writeByte(5);
    writer.writeBool(obj.goalAchieved);
  }
}