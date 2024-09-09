import 'package:flutter/material.dart';
import 'package:skola_offline/main.dart';
import 'package:skola_offline/timetable_day.dart';
import 'package:skola_offline/timetable_week.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TimetableScreenState extends State<TimetableScreen> {
  bool isDayScreen = true;

  setDayScreen() {
    setState(() {
      isDayScreen = true;
    });
  }

  setWeekScreen() {
    setState(() {
      isDayScreen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(MyApp.of(context)?.getDefaultToWeeklyTimetable() == true) setWeekScreen();
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.timetable),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: setDayScreen,
            color: isDayScreen ? Colors.white : Colors.grey,
          ),
          IconButton(
            icon: Icon(Icons.calendar_view_week),
            onPressed: setWeekScreen,
            color: isDayScreen ? Colors.grey : Colors.white,
          ),
        ],
      ),
      body: isDayScreen ? TimetableDayScreen() : TimetableWeekScreen(),
    );
    // return TimetableDayScreen();
    // return TimetableWeekScreen();
    // return Placeholder(child: Text('TimetableScreen'));
  }
}

class TimetableScreen extends StatefulWidget {
  @override
  TimetableScreenState createState() => TimetableScreenState();
}
