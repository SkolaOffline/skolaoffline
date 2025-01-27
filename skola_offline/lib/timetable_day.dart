import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:skola_offline/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:skola_offline/structs/lesson.dart';
import 'package:skola_offline/api_handlers/timetable_handler.dart';

const TIMETABLE = 'timetable';
DateFormat hiveIndexFormatter = DateFormat('y-MM-dd');
class TimetableDayScreenState extends State<TimetableDayScreen> {
  List<Lesson> dayTimetable = [];
  List<Lesson> todayTimetable = [];
  bool isLoading = true;
  bool _mounted = true;
  DateTime date = DateTime.now().add(Duration(days: -3));
  DateTime today = DateTime(2024, 5, 27, 8, 40, 03);
  bool isLoadingToday = true;


  void cacheCheck(){
    if (_mounted && Hive.box(TIMETABLE).get(hiveIndexFormatter.format(date)) != null && Hive.box(TIMETABLE).get(hiveIndexFormatter.format(date)) is List<Lesson>) {
      print('Cache update');
      setState(() {
        dayTimetable = Hive.box(TIMETABLE).get(hiveIndexFormatter.format(date));
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    Hive.box(TIMETABLE).listenable().addListener(() {
      cacheCheck();
    });

    cacheCheck();
    TimetableHandler.fetchTimetable(date, context);
    _fetchTimetableForToday();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> _fetchTimetableForToday() async {
    today = (MyApp.of(context)?.getDummyMode() ?? false)
        ? DateTime(2024, 5, 27, 8, 46, 03)
        : DateTime.now();

    // holiday fix
    if (today.month == 7 || today.month == 8) {
      today = DateTime(today.year, 9, 1, 0, 0, 0);
    }

    //weekend fix
    if (today.weekday == 6) {
      today.add(Duration(days: 2));
    } else if (today.weekday == 7) {
      today.add(Duration(days: 1));
    }

    try {
      final timetableData = await TimetableHandler.downloadTimetable(today,context);
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
        if (DateTime.now().isBefore(dateFormatter.parse(todayTimetable[i].endTime))) {
          currentLessonIndex = i;
        }
      }
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await TimetableHandler.fetchTimetable(date, context);
        },
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! > 0) {
              if (date.weekday == 1) {
                date = date.subtract(Duration(days: 3));
              } else {
                date = date.subtract(Duration(days: 1));
              }
              isLoading = true;
            } else if (details.primaryVelocity! < 0) {
              if (date.weekday == 5) {
                date = date.add(Duration(days: 3));
              } else {
                date = date.add(Duration(days: 1));
              }
              isLoading = true;
            }
            TimetableHandler.fetchTimetable(date, context);
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 10, bottom: 20),
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
                        '${DateFormat('EE').format(date)}, ${DateFormat(
                          'd.M.y',
                        ).format(date)}',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w300),
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
                              
                              cacheCheck();
                              TimetableHandler.fetchTimetable(date,context);
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

                                  cacheCheck();
                                  TimetableHandler.fetchTimetable(date,context);
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
                              
                              cacheCheck();
                              TimetableHandler.fetchTimetable(date,context);

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
              isLoading || dayTimetable.isEmpty
                  ? SliverToBoxAdapter(child: Container()) : SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 5, bottom: 20),
                        child: Text("Orderly service: ${dayTimetable[0].orderlyService.join(', ').replaceAll(RegExp(r'[\{\}]'),'')}",
                          style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w300),
                ))),
            ],
          ),
        ),
      ),
    );
  }

  List<List<Lesson>> parseWeekTimetable(String jsonString) {
    Map<String, dynamic> data = jsonDecode(jsonString);
    return data['days'].map<List<Lesson>>((day) => parseDayTimetable(day)).toList();
  }

  List<Lesson> parseDayTimetable(Map<String, dynamic> day) {

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
          lessonName: lesson['subject']['name'] ?? lesson['description'],
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
}

class TimetableDayScreen extends StatefulWidget {
  @override
  TimetableDayScreenState createState() => TimetableDayScreenState();
}

class CurrentLessonCard extends StatefulWidget {
  final Lesson lesson;

  const CurrentLessonCard({super.key, required this.lesson});

  @override
  _CurrentLessonCardState createState() => _CurrentLessonCardState();
}

class _CurrentLessonCardState extends State<CurrentLessonCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(0),
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
  final Lesson lesson;

  const LessonCard({super.key, required this.lesson});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      // color: Theme.of(context).colorScheme.secondaryContainer,
      color: lesson.lessonType == 'ROZVRH' ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.tertiaryContainer,
      child: Padding(
        padding: EdgeInsets.all(0),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: lesson.lessonType == 'ROZVRH' ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    spreadRadius: 0,
                    offset: Offset(7, 0),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    lesson.lessonFrom == lesson.lessonTo
                        ? lesson.lessonFrom.toString()
                        : '${lesson.lessonFrom}-${lesson.lessonTo}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formatTime(lesson.beginTime),
                    style: TextStyle(fontSize: 10),
                  ),
                  Text(
                    formatTime(lesson.endTime),
                    style: TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${lesson.lessonAbbrev} - ${lesson.lessonName}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    lesson.classroomAbbrev,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    lesson.teacher,
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
