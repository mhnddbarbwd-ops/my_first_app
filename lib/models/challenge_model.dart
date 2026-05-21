import 'package:hive/hive.dart';

@HiveType(typeId: 3)
class ChallengeModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  int targetValue;

  @HiveField(4)
  int currentValue;

  @HiveField(5)
  bool isCompleted;

  @HiveField(6)
  String icon;

  ChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.targetValue,
    this.currentValue = 0,
    this.isCompleted = false,
    this.icon = 'star',
  });

  double get progress => targetValue > 0 ? currentValue / targetValue : 0.0;
}

class ChallengeModelAdapter extends TypeAdapter<ChallengeModel> {
  @override
  final int typeId = 3;

  @override
  ChallengeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChallengeModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      targetValue: fields[3] as int,
      currentValue: fields[4] as int? ?? 0,
      isCompleted: fields[5] as bool? ?? false,
      icon: fields[6] as String? ?? 'star',
    );
  }

  @override
  void write(BinaryWriter writer, ChallengeModel obj) {
    writer.writeByte(7);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.title);
    writer.writeByte(2);
    writer.write(obj.description);
    writer.writeByte(3);
    writer.write(obj.targetValue);
    writer.writeByte(4);
    writer.write(obj.currentValue);
    writer.writeByte(5);
    writer.write(obj.isCompleted);
    writer.writeByte(6);
    writer.write(obj.icon);
  }
}