import 'package:flutter/material.dart';
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

class AbsencesScreen extends StatelessWidget {
  var absence = {
    'subjectName': 'subjectName',
    'absences': 123,
    'percentage': 0.2345,
    'numberOfHours': 234,
    'excused': 345,
    'unexcused': 456,
    'notCounted': 567,
    'allowedAbsences': 678,
    'allowedPercentage': 789, 
  };

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AbsenceInSubjectCard(absence: absence, context: context),
    );
  }


  // ignore: non_constant_identifier_names
  Widget AbsenceInSubjectCard({required final absence, required final context}) {
    return Card(
      elevation: 4,
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
        Text(absence['absences'].toString())

      ],),
    );
  }
}
