import 'package:flutter/material.dart';
import 'package:skola_offline/marksBySubject.dart';
import 'package:skola_offline/marksReport.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MarksScreenState extends State<MarksScreen> {
  bool isSubjectScreen = true;

  setSubjectScreen() {
    setState(() {
      isSubjectScreen = true;
    });
  }

  setReportScreen() {
    setState(() {
      isSubjectScreen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSubjectScreen ? Text("Marks By Subject") : Text("Reports"),
        actions: [
          IconButton(
            icon: Icon(Icons.subject),
            onPressed: setSubjectScreen,
            color: isSubjectScreen ? Colors.white : Colors.grey,
          ),
          IconButton(
            icon: Icon(Icons.summarize_outlined),
            onPressed: setReportScreen,
            color: isSubjectScreen ? Colors.grey : Colors.white,
          ),
        ],
      ),
      body: isSubjectScreen ? MarksBySubjectScreen() : MarksReportScreen(),
    );
    // return TimetableSubjectScreen();
    // return TimetableWeekScreen();
    // return Placeholder(child: Text('TimetableScreen'));
  }
}

class MarksScreen extends StatefulWidget {
  @override
  MarksScreenState createState() => MarksScreenState();
}
