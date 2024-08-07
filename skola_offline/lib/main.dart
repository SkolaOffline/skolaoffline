import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'package:skola_offline/absences.dart';
import 'package:skola_offline/app_settings.dart';
import 'package:skola_offline/login.dart';
import 'package:skola_offline/settings.dart';
import 'package:skola_offline/timetable.dart';
import 'package:skola_offline/marks.dart';
import 'package:skola_offline/messages.dart';
import 'package:skola_offline/profile.dart';

import 'package:skola_offline/api_cubit.dart';

Future<void> main() async {
  // final storage = FlutterSecureStorage();
  // storage.deleteAll();
  // TODO invalidate the access token
  // storage.write(key: 'accessToken', value: 'your_access_token_here');
  WidgetsFlutterBinding.ensureInitialized();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getTemporaryDirectory(),
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  AppSettings _appSettings = AppSettings();

  void setLocale(Locale value) {
    setState(() {
      _appSettings.language = value;
    });
  }

  Locale getLocale() {
    return _appSettings.language;
  }

  void setDarkMode(bool value) {
    setState(() {
      _appSettings.useDarkMode = value;
    });
  }

  bool getDarkMode() {
    return _appSettings.useDarkMode;
  }

  void setDummyMode(bool value) {
    setState(() {
      _appSettings.useDummyData = value;
    });
  }

  bool getDummyMode() {
    return _appSettings.useDummyData;
  }

  void setDarkMarks(bool value) {
    setState(() {
      _appSettings.darkMarks = value;
    });
  }

  bool getDarkMarks() {
    return _appSettings.darkMarks;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ApiCubit(),
      child: MaterialApp(
        title: 'Škola Offline',
        darkTheme: ThemeData.dark(
          useMaterial3: true,
        ),
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 47, 23, 89),
          ),
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: _appSettings.language,
        home: MyHomePage(),
      ),
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
    // ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Škola Offline',
              style: TextStyle(
                fontSize: 28,
                // fontFamily: 'SansSerif',
                fontWeight: FontWeight.bold,
              ),
            ),
            StreamBuilder(
                stream: Stream.periodic(const Duration(seconds: 1)),
                builder: (context, snapshot) {
                  return Text(
                    DateFormat('d.M H:mm:ss').format(DateTime
                        .now()), //TODO: For final releases I would personally remove seconds - Daalbu
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      // fontFamily: 'SansSerif',
                    ),
                  );
                }),
            Row(
              children: [
                Image(
                  image: AssetImage('lib/assets/skolaoffline_logo.png'),
                  height: 40,
                  // width: MediaQuery.of(context).size.width * 0.5,
                ),
                PopupMenuButton(
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: 'profile',
                      child: Row(
                        children: [
                          Icon(Icons.person),
                          SizedBox(width: 5),
                          Text(AppLocalizations.of(context)!.profile),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'settings',
                      child: Row(children: [
                        Icon(Icons.settings),
                        SizedBox(width: 5),
                        Text(AppLocalizations.of(context)!.settings),
                      ]),
                    )
                  ],
                  onSelected: (value) {
                    // Handle menu item selection
                    if (value == 'profile') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen()),
                      );
                    } else if (value == 'settings') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SettingsScreen()),
                      );
                    }
                  },
                )
              ],
            ),
          ],
        ),
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        elevation: 10,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
              icon: Icon(Icons.schedule),
              label: AppLocalizations.of(context)!.timetable),
          NavigationDestination(
              icon: Icon(Icons.format_list_numbered),
              label: AppLocalizations.of(context)!.marks),
          NavigationDestination(
              icon: Icon(Icons.message),
              label: AppLocalizations.of(context)!.messages),
          NavigationDestination(
              icon: Icon(Icons.person_off),
              label: AppLocalizations.of(context)!.absence),
          // NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
