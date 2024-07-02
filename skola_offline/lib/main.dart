import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_html/flutter_html.dart';





void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Škola Offline',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(icon: Icon(Icons.schedule), label: 'Timetable'),
          NavigationDestination(
              icon: Icon(Icons.format_list_numbered), label: 'Marks'),
          NavigationDestination(icon: Icon(Icons.message), label: 'Messages'),
          NavigationDestination(
              icon: Icon(Icons.person_off), label: 'Absences'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class TimetableScreen extends StatefulWidget {
  @override
  TimetableScreenState createState() => TimetableScreenState();
}

// todo test
Future<void> refreshToken() async {
  final storage = FlutterSecureStorage();
  // refresh token
  final refreshToken = await storage.read(key: 'refreshToken');
  final r = await http.post(
    Uri.parse('https://aplikace.skolaonline.cz/solapi/api/connect/token'),
    headers: {"Content-Type": "application/x-www-form-urlencoded"},
    body: {
        "grant_type": "refresh_token",
        "refresh_token": refreshToken,
        "client_id": "test_client",
        "scope": "offline_access sol_api",
    },
  );
  print('refresh response: ${r.statusCode}');
}


class TimetableScreenState extends State<TimetableScreen> {
  List<dynamic> weekTimetable = [];
  bool isLoading = true;
  bool _mounted = true;
  DateTime now = DateTime(2024,6,3,12,00,03);

  @override
  void initState() {
    super.initState();
    _fetchTimetable();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> _fetchTimetable() async {
    try {
      final timetableData = await downloadTimetable(now);
      if (_mounted) {
        setState(() {
          weekTimetable = parseWeekTimetable(timetableData);
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

  @override
  Widget build(BuildContext context) {
    final date_formatter = DateFormat('y-MM-ddTHH:mm:ss');

    var current_lesson_index = -1;


    if(!isLoading){
      for(var i=weekTimetable[now.weekday-1].length-1;i>=0; i--){
      if(now.isBefore(date_formatter.parse(weekTimetable[now.weekday-1][i]['endTime']))  ){
          current_lesson_index=i;
      }
    }
    }
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchTimetable,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: isLoading ? Center(child: CircularProgressIndicator()) : (current_lesson_index ==-1 ?Center(child:Text('There are no lessons left for today')) : CurrentLessonCard(lesson: weekTimetable[now.weekday-1][current_lesson_index]))
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Rozvrh hodin',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
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
                        final lesson = weekTimetable[now.weekday-1][index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: LessonCard(lesson: lesson),
                        );
                      },
                      childCount:
                          weekTimetable.isEmpty ? 0 : weekTimetable[now.weekday-1].length,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<String> downloadTimetable(DateTime dateTime) async {
    final storage = FlutterSecureStorage();
    final userId = await storage.read(key: 'userId');
    final syID = await storage.read(key: 'schoolYearId');
    final accessToken = await storage.read(key: 'accessToken');

      DateTime getMidnight(DateTime datetime){
      return DateTime(datetime.year,datetime.month,datetime.day);
    }

    final monday = getMidnight(dateTime.subtract(Duration(days: dateTime.weekday - 1)));
    final friday = getMidnight(monday.add(Duration(days: 5)));

    final date_formatter = DateFormat('y-MM-ddTHH:mm:ss.000');

    final params = {
      'studentId': userId,
      'dateFrom': date_formatter.format(monday),
      'dateTo': date_formatter.format(friday),
      'schoolYearId': syID
    };

    final url =
        Uri.parse("https://aplikace.skolaonline.cz/solapi/api/v1/timeTable")
            .replace(queryParameters: params);

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load timetable');
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
              'beginTime': lesson['beginTime'],
              'endTime': lesson['endTime'],
            })
        .toList();
  }
}

class CurrentLessonCard extends StatelessWidget {

  final Map<String, dynamic> lesson;

  const CurrentLessonCard({Key? key, required this.lesson}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Lesson',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            LessonCard(lesson: lesson)
          ],
        ),
      ),
    );
  }
}

class LessonCard extends StatelessWidget {
  final Map<String, dynamic> lesson;

  const LessonCard({Key? key, required this.lesson}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return 
    Card(
      elevation: 2,
      child: 
      Padding(
        padding: EdgeInsets.all(8),
        child: 
        Row(
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
                    lesson['lessonOrder'].toString(),
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
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${lesson['lessonAbbrev']} - ${lesson['lessonName']}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
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

class MarksScreen extends StatefulWidget {
  @override
  MarksScreenState createState() => MarksScreenState();
}

class MarksScreenState extends State<MarksScreen> {
  List<dynamic> subjects = [];
  bool isLoading = true;
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _fetchMarks();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> _fetchMarks() async {
    try {
      final storage = FlutterSecureStorage();
      final userId = await storage.read(key: 'userId');
      final accessToken = await storage.read(key: 'accessToken');

      final url = Uri.parse(
          "https://aplikace.skolaonline.cz/solapi/api/v1/students/$userId/marks/bySubject");

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        if (_mounted) {
          setState(() {
            subjects = json.decode(response.body)['subjects'];
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load marks');
      }
    } catch (e) {
      print('Error fetching marks: $e');
      if (_mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchMarks,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return SubjectCard(subject: subject);
                },
              ),
      ),
    );
  }
}

class SubjectCard extends StatelessWidget {
  final Map<String, dynamic> subject;

  const SubjectCard({Key? key, required this.subject}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: ExpansionTile(
        title: Text(
          subject['subject']['name'],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: RichText(
            text: TextSpan(
                text: 'Average: ', // Normal text
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
              TextSpan(
                text: '${subject['averageText']}', // Bold text
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  ),
              )
            ])),
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: subject['marks'].length,
            itemBuilder: (context, index) {
              final mark = subject['marks'][index];
              return Column(
                children: [
                  ListTile(
                    title: Text(
                      mark['theme'].substring(0, 1).toUpperCase() + mark['theme'].substring(1),
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    // subtitle: Text('Date: ${mark['markDate'].split('T')[0]}'),
                    subtitle: Text(formatDateToDate(mark['markDate']), style: TextStyle(fontSize: 12)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 6.0,
                              right:
                                  6.0), // Adds 16 pixels of padding on the left and 32 pixels on the right
                          // child: Text('Weight: ${mark['weight']}',
                          child: Text('${(mark['weight']*10).toInt()}',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300)),
                        ),
                        SizedBox(width: 8),
                        Container(
                          width: 30,
                          height: 40,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getMarkColor(mark['markText']),
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 6,
                                offset: Offset(4, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              mark['markText'],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () =>
                        _showMarkDetails(context, mark, subject['teachers']),
                  ),
                  Divider(height: 0,),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getMarkColor(String mark) {
    switch (mark) {
      case '1':
        return Colors.green;
      case '2':
        return Colors.lightGreen;
      case '3':
        return Colors.yellow;
      case '4':
        return Colors.orange;
      case '5':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }


  String formatDateToDate(String date) {
    // final dateFormatter = DateFormat('y-MM-ddTHH:mm:ss.000');
    final dateFormatter = DateFormat('dd.MM.yyyy');
    return dateFormatter.format(DateTime.parse(date));
  }



  void _showMarkDetails(
      BuildContext context, Map<String, dynamic> mark, List<dynamic> teachers) {
    String teacherName = 'Unknown';
    for (var teacher in teachers) {
      if (teacher['id'] == mark['teacherId']) {
        teacherName = teacher['displayName'];
        break;
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(mark['theme']),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // Text('Date: ${mark['markDate'].split('T')[0]}'),
                Text('Date: ${formatDateToDate(mark['markDate'])}'),
                Text('Mark: ${mark['markText']}'),
                Text('Weight: ${mark['weight']}'),
                // Text('Type: ${mark['type']}'),
                if (mark['typeNote'] != null)
                  Text('Type Note: ${mark['typeNote']}'),
                if (mark['comment'] != null)
                  Text('Comment: ${mark['comment']}'),
                if (mark['verbalEvaluation'] != null)
                  Text('Verbal Evaluation: ${mark['verbalEvaluation']}'),
                Text('Teacher: $teacherName'),
                if (mark['classRankText'] != null)
                  Text('Class Rank: ${mark['classRankText']}'),
                if (mark['classAverage'] != null)
                  Text('Class Average: ${mark['classAverage']}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class MessagesScreen extends StatefulWidget {
  @override
  MessagesScreenState createState() => MessagesScreenState();
}

class MessagesScreenState extends State<MessagesScreen> {
  List<dynamic> messageList = [];

  @override
  void initState() {
    super.initState();
    downloadMessages().then((value) {
      setState(() {
        messageList = parseMessages(value);
      });
    });
  }

  Future<String> downloadMessages() async {
    final storage = FlutterSecureStorage();
    final accessToken = await storage.read(key: 'accessToken');

    final params = { 
      // TODO - not hardcoded
      'dateFrom': '2024-04-01T00:00:00.000',
      'dateTo': '2024-08-01T00:00:00.000',
    };

    final url = 
      Uri.parse('https://aplikace.skolaonline.cz/solapi/api/v1/messages/received')
      .replace(queryParameters: params);

    final response = await http.get(
      url, 
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      // print(response.body);
      return response.body;
    } else {
      // TODO - handle exceptions
      throw Exception('Failed to load messages\n${response.statusCode}\n${response.body}');
    }
  }

  List<dynamic> parseMessages(String jsonString) {
    Map<String, dynamic> jsn = jsonDecode(jsonString);
    List<dynamic> messageJsn = jsn['messages'];
    var messages = [];

    for (var message in messageJsn) {
      var messg = {
        'sentDate': message['sentDate'],
        'read': message['read'],
        'sender': message['sender']['name'],
        'attachments': message['attachemnts'].toString(),
        'title': message['title'],
        'text': 
        message['text']
          // parse(message['text'])
          // .outerHtml
          // .replaceAll(RegExp(r''), '')
          ,
        'id': message['id'],
      };
      messages.add(messg);
    }

    return messages;
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: ListView(children: [
        // Text(
          // 'Zprávy',
          // style: Theme.of(context).textTheme.displayMedium!.copyWith(),
          // ),
        body: Messages(messageList: messageList, context: context)
      // ],)
    );
 }

  String formatDateToDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    //TODO: USE DateFormat - better build-in version of the same thing
    String formatedDate = '${dateTime.day}. ${dateTime.month}. ${dateTime.year}';
    // print(formatedDate);
    return formatedDate;
  }

  // ignore: non_constant_identifier_names
  Widget Messages({required List<dynamic> messageList, required BuildContext context}) {
    if (messageList.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 10,),
                Text('Loading...'),
              ],
              ),
            ],
          );
    } else {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(children: [
          for (var message in messageList)
          MessageWidget(
            title: message['title'], 
            content: message['text'], 
            context: context,
            from: message['sender'],
            date: message['sentDate'],
            message: message
            ),
        ],),
      )
    );
    }
  }
 
  // ignore: non_constant_identifier_names
  Widget MessageWidget({
    required String title, 
    required String content, 
    required BuildContext context, 
    required String from,
    required String date,
    required final message,
    }) {
    return Column(
      children: [
        Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  // TODO - fix, so it doesn't depend on the length of the title
                  // because this is embarassing
                    title.length > 25 ? title.substring(0, 25) + '...' : title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      from,),
                    Text(
                      formatDateToDate(date),)
                  ],
                )
              ],
            ),

            // Text(content),
            // HtmlWidget(
            //   content
            // )
            Html(
              data: content,
              style: {
                'p': Style(
                  fontSize: FontSize(16),
                ),
              },
            ),
          ],
        ),
      ),
      ),
      SizedBox(height: 15,),
      ],
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
// Implement other screen classes (MarksScreen, MessagesScreen, AbsencesScreen) similarly

class ProfileScreen extends StatefulWidget {
  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> login(String username, String password) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Logging in...'),
            ],
          ),
        );
      },
    );

    final storage = FlutterSecureStorage();
    await storage.write(key: 'username', value: username);
    await storage.write(key: 'password', value: password);

    try {
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

      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(); // Close the loading dialog

      if (response.statusCode == 400) {
        _showErrorDialog(
            'Wrong credentials', 'Please check your username and password.');
        return;
      }

      if (response.statusCode != 200) {
        _showErrorDialog('Error', 'An error occurred while logging in.');
        return;
      }

      Map<String, dynamic> data = json.decode(response.body);
      String accessToken = data['access_token'];
      String refreshToken = data['refresh_token'];

      await storage.write(key: 'accessToken', value: accessToken);
      await storage.write(key: 'refreshToken', value: refreshToken);

      // Get user data
      final userResponse = await http.get(
        Uri.parse("https://aplikace.skolaonline.cz/solapi/api/v1/user"),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      Map<String, dynamic> jsonResponse = json.decode(userResponse.body);

      await storage.write(key: 'userId', value: jsonResponse['personID']);
      await storage.write(
          key: 'schoolYearId', value: jsonResponse['schoolYearId']);

      _showSuccessDialog('Success', 'You have been logged in.');
    } catch (e) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(); // Close the loading dialog
      _showErrorDialog('Error', 'An unexpected error occurred: $e');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                String username = _usernameController.text;
                String password = _passwordController.text;
                await login(username, password);
              },
              icon: Icon(Icons.login),
              label: Text('Login'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
