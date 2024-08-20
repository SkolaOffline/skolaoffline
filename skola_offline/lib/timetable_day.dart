import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:skola_offline/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TimetableDayScreenState extends State<TimetableDayScreen> {
  List<dynamic> dayTimetable = [];
  List<dynamic> todayTimetable = [];
  bool isLoading = true;
  bool _mounted = true;
  DateTime date = DateTime.now();
  DateTime today = DateTime(2024, 5, 27, 8, 40, 03);
  bool isLoadingToday = true;

  @override
  void initState() {
    super.initState();
    _fetchTimetable();
    _fetchTimetableForToday();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> _fetchTimetable() async {
    try {
      final timetableData = await downloadTimetable(date);
      if (_mounted) {
        setState(() {
          dayTimetable = parseWeekTimetable(timetableData)[0];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching timetable: $e');
      if (_mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchTimetableForToday() async {
    today = (MyApp.of(context)?.getDummyMode() ?? false)
        ? DateTime(2024, 5, 27, 8, 46, 03)
        : DateTime.now();

    try {
      final timetableData = await downloadTimetable(today);
      if (_mounted) {
        setState(() {
          todayTimetable = parseWeekTimetable(timetableData)[0];
          isLoadingToday = false;
        });
      }
    } catch (e) {
      print('Error fetching timetable for today: $e');
      if (_mounted) {
        setState(() {
          isLoadingToday = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('y-MM-ddTHH:mm:ss');

    var currentLessonIndex = -1;
    if (!isLoadingToday) {
      for (var i = todayTimetable.length - 1; i >= 0; i--) {
        if (today.isBefore(dateFormatter.parse(todayTimetable[i]['endTime']))) {
          currentLessonIndex = i;
        }
      }
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchTimetable,
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! < 0) {
              if (date.weekday == 1) {
                date = date.subtract(Duration(days: 3));
              } else {
                date = date.subtract(Duration(days: 1));
              }
              isLoading = true;
            } else if (details.primaryVelocity! > 0) {
              if (date.weekday == 5) {
                date = date.add(Duration(days: 3));
              } else {
                date = date.add(Duration(days: 1));
              }
              isLoading = true;
            }
            _fetchTimetable();
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: isLoadingToday
                        ? Center(child: CircularProgressIndicator())
                        : (currentLessonIndex == -1
                            ? Center(
                                child: Text(AppLocalizations.of(context)!
                                    .no_lessons_for_today))
                            : CurrentLessonCard(
                                lesson: todayTimetable[currentLessonIndex]))),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.timetable,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '${DateFormat('EE').format(date)}, ${DateFormat(
                          'd.M.y',
                        ).format(date)}',
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {
                              setState(() {
                                if (date.weekday == 1) {
                                  date = date.subtract(Duration(days: 3));
                                } else {
                                  date = date.subtract(Duration(days: 1));
                                }
          
                                isLoading = true;
                              });
                              _fetchTimetable();
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.date_range),
                            onPressed: () {
                              showDatePicker(
                                      context: context,
                                      firstDate: DateTime(0),
                                      lastDate: DateTime(9999),
                                      initialDate: date)
                                  .then((value) {
                                if (value != null) {
                                  setState(() {
                                    date = value;
                                    isLoading = true;
                                  });
                                  _fetchTimetable();
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_forward),
                            onPressed: () {
                              if (date.weekday == 5) {
                                date = date.add(Duration(days: 3));
                              } else {
                                date = date.add(Duration(days: 1));
                              }
                              isLoading = true;
          
                              _fetchTimetable();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              isLoading
                  ? SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final lesson = dayTimetable[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 0.0),
                            child: LessonCard(lesson: lesson),
                          );
                        },
                        childCount:
                            dayTimetable.isEmpty ? 0 : dayTimetable.length,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> downloadTimetable(DateTime whichDay) async {
    if (MyApp.of(context)?.getDummyMode() ?? false) {
      String dummyData =
          // TODO: make dummy data for one day
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

    final dateFormatter = DateFormat('y-MM-ddTHH:mm:ss.000');

    Map<String, dynamic> params = {
      'studentId': userId,
      'dateFrom': dateFormatter.format(day),
      'dateTo': dateFormatter.format(day),
      'schoolYearId': syID
    };

    String url = 'api/v1/timeTable';

    // ignore: use_build_context_synchronously
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
      getMidnight(monday.add(Duration(days: 5)));

      final dateFormatter = DateFormat('y-MM-ddTHH:mm:ss.000');

      Map<String, dynamic> params = {
        'studentId': userId,
        // TODO change to dateTime
        // 'dateFrom': dateFormatter.format(monday),
        // 'dateTo': dateFormatter.format(friday),
        'dateFrom': dateFormatter.format(DateTime(2024, 6, 3, 0, 0, 0)),
        'dateTo': dateFormatter.format(DateTime(2024, 6, 7, 0, 0, 0)),
        'schoolYearId': syID
      };

      String url = 'api/v1/timeTable';

      final response = await makeRequest(
        url,
        params,
        // ignore: use_build_context_synchronously
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

  List<dynamic> parseDayTimetable(Map<String, dynamic> day) {
    return day['schedules']
        .where((lesson) =>
            // TODO parse different types of lessons
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

class TimetableDayScreen extends StatefulWidget {
  @override
  TimetableDayScreenState createState() => TimetableDayScreenState();
}

class CurrentLessonCard extends StatefulWidget {
  final Map<String, dynamic> lesson;

  const CurrentLessonCard({super.key, required this.lesson});

  @override
  _CurrentLessonCardState createState() => _CurrentLessonCardState();
}

class _CurrentLessonCardState extends State<CurrentLessonCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                child: LessonCard(lesson: widget.lesson),
              ))
        ],
      ),
    );
  }
}

class LessonCard extends StatelessWidget {
  final Map<String, dynamic> lesson;

  const LessonCard({super.key, required this.lesson});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: EdgeInsets.all(0),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    lesson['lessonIdFrom'] == lesson['lessonIdTo']
                        ? lesson['lessonIdFrom'].toString()
                        : '${lesson['lessonIdFrom']}-${lesson['lessonIdTo']}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formatTime(lesson['beginTime']),
                    style: TextStyle(fontSize: 10),
                  ),
                  Text(
                    formatTime(lesson['endTime']),
                    style: TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
            SizedBox(width: 19),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${lesson['lessonAbbrev']} - ${lesson['lessonName']}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    lesson['classroomAbbrev'],
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    lesson['teacher'],
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatTime(String time) {
    final dateTime = DateTime.parse(time);
    return DateFormat('HH:mm').format(dateTime);
  }
}
