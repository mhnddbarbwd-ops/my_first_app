import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class UserProfile {
  @HiveField(0)
  String name;
  @HiveField(1)
  String gender; // ذكر / أنثى
  @HiveField(2)
  int age;
  @HiveField(3)
  double weight; // كجم
  @HiveField(4)
  double height; // سم
  @HiveField(5)
  bool profileComplete;

  UserProfile({
    this.name = '',
    this.gender = 'ذكر',
    this.age = 25,
    this.weight = 70.0,
    this.height = 170.0,
    this.profileComplete = false,
  });
}

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 1;

  @override
  UserProfile read(BinaryReader reader) {
    final numFields = reader.readByte();
    String name = '', gender = 'ذكر';
    int age = 25;
    double weight = 70.0, height = 170.0;
    bool profileComplete = false;

    for (int i = 0; i < numFields; i++) {
      final int key = reader.readByte();
      reader.readByte(); // field type
      switch (key) {
        case 0:
          name = reader.readString();
          break;
        case 1:
          gender = reader.readString();
          break;
        case 2:
          age = reader.readInt();
          break;
        case 3:
          weight = reader.readDouble();
          break;
        case 4:
          height = reader.readDouble();
          break;
        case 5:
          profileComplete = reader.readBool();
          break;
        default:
          reader.readByte();
          break;
      }
    }
    return UserProfile(
      name: name,
      gender: gender,
      age: age,
      weight: weight,
      height: height,
      profileComplete: profileComplete,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer.writeByte(6);
    writer.writeByte(0);
    writer.writeByte(18); // String
    writer.writeString(obj.name);
    writer.writeByte(1);
    writer.writeByte(18);
    writer.writeString(obj.gender);
    writer.writeByte(2);
    writer.writeInt(obj.age);
    writer.writeByte(3);
    writer.writeDouble(obj.weight);
    writer.writeByte(4);
    writer.writeDouble(obj.height);
    writer.writeByte(5);
    writer.writeBool(obj.profileComplete);
  }
}