import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:skola_offline/dummy_app_state.dart';
import 'package:skola_offline/main.dart';
// import 'package:skola_offline/main.dart';

// ! TOTALLY NOT WORKING

class TimetableWeekScreenState extends State<TimetableWeekScreen> {
  List<dynamic> weekTimetable = [];
  bool isLoading = true;
  bool _mounted = true;
  DateTime now = DateTime(2024, 6, 3, 12, 00, 03);

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

  Future<void> _fetchTimetableWeek() async {
    try {
      final timetableData = await downloadTimetableWeek(now);
      // print(timetableData);
      if (_mounted) {
        setState(() {
          weekTimetable = parseWeekTimetable(timetableData);
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching timetable: $e');
      // if (_mounted) {
      //   setState(() {
      //     isLoading = false;
      //   });
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('y-MM-ddTHH:mm:ss');

    var currentLessonIndex = -1;

    // print(isLoading);

    if (!isLoading) {
      for (var i = weekTimetable[now.weekday - 1].length - 1; i >= 0; i--) {
        if (now.isBefore(dateFormatter
            .parse(weekTimetable[now.weekday - 1][i]['endTime']))) {
          currentLessonIndex = i;
        }
      }
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchTimetableWeek,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : (currentLessonIndex == -1
                          ? Center(
                              child:
                                  Text('There are no lessons left for today'))
                          : CurrentLessonCard(
                              lesson: weekTimetable[now.weekday - 1]
                                  [currentLessonIndex]))),
            ),
            // SliverToBoxAdapter(
            //     child: SizedBox(
            //   height: 10,
            // )),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rozvrh hodin',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    IconButton(
                      icon: Icon(Icons.date_range),
                      onPressed: () {
                        showDatePicker(context: context, firstDate: DateTime(0), lastDate: DateTime(9999), initialDate: now).then((value) {
                          if (value != null) {
                            setState(() {
                              now = value;
                              isLoading = true;
                            });
                            _fetchTimetableWeek();
                          }
                        });
                      },
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
                        final lesson = weekTimetable[now.weekday - 1][index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 0.0),
                          child: LessonCard(lesson: lesson),
                        );
                      },
                      childCount: weekTimetable.isEmpty
                          ? 0
                          : weekTimetable[now.weekday - 1].length,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<String> downloadTimetable(DateTime whichDay) async {
    final dummyAppState = DummyAppState();
    bool useDummyData = dummyAppState.useDummyData;

    if (useDummyData) {
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
        // Uri.parse("https://aplikace.skolaonline.cz/solapi/api/v1/timeTable")
            // .replace(queryParameters: params);

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
    final dummyAppState = DummyAppState();
    bool useDummyData = dummyAppState.useDummyData;

    if (useDummyData) {
      String dummyData = 
        await rootBundle.loadString('lib/assets/dummy_timetable.json');
        return dummyData;
    } else {
      final storage = FlutterSecureStorage();
      final userId = await storage.read(key: 'userId');
      final syID = await storage.read(key: 'schoolYearId');
      // final accessToken = await storage.read(key: 'accessToken');

      DateTime getMidnight(DateTime datetime) {
        return DateTime(datetime.year, datetime.month, datetime.day);
      }

      final monday =
          getMidnight(dateTime.subtract(Duration(days: dateTime.weekday - 1)));
      final friday = getMidnight(monday.add(Duration(days: 5)));

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
          // Uri.parse("https://aplikace.skolaonline.cz/solapi/api/v1/timeTable")
              // .replace(queryParameters: params);

      // final response = await http.get(
      //   url,
      //   headers: {'Authorization': 'Bearer $accessToken'},
      // );

      final response = await makeRequest(
        url,
        params,
        // ignore: use_build_context_synchronously
        context,
        );

      if (response.statusCode == 200) {
        return response.body;
      // } else if (response.statusCode == 401) {
      //   await refreshToken();
      //   return downloadTimetable(dateTime);
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

class TimetableScreen extends StatefulWidget {
  @override
  TimetableScreenState createState() => TimetableScreenState();
}

// Future<void> refreshToken() async {
//   final storage = FlutterSecureStorage();
  // refresh token
//   final refreshToken = await storage.read(key: 'refreshToken');
//   final r = await http.post(
//     Uri.parse('https://aplikace.skolaonline.cz/solapi/api/connect/token'),
//     headers: {"Content-Type": "application/x-www-form-urlencoded"},
//     body: {
//       "grant_type": "refresh_token",
//       "refresh_token": refreshToken,
//       "client_id": "test_client",
//       "scope": "offline_access sol_api",
//     },
//   );
  // print(r.body);
//   print('refresh response: ${r.statusCode}');

//   if (r.statusCode == 200) {
//     final accessToken = jsonDecode(r.body)['access_token'];
//     final newRefreshToken = jsonDecode(r.body)['refresh_token'];
//     await storage.write(key: 'accessToken', value: accessToken);
//     await storage.write(key: 'refreshToken', value: newRefreshToken);

//     print('refreshed token');
//   } else if (r.statusCode == 400) {
//     await storage.delete(key: 'accessToken');
//     await storage.delete(key: 'refreshToken');
//     print('deleted token');

//     final response = await http.post(
//       Uri.parse('https://aplikace.skolaonline.cz/solapi/api/connect/token'),
//       headers: {"Content-Type": "application/x-www-form-urlencoded"},
//       body: {
//         "grant_type": "password",
//         "username": await storage.read(key: 'username'),
//         "password": await storage.read(key: 'password'),
//         "client_id": "test_client",
//         "scope": "openid offline_access profile sol_api",
//       },
//     );

//     if (response.statusCode == 200) {
//       final accessToken = jsonDecode(response.body)['access_token'];
//       final refreshToken = jsonDecode(response.body)['refresh_token'];
//       await storage.write(key: 'accessToken', value: accessToken);
//       await storage.write(key: 'refreshToken', value: refreshToken);
//     } else {
//       throw Exception('Failed to login again after token refresh');
//     }
//   } else {
//     throw Exception('Failed to refresh token');
//   }


//   throw Exception('too lazy to implement');
//   // exit(1);
// }

class CurrentLessonCard extends StatelessWidget {
  final Map<String, dynamic> lesson;

  const CurrentLessonCard({Key? key, required this.lesson}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Lesson',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          // SizedBox(height: 8),
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
                child: LessonCard(lesson: lesson),
              ))
        ],
      ),
    );
  }
}

class LessonCard extends StatelessWidget {
  final Map<String, dynamic> lesson;

  const LessonCard({Key? key, required this.lesson}) : super(key: key);
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
                    // lesson['lessonOrder'].toString(),
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
