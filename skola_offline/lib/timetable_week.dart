import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:skola_offline/structs/lesson.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:skola_offline/api_handlers/timetable_handler.dart';

const TIMETABLE = 'timetable';
DateFormat hiveIndexFormatter = DateFormat('y-MM-dd');

class TimetableWeekScreenState extends State<TimetableWeekScreen> {
  List<List<Lesson>> weekTimetable = [];
  List<Lesson?> listifiedTimetable = [];
  bool isLoading = true;
  bool _mounted = true;
  DateTime date = DateTime.now().add(Duration(days:-4));

  void cacheCheck(){
    if (_mounted && Hive.box(TIMETABLE).get(hiveIndexFormatter.format(date)) != null && Hive.box(TIMETABLE).get(hiveIndexFormatter.format(date)) is List<Lesson>) {
      print('Cache update');
      setState(() {
        final monday = date.subtract(Duration(days: date.weekday - 1));
        weekTimetable = [];
        for (var i = 0; i < 5; i++) {
          weekTimetable.add(Hive.box(TIMETABLE).get(hiveIndexFormatter.format(monday.add(Duration(days: i)))));
        }
        listifiedTimetable = listify(weekTimetable);
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

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                      cacheCheck();
                      TimetableHandler.fetchTimetable(date,context);
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
                          cacheCheck();
                          TimetableHandler.fetchTimetable(date,context);
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
                    cacheCheck();
                    TimetableHandler.fetchTimetable(date,context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        body: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! < 0) {
              setState(() {
                date = date.add(Duration(days: 7));
                isLoading = true;
              });
              TimetableHandler.fetchTimetable(date,context);
            } else if (details.primaryVelocity! > 0) {
              setState(() {
                date = date.subtract(Duration(days: 7));
                isLoading = true;
              });
              TimetableHandler.fetchTimetable(date,context);
            }
          }, 
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              scrollDirection: Axis.horizontal,
              crossAxisCount: 8,
              // TODO this needs to be fixed
              childAspectRatio: MediaQuery.of(context).size.height /
                  (MediaQuery.of(context).size.width) *
                10 /
                  24,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              children: [
                for (var i = 0; i < listifiedTimetable.length; i++)
                  LessonCardAbbrev(potentiallesson: listifiedTimetable[i]),
              ],
            ),
          ),
        ),
      );
    }
  }

  List<Lesson?> listify(List<dynamic> timetable) {
    List<Lesson?> listified = [];
    for (var day in timetable) {
      int len = 0;
      for (var lesson in day) {
        if (lesson.lessonTo.toString() == '-' ||
            lesson.lessonFrom.toString() == '-') {
          listified.add(lesson);
          len += 1;
          continue;
        }
        for (var i = 0;
            i <
                lesson.lessonTo -
                    lesson.lessonFrom +
                    1;
            i++) {
          listified.add(lesson);
          len += 1;
        }
      }
      for (var i = 0; i < 8 - len; i++) {
        listified.add(null);
      }
    }
    return listified;
  }

}

class TimetableWeekScreen extends StatefulWidget {
  @override
  TimetableWeekScreenState createState() => TimetableWeekScreenState();
}

class CurrentLessonCard extends StatelessWidget {
  final Lesson lesson;

  const CurrentLessonCard({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Column(
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
              child: LessonCardAbbrev(potentiallesson: lesson),
            ))
      ],
    );
  }
}

class LessonCardAbbrev extends StatelessWidget {
  final Lesson? potentiallesson;

  const LessonCardAbbrev({super.key, required this.potentiallesson});

  @override
  Widget build(BuildContext context) {
    if (potentiallesson == null ) {
      return Card(
        color: Theme.of(context).colorScheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        child: const SizedBox.shrink(),
      );
    }

    final lesson = potentiallesson as Lesson;
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        color: lesson.lessonType == 'ROZVRH' ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.tertiaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                lesson.lessonAbbrev.substring(
                  0,
                  lesson.lessonAbbrev.length > 4
                      ? 4
                      : lesson.lessonAbbrev.length,
                ),
                softWrap: true,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                lesson.classroomAbbrev
                    .replaceAll(RegExp(r'\([^()]*\)'), '')
                    .substring(
                      0, 
                      min<int>(
                        6, 
                        lesson.classroomAbbrev
                        .replaceAll(RegExp(r'\([^()]*\)'), '')
                        .length)),
                softWrap: true,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 0.5
                ),
              ),
              Text(
                lesson.teacherAbbrev,
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
