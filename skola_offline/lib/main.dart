import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

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

class TimetableScreenState extends State<TimetableScreen> {
  List<dynamic> weekTimetable = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTimetable();
  }

  Future<void> _fetchTimetable() async {
    try {
      final timetableData = await downloadTimetable();
      setState(() {
        weekTimetable = parseWeekTimetable(timetableData);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching timetable: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchTimetable,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CurrentLessonCard(),
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
                        final lesson = weekTimetable[0][index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: LessonCard(lesson: lesson),
                        );
                      },
                      childCount:
                          weekTimetable.isEmpty ? 0 : weekTimetable[0].length,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<String> downloadTimetable() async {
    final storage = FlutterSecureStorage();
    final userId = await storage.read(key: 'userId');
    final syID = await storage.read(key: 'schoolYearId');
    final accessToken = await storage.read(key: 'accessToken');

    //TODO - change dateFrom and dateTo to monday and friday
    // final now = DateTime.now();
    // final monday = now.subtract(Duration(days: now.weekday - 1));
    // final friday = monday.add(Duration(days: 5));

    final params = {
      'studentId': userId,
      //TODO - change dateFrom and dateTo to monday and friday
      'dateFrom': '2024-06-03T00:00:00.000',
      'dateTo': '2024-06-08T00:00:00.000',
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
            Text(
              'To be implemented',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
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
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
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
                    style: TextStyle(fontSize: 12),
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
                    'Room: ${lesson['classroomAbbrev']}',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Teacher: ${lesson['teacher']}',
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
  _MarksScreenState createState() => _MarksScreenState();
}

class _MarksScreenState extends State<MarksScreen> {
  List<dynamic> subjects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMarks();
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
        setState(() {
          subjects = json.decode(response.body)['subjects'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load marks');
      }
    } catch (e) {
      print('Error fetching marks: $e');
      setState(() {
        isLoading = false;
      });
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
        subtitle: Text('Average: ${subject['averageText']}'),
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: subject['marks'].length,
            itemBuilder: (context, index) {
              final mark = subject['marks'][index];
              return ListTile(
                title: Text(mark['theme']),
                subtitle: Text('Date: ${mark['markDate'].split('T')[0]}'),
                trailing: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getMarkColor(mark['markText']),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    mark['markText'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
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
