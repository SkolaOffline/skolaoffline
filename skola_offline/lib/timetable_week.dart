import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:skola_offline/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TimetableWeekScreenState extends State<TimetableWeekScreen> {
  List<dynamic> weekTimetable = [];
  List<dynamic> listifiedTimetable = [];
  bool isLoading = true;
  bool _mounted = true;
  DateTime date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchTimetableWeek();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  bool _decideWhichDayToEnable(DateTime day) {
    if (day.weekday == DateTime.monday) {
      return true;
    }
    return false;
  }

  Future<void> _fetchTimetableWeek() async {
    try {
      final timetableData = await downloadTimetableWeek(date);
      if (_mounted) {
        setState(() {
          weekTimetable = parseWeekTimetable(timetableData);
          listifiedTimetable = listify(weekTimetable);
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching timetable: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('y-MM-ddTHH:mm:ss');

    // if (!isLoading) {
    //   if (date.weekday > 0 && date.weekday < 6) {
    //     for (var i = weekTimetable[date.weekday - 1].length - 1; i >= 0; i--) {
    //       if (date.isBefore(dateFormatter
    //           .parse(weekTimetable[date.weekday - 1][i]['endTime']))) {}
    //     }
    //   }
    // }

    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.timetable,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(width: 10),
              Text(
                '${DateFormat('d.M').format(date)} - ${DateFormat(
                  'd.M.y',
                ).format(date.add(Duration(days: 4)))}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, size: 20),
                    onPressed: () {
                      setState(() {
                        date = date.subtract(Duration(days: 7));
                        isLoading = true;
                      });
                      _fetchTimetableWeek();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.date_range, size: 20),
                    onPressed: () {
                      showDatePicker(
                              context: context,
                              firstDate: DateTime(0),
                              lastDate: DateTime(9999),
                              selectableDayPredicate: _decideWhichDayToEnable,
                              locale: const Locale('cs', 'CZ'),
                              initialDate: date
                                  .subtract(Duration(days: date.weekday - 1)))
                          .then((value) {
                        if (value != null) {
                          setState(() {
                            date = value;
                            isLoading = true;
                          });
                          _fetchTimetableWeek();
                        }
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward, size: 20),
                    onPressed: () {
                      setState(() {
                        date = date.add(Duration(days: 7));
                        isLoading = true;
                      });
                      _fetchTimetableWeek();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(4.0),
          child: GridView.count(
            scrollDirection: Axis.horizontal,
            crossAxisCount: 8,
            childAspectRatio: MediaQuery.of(context).size.height /
                (MediaQuery.of(context).size.width) *
                9 /
                24,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            children: [
              for (var i = 0; i < listifiedTimetable.length; i++)
                LessonCardAbbrev(lesson: listifiedTimetable[i]),
            ],
          ),
        ),
      );
    }
  }

  Future<String> downloadTimetable(DateTime whichDay) async {
    if (MyApp.of(context)?.getDummyMode() ?? false) {
      String dummyData =
          await rootBundle.loadString('lib/assets/dummy_timetable.json');
      return dummyData;
    }
    final storage = FlutterSecureStorage();
    final userId = await storage.read(key: 'userId');
    final syID = await storage.read(key: 'schoolYearId');

    DateTime getMidnight(DateTime datetime) {
      return DateTime(datetime.year, datetime.month, datetime.day);
    }

    final day = getMidnight(whichDay);
    final nextDay = getMidnight(day.add(Duration(days: 1)));

    final dateFormatter = DateFormat('y-MM-ddTHH:mm:ss.000');

    Map<String, dynamic> params = {
      'studentId': userId,
      'dateFrom': dateFormatter.format(day),
      'dateTo': dateFormatter.format(nextDay),
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

  Future<String> downloadTimetableWeek(DateTime dateTime) async {
    if (MyApp.of(context)?.getDummyMode() ?? false) {
      String dummyData =
          await rootBundle.loadString('lib/assets/dummy_timetable.json');
      return dummyData;
    } else {
      final storage = FlutterSecureStorage();
      final userId = await storage.read(key: 'userId');
      final syID = await storage.read(key: 'schoolYearId');

      DateTime getMidnight(DateTime datetime) {
        return DateTime(datetime.year, datetime.month, datetime.day);
      }

      final monday =
          getMidnight(dateTime.subtract(Duration(days: dateTime.weekday - 1)));
      final friday = getMidnight(monday.add(Duration(days: 5)));

      final dateFormatter = DateFormat('y-MM-ddTHH:mm:ss.000');

      Map<String, dynamic> params = {
        'studentId': userId,
        'dateFrom': dateFormatter.format(monday),
        'dateTo': dateFormatter.format(friday),
        'schoolYearId': syID
      };

      String url = 'api/v1/timeTable';

      final response = await makeRequest(
        url,
        params,
        context,
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception(
            'Failed to load timetable\n${response.statusCode}\n${response.body}');
      }
    }
  }

  List<dynamic> parseWeekTimetable(String jsonString) {
    Map<String, dynamic> data = jsonDecode(jsonString);
    return data['days'].map((day) => parseDayTimetable(day)).toList();
  }

  List<dynamic> listify(List<dynamic> timetable) {
    List<Map<String, dynamic>> listified = [];
    for (var day in timetable) {
      int len = 0;
      for (var lesson in day) {
        if (lesson['lessonTo'].toString() == '-' ||
            lesson['lessonFrom'].toString() == '-') {
          listified.add(Map<String, dynamic>.from(lesson));
          len += 1;
          continue;
        }
        for (var i = 0;
            i <
                int.parse(lesson['lessonTo']) -
                    int.parse(lesson['lessonFrom']) +
                    1;
            i++) {
          listified.add(Map<String, dynamic>.from(lesson));
          len += 1;
        }
      }
      for (var i = 0; i < 8 - len; i++) {
        listified.add({});
      }
    }
    return listified;
  }

  List<dynamic> parseDayTimetable(Map<String, dynamic> day) {
    return day['schedules']
        .where((lesson) =>
            lesson['hourType']['id'] != 'SKOLNI_AKCE' &&
            lesson['hourType']['id'] != 'SUPLOVANA')
        .map((lesson) => {
              'lessonFrom': lesson['lessonIdFrom'],
              'lessonTo': lesson['lessonIdTo'],
              'lessonType': lesson['hourType']['id'],
              'lessonAbbrev': lesson['subject']['abbrev'],
              'lessonName': lesson['subject']['name'],
              'classroomAbbrev': lesson['rooms'][0]['abbrev'],
              'teacher': lesson['teachers'][0]['displayName'],
              'teacherAbbrev': lesson['teachers'][0]['abbrev'],
              'lessonOrder': lesson['detailHours'][0]['order'],
              'lessonIdFrom': lesson['lessonIdFrom'],
              'lessonIdTo': lesson['lessonIdTo'],
              'beginTime': lesson['beginTime'],
              'endTime': lesson['endTime'],
            })
        .toList();
  }
}

class TimetableWeekScreen extends StatefulWidget {
  @override
  TimetableWeekScreenState createState() => TimetableWeekScreenState();
}

class CurrentLessonCard extends StatelessWidget {
  final Map<String, dynamic> lesson;

  const CurrentLessonCard({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.current_lesson,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(17),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 5,
                    spreadRadius: 2,
                    offset: Offset(7, 7),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: LessonCardAbbrev(lesson: lesson),
              ))
        ],
      ),
    );
  }
}

class LessonCardAbbrev extends StatelessWidget {
  final Map<String, dynamic> lesson;

  const LessonCardAbbrev({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    if (lesson.isEmpty) {
      return Card(
        color: Theme.of(context).colorScheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        child: const SizedBox.shrink(),
      );
    }
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              lesson['lessonAbbrev'].substring(
                0,
                lesson['lessonAbbrev'].length > 4
                    ? 4
                    : lesson['lessonAbbrev'].length,
              ),
              softWrap: true,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              lesson['classroomAbbrev']
                  .replaceAll(RegExp(r'\([^()]*\)'), '')
                  .substring(0, min<int>(3, lesson['classroomAbbrev'].length)),
              softWrap: true,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              lesson['teacherAbbrev'],
              style: const TextStyle(fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}
