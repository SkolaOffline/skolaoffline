// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LessonAdapter extends TypeAdapter<Lesson> {
  @override
  final int typeId = 0;

  @override
  Lesson read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Lesson(
      lessonFrom: fields[0] as int,
      lessonTo: fields[1] as int,
      lessonType: fields[2] as String,
      lessonAbbrev: fields[3] as String,
      lessonName: fields[4] as String,
      classroomAbbrev: fields[5] as String,
      teacher: fields[6] as String,
      teacherAbbrev: fields[7] as String,
      lessonOrder: fields[8] as int,
      beginTime: fields[9] as String,
      endTime: fields[10] as String,
      orderlyService: (fields[11] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Lesson obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.lessonFrom)
      ..writeByte(1)
      ..write(obj.lessonTo)
      ..writeByte(2)
      ..write(obj.lessonType)
      ..writeByte(3)
      ..write(obj.lessonAbbrev)
      ..writeByte(4)
      ..write(obj.lessonName)
      ..writeByte(5)
      ..write(obj.classroomAbbrev)
      ..writeByte(6)
      ..write(obj.teacher)
      ..writeByte(7)
      ..write(obj.teacherAbbrev)
      ..writeByte(8)
      ..write(obj.lessonOrder)
      ..writeByte(9)
      ..write(obj.beginTime)
      ..writeByte(10)
      ..write(obj.endTime)
      ..writeByte(11)
      ..write(obj.orderlyService);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
