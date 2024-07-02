import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:skola_offline/timetable.dart';
import 'package:skola_offline/marks.dart';
import 'package:skola_offline/messages.dart';
import 'package:skola_offline/profile.dart';





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

  int _currentIndex = 3;

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
          NavigationDestination(icon: Icon(Icons.format_list_numbered), label: 'Marks'),
          NavigationDestination(icon: Icon(Icons.message), label: 'Messages'),
          NavigationDestination(icon: Icon(Icons.person_off), label: 'Absences'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class AbsencesScreen extends StatefulWidget {
  @override
  AbsencesScreenState createState() => AbsencesScreenState();
}

class AbsencesScreenState extends State<AbsencesScreen> {
  List<dynamic> absencesList = [];
  bool isLoading = true;
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _fetchAbsences();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> _fetchAbsences() async {
    try {
      final absencesData = await downloadAbsences();
      print(absencesData);
      if (_mounted) {
        setState(() {
          absencesList = parseAbsences(absencesData);
          isLoading = false;
        });
      }
    } catch (e) {
      print('error fetching timetable: $e');
      if (_mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  List<dynamic> parseAbsences(String jsonString) {
    return [jsonString];
  }

  // final absence = {
  //   'subjectName': 'subjectName',
  //   'absences': 123,
  //   'percentage': 0.2345,
  //   'numberOfHours': 234,
  //   'excused': 345,
  //   'unexcused': 456,
  //   'notCounted': 567,
  //   'allowedAbsences': 678,
  //   'allowedPercentage': 789, 


  @override
  Widget build(BuildContext context) {
    return Center(
      child: AbsenceInSubjectCard(absence: absence, context: context),
    );
  }

  Future<String> downloadAbsences() async {
    final storage = FlutterSecureStorage();
    final accessToken = await storage.read(key: 'accessToken');

    final params = {
      'dateFrom': DateTime(DateTime.now().year, 9, 1).toIso8601String(),
      'dateTo': DateTime(DateTime.now().year, 6, 31).toIso8601String(),
    };

    final url = Uri.parse(
      'https://aplikace.skolaonline.cz/solapi/api/v1/absences/inSubject',
    ).replace(queryParameters: params);

    final response = await http.get(
      url, 
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load timetable\n${response.statusCode}\n${response.body}');
    }
  }


  // ignore: non_constant_identifier_names
  Widget AbsenceInSubjectCard({required final absence, required final context}) {
    return Card(
      elevation: 5,
      child: Row(children: [
        SizedBox(
          width: 200,
          height: 80,
          child: Row(
            children: [
              Text(
                absence['subjectName'],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
              ),
              Expanded(
                child: Container(),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 50,
          child: Row(
            children: [
              Text(absence['absences'].toString()),
              Expanded(child: Container()),
            ],
          ),
        ),
        SizedBox(
          width: 50,
          child: Row(children: [
            Text(absence['percentage'].toString()),
            Expanded(child: Container(),),
          ],),
        ),
        Text('.....'),


      ],),
    );
  }
}
