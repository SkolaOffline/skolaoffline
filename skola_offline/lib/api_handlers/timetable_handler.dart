import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:skola_offline/main.dart';
import 'package:skola_offline/structs/lesson.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';



class TimetableHandler {

  //! This is a static class that should not be instantiated
  TimetableHandler._();

  static const _TIMETABLE = 'timetable';
  static DateFormat _hiveIndexFormatter = DateFormat('y-MM-dd');

  static final _dateFormatter = DateFormat('y-MM-ddTHH:mm:ss.000');

  static DateTime _getDownloadDate(DateTime date) {
  
    DateTime returnDate = date;

    //TODO: holidays are set strictly to july and august in this whole file
    if (date.month == 7 || date.month == 8) {
      returnDate = DateTime(date.year, 9, 1, 0, 0, 0);
    }

    final monday = returnDate.add(Duration(days: 1-date.weekday));

    returnDate = DateTime(monday.year, monday.month, monday.day, 0, 0, 0);

    return returnDate;
  }

  static List<List<Lesson>> parseWeekTimetable(String jsonString) {
    Map<String, dynamic> data = jsonDecode(jsonString);
    return data['days'].map<List<Lesson>>((day) => parseDayTimetable(day)).toList();
  }

  static List<Lesson> parseDayTimetable(Map<String, dynamic> day) {

    List<Lesson> dayTimetable = [];

    for(Map<String, dynamic>lesson in day['schedules']){
      if(
        // TODO parse different types of lessons
        // lesson['hourType']['id'] != 'SKOLNI_AKCE' &&
        lesson['hourType']['id'] != 'SUPLOVANA'){

          List<String> orderlyService = [];
          
          for(Map<String, dynamic> student in lesson['orderlyService']){
            orderlyService.add('${student['firstName']} ${student['lastname']}');
          }
          dayTimetable.add(Lesson(
          lessonFrom: int.parse(lesson['lessonIdFrom']),
          lessonTo: int.parse(lesson['lessonIdTo']),
          lessonType: lesson['hourType']['id'],
          lessonAbbrev: lesson['subject']['abbrev'] ?? lesson['title'],
          lessonName: lesson['subject']['name'] ?? (lesson['description'] ?? lesson['title']),
          classroomAbbrev: lesson['rooms'][0]['abbrev'],
          teacher: lesson['teachers'][0]['displayName'],
          teacherAbbrev: lesson['teachers'][0]['abbrev'],
          lessonOrder: lesson['detailHours'][0]['order'],
          beginTime: lesson['beginTime'],
          endTime: lesson['endTime'],
          orderlyService: orderlyService,
        ));
      }
    }

    return dayTimetable;
  }

  static Future<void> fetchTimetable(DateTime date, BuildContext context) async{

    final timetableBox = Hive.box(_TIMETABLE);

    final timetable = parseWeekTimetable(await downloadTimetable(date, context));

    for (int i = 0; i < timetable.length; i++) {
      timetableBox.put(_hiveIndexFormatter.format(_getDownloadDate(date).add(Duration(days: i))), timetable[i]);
    }

  }

  // Download timetable for a week. 
  static Future<String> downloadTimetable(DateTime date, BuildContext context) async {
    
    if (MyApp.of(context)?.getDummyMode() ?? false) {
      String dummyData =
          await rootBundle.loadString('lib/assets/dummy_timetable.json');
      return dummyData;
    }
    final storage = FlutterSecureStorage();
    final userId = await storage.read(key: 'userId');
    //TODO: Make a better syID logic that would not get the syID from the storage
    final syID = await storage.read(key: 'schoolYearId');



    Map<String, dynamic> params = {
      'studentId': userId,
      'dateFrom': _dateFormatter.format(_getDownloadDate(date)),
      'dateTo': _dateFormatter.format(_getDownloadDate(date.add(Duration(days: 7)))),
      'schoolYearId': syID
    };

    String url = 'api/v1/timeTable';

    final response = await makeRequest(url, params, context);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(
          'Failed to load timetable\n${response.statusCode}\n${response.body}');
    }

    }

  }

