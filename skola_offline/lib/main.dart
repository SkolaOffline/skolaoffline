// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // test login

  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Škola Offline',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {

  int _currentIndex = 0;

  final List<Widget> _tabs = [
    TimetableScreen(),
    MarksScreen(),
    MessagesScreen(),
    AbsencesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Škola Offline'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Add this line
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Timetable',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_numbered_outlined),
            label: 'Marks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mark_as_unread),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_off),
            label: 'Absences',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class TimetableScreen extends StatefulWidget {
  @override
  TimetableScreenState createState() => TimetableScreenState();

  // @override
  // Widget build(BuildContext context) {
  //   // Add your widget tree here
  //   return Container();
  // }
  // TimetableScreenState createState() => TimetableScreenState();
}

class TimetableScreenState extends State<TimetableScreen> {
  String responseText = 'Loading...';
  List<dynamic> weekTimetable = []; // Define weekTimetable variable
  @override
  void initState() {
    super.initState();
    downloadTimetable().then((value) {
      setState(() {
        weekTimetable = parseWeekTimtable(value); // Assign value to weekTimetable
        responseText = 'Loaded';
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Text(
          'timetable',
          style: Theme.of(context).textTheme.displayMedium!.copyWith(
            // color: Theme.of(context).colorScheme.onPrimary
          ),
          ),
        timeTable(weekTimetable: weekTimetable),
     ],)
    );
  } 

  Widget timeTable({required List<dynamic> weekTimetable}) {
    if (weekTimetable.isEmpty) {
        return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // CircularProgressIndicator(),
          // SizedBox(width: 10,),
          Text('Loading...'),
        ],
        );
    } else {
      return Column(
        children: [
          for (var lesson in weekTimetable[0])
            // Text('${lesson['lessonAbbrev']} ${lesson['classroomAbbrev']} ${lesson['teacherAbbrev']}'),
            Column(
              children: [
                LessonOnTimetable(
                  abbrev: lesson['lessonAbbrev'],
                  classroom: lesson['classroomAbbrev'],
                  teacher: lesson['teacherAbbrev'],
                  lesson: lesson),
                SizedBox(height:20),
              ],
            ),
            
        ],
      );
    }
  }

  // ignore: non_constant_identifier_names
  Widget LessonOnTimetable({final abbrev, final classroom, final teacher, final lesson}) {
    return Row(children: [
      Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              lesson['lessonOrder'].toString(),
              style: TextStyle(fontSize: 25),
            ),
            Text(
              formatDate(lesson['beginTime'] ?? 'error'),
              style: TextStyle(fontSize: 13),
            ),
            Text(
              formatDate(lesson['endTime'] ?? 'error'),
              style: TextStyle(fontSize: 13),
            ),
        ],
        ),
      ),
      SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            abbrev,
            style: TextStyle(fontSize: 20),
          ),
          Text(
            classroom,
            style: TextStyle(fontSize: 15),
          ),
          Text(
            teacher,
            style: TextStyle(fontSize: 15),
          ),
        ],
      ),
    ],
    );
  }

  Future<String> downloadTimetable() async {
    final storage = FlutterSecureStorage();
    
    final userId = await storage.read(key: 'userId');
    final syID = await storage.read(key: 'schoolYearId');
    final accessToken = await storage.read(key: 'accessToken');


    final params = {
      'studentId': userId,
      // todo - not hardcoded
      'dateFrom': '2024-06-03T00:00:00.000',
      'dateTo': '2024-06-08T00:00:00.000',
      'schoolYearId': syID
    };

    final url = Uri.parse("https://aplikace.skolaonline.cz/solapi/api/v1/timeTable").replace(queryParameters: params);
   
    final response = await http.get(
      url, 
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('timeTable response: ${response.statusCode}');
    // todo - refresh token when expired
    return response.statusCode == 200 ? response.body : 'Error: ${response.statusCode}';
  }

  List<dynamic> parseWeekTimtable(String json) {
    Map<String, dynamic> data = jsonDecode(json);
    List<dynamic> timetable = [];

    final monday = parseDayTimetable(data['days'][0]);
    final tuesday = parseDayTimetable(data['days'][1]);
    final wednesday = parseDayTimetable(data['days'][2]);
    final thursday = parseDayTimetable(data['days'][3]);
    final friday = parseDayTimetable(data['days'][4]);

    timetable.add(monday);
    timetable.add(tuesday);
    timetable.add(wednesday);
    timetable.add(thursday);
    timetable.add(friday);

    return timetable;
  }

  String formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    String formatedDate = '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    print(formatedDate);
    return formatedDate;
  }

  List<dynamic> parseDayTimetable(Map<String, dynamic> day) {
    List<dynamic> lessons = [];
    for (var lesson in day['schedules']) {
      if (lesson['hourType']['id'] == 'SKOLNI_AKCE' ||
        lesson['hourType']['id'] == 'SUPLOVANA') {
        continue;
      }
      var less = {
        'lessonFrom': lesson['lessonIdFrom'],
        'lessonTo': lesson['lessonIdTo'],
        'lessonType': lesson['hourType']['id'],
        'lessonAbbrev': lesson['subject']['abbrev'],
        'classroomAbbrev': lesson['rooms'][0]['abbrev'],
        'teacherAbbrev': lesson['teachers'][0]['abbrev'],
        'lessonOrder': lesson['detailHours'][0]['order'],
        'beginTime': lesson['beginTime'],
        'endTime': lesson['endTime'],
      };
      lessons.add(less);
    }
    return lessons;
  }
}


class MarksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Marks Screen'),
    );
  }
}

class MessagesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Message Screen'),
    );
  }
}

class AbsencesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Absences Screen'),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  TextEditingController _usernameController = TextEditingController(); // Add this line
  TextEditingController _passwordController = TextEditingController(); // Add this line

  Future<void> login(username, password) async {
    showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
    return Dialog(
      child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        CircularProgressIndicator(),
        SizedBox(height: 16.0),
        Text('Logging in...'),
        ],
      ),
      ),
    );
    },
    );


    final storage = FlutterSecureStorage();
    await storage.write(key: 'username', value: username);
    await storage.write(key: 'password', value: password);
 
    final response = await http.post(
      Uri.parse('https://aplikace.skolaonline.cz/solapi/api/connect/token'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: <String, String>{
        'grant_type': 'password',
        'username': username,
        'password': password,
        'client_id': 'test_client',
        'scope': 'openid offline_access profile sol_api',
      },
    );

    Navigator.of(context).pop();

    if (response.statusCode == 400) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Wrong credentials'),
            content: Text('Please check your username and password.'),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }
    if (response.statusCode != 200) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(response.body),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    } else {
      showDialog(context: context, builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('You have been logged in.'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      });
    }


    Map<String, dynamic> data = json.decode(response.body);
    String accessToken = data['access_token'];
    // print('expires in: ${data['expires_in']}');
    String refreshToken = data['refresh_token'];

    await storage.write(key: 'accessToken', value: accessToken);
    await storage.write(key: 'refreshToken', value: refreshToken);

    //get user data
    final userResponse = await http.get(
      Uri.parse("https://aplikace.skolaonline.cz/solapi/api/v1/user"),
      headers: {
        'Authorization': 'Bearer $accessToken'
      }
    );
    
    Map<String, dynamic> jsonResponse = json.decode(userResponse.body) as Map<String, dynamic>;

    await storage.write(key: 'userId', value: jsonResponse['personID']);
    await storage.write(key: 'schoolYearId', value: jsonResponse['schoolYearId']);
  }


  // Future<void> logout() async {
    // final storage = FlutterSecureStorage();

    // final response = await http.post(
    //   Uri.parse('https://aplikace.skolaonline.cz/solapi/api/v1/user/logout'),
    //   headers: {
    //     "Authorization": "Bearer ${await storage.read(key: 'accessToken')}",
    //   },
    // );

    // if (response.statusCode != 200) {
    //   showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         title: Text('Error'),
    //         content: Row(children: [
    //           Text('Error logging out: '),
    //           Text(response.statusCode.toString()),
    //           Text(response.body),
    //         ],),
    //         backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    //         actions: [
    //           TextButton(
    //             onPressed: () {
    //               Navigator.of(context).pop();
    //             },
    //             child: Text('OK'),
    //           ),
    //         ],
    //       );
    //     },
    //   );
    // }
    // else {
    //   await storage.deleteAll();
    //   showDialog(context: context, builder: (BuildContext context) {
    //     return AlertDialog(
    //       title: Text('Logout'),
    //       content: Text('You have been logged out.'),
    //       backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    //       actions: [
    //         TextButton(
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //           },
    //           child: Text('OK'),
    //         ),
    //       ],
    //     );
    //   });
    // }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('John Doe'),
                  ],
                ),
              ],
            ),
            TextField(
              controller: _usernameController, // Add this line
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            TextField(
              controller: _passwordController, // Add this line
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            SizedBox(height: 20,),
            ElevatedButton(
                onPressed: () async {
                String username = _usernameController.text;
                String password = _passwordController.text;
                await login(username, password);
              },

              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.login),
                    Text('Login (takes ~5 seconds)'),
                  ],
                ),
              ),
            ),
            // SizedBox(height: 15,),
            // ElevatedButton(
            //   onPressed: () {
            //     logout();
            //   }, 
            //   child: Padding(
            //     padding: const EdgeInsets.all(12.0),
            //     child: Row(
            //       children: [
            //         Icon(Icons.logout),
            //         Text('Logout'),
            //       ],
            //     ),
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}