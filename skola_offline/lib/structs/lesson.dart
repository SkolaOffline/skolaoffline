import 'package:hive/hive.dart';

part 'lesson.g.dart';

@HiveType(typeId: 0)
class Lesson extends HiveObject {
  @HiveField(0)
  int lessonFrom;

  @HiveField(1)
  int lessonTo;

  @HiveField(2)
  String lessonType;

  @HiveField(3)
  String lessonAbbrev;

  @HiveField(4)
  String lessonName;

  @HiveField(5)
  String classroomAbbrev;

  @HiveField(6)
  String teacher;

  @HiveField(7)
  String teacherAbbrev;

  @HiveField(8)
  int lessonOrder;

  @HiveField(9)
  String beginTime;

  @HiveField(10)
  String endTime;

  @HiveField(11)
  List<String> orderlyService;

  Lesson({
    required this.lessonFrom,
    required this.lessonTo,
    required this.lessonType,
    required this.lessonAbbrev,
    required this.lessonName,
    required this.classroomAbbrev,
    required this.teacher,
    required this.teacherAbbrev,
    required this.lessonOrder,
    required this.beginTime,
    required this.endTime,
    required this.orderlyService,
  });
}

