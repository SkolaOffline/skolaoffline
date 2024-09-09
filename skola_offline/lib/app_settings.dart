import 'dart:convert';

import 'package:flutter/material.dart';

// ? Why is this a thing? 
class AppSettings {

  bool useDummyData=false;
  bool useDarkMode=true;
  Locale language=Locale('cs');
  bool darkMarks=false;
  bool defaultToWeeklyTimetable=false;

  AppSettings();

Map<String,dynamic> toJSON(){
      return {
  'useDummyData':useDummyData,
  'useDarkMode':useDarkMode,
  'language':language.languageCode,
  'darkMarks':darkMarks,
  'defaultToWeeklyTimetable':defaultToWeeklyTimetable

    };
    }
  AppSettings.fromJSON(Map<String, dynamic> json) {
  useDummyData =json['useDummyData'];
  useDarkMode =  json['useDarkMode'];
  language = Locale(json['language']);
  darkMarks = json['darkMarks'];
  defaultToWeeklyTimetable=json['defaultToWeeklyTimetable'];
  }
}