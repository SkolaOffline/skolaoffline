import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
import 'package:skola_offline/timetable.dart';
import 'package:skola_offline/marks.dart';
import 'package:skola_offline/messages.dart';
import 'package:skola_offline/profile.dart';
import 'package:skola_offline/absences.dart';

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

class AbsencesScreen extends StatefulWidget {
  @override
  AbsencesScreenState createState() => AbsencesScreenState();
}

class AbsencesScreenState extends State<AbsencesScreen> {
  List<dynamic> absencesSubjectList = [];
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
          absencesSubjectList = parseAbsences(absencesData);
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
    final absencesData = jsonDecode(jsonString);
    List<dynamic> absencesList = [];

    final absenceAllInAll = {
      'subjectName': 'Dohromady',
      'absences': absencesData['summaryAbsenceAll'],
      'percentage': absencesData['absenceAllPercentage'],
      'numberOfHours': absencesData['summaryNumberOfHours'],
      'excused': absencesData['summaryNumberOfExcused'],
      'unexcused': absencesData['summaryNumberOfUnexcused'],
      'notCounted': absencesData['summaryNumberOfNotCounted'],
      'allowedAbsences': -1,
      'allowedPercentage': -1,
    };
    absencesList.add(absenceAllInAll);

    for (var absence in absencesData['subjects']) {
      final absenceDict = {
      'subjectName': absence['subject']['name'],
      'absences': absence['absenceAll'],
      'percentage': absence['absenceAllPercentage'],
      'numberOfHours': absence['numberOfHours'],
      'excused': absence['numberOfExcused'],
      'unexcused': absence['numberOfUnexcused'],
      'notCounted': absence['numberOfNotCounted'],
      'allowedAbsences': absence['allowedAbsence'],
      'allowedPercentage': absence['allowedAbsencePercentage'],
      };
      absencesList.add(absenceDict);
    }

    return absencesList;
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
    final absenceHeader = {
      'subjectName': '',
      'absences': 'Abse',
      'percentage': '%',
      'numberOfHours': 'Hodin',
      'excused': 'Omluv',
      'unexcused': 'Neomluveno',
      'notCounted': 'Nezapočítáváno',
      'allowedAbsences': 'Povolone',
      'allowedPercentage': 'Povoleno'
    };

  if (absencesSubjectList.isEmpty) {
    return Scaffold(
      body: Center(child: 
      CircularProgressIndicator(),)
    );
  } else {
    return ListView(children: [
        AbsenceInSubjectCard(
          absence: absenceHeader,
          context: context
        ),
        for (var subject in absencesSubjectList)
        AbsenceInSubjectCard(absence: subject, context: context)
      ],);
    }
  }

  Future<String> downloadAbsences() async {
    final storage = FlutterSecureStorage();
    final accessToken = await storage.read(key: 'accessToken');

    final startPololeti = (DateTime.now().month >= 2 && DateTime.now().month <= 7) ? '2.' : '1';


    final params = {
      // TODO - pololeti
      'dateFrom': DateTime(DateTime.now().year-1, 9, 1).toIso8601String(),
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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,          
          children: [
          // SizedBox(width: 20,),
          SizedBox(
            width: 200,
            height: 30,
            child: Row(
              children: [
                SizedBox(width: 5,),
                Text(
                    absence['subjectName'].length > 25
                      ? absence['subjectName'].substring(0, 25) + '...'
                      : absence['subjectName'],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
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
          SizedBox(
            width: 50,
            child: Row(children: [
              Text(absence['numberOfHours'].toString()),
              Expanded(child: Container(),),
            ],),
          ),
          // SizedBox(
          //   width: 50,
          //   child: Row(children: [
          //     Text(absence['excused'].toString()),
          //     Expanded(child: Container()),
          //   ],),
          // )
          // atd
          // TODO - how to show it nicely
        
        
        ],),
      ),
    );
  }
}
