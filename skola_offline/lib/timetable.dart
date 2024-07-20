import 'package:flutter/material.dart';
// import 'package:skola_offline/timetableDay.dart';
import 'package:skola_offline/timetableWeek.dart';

class TimetableScreenState extends State<TimetableScreen> {
  @override
  Widget build(BuildContext context) {
    // return TimetableDayScreen();
    return TimetableWeekScreen();
    // return Placeholder(child: Text('TimetableScreen'));
  }
}

class TimetableScreen extends StatefulWidget {
  @override
  TimetableScreenState createState() => TimetableScreenState();
}