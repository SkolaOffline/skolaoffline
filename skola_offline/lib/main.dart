import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:skola_offline/absences.dart';
import 'package:skola_offline/app_settings.dart';
import 'package:skola_offline/login.dart';
import 'package:skola_offline/settings.dart';
import 'package:skola_offline/timetable.dart';
import 'package:skola_offline/marks.dart';
import 'package:skola_offline/messages.dart';
import 'package:skola_offline/profile.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // final storage = FlutterSecureStorage();
  // storage.deleteAll();
  // TODO invalidate the access token
  // storage.write(key: 'accessToken', value: 'your_access_token_here');

  runApp(MyApp());
}

Future<http.Response> makeRequest(
  String rawUrl,
  Map<String, dynamic>? params,
  BuildContext context,
) async {
  // TODO - we could cache the requests...
  // but it would be SO much work

  var url = Uri.parse('https://aplikace.skolaonline.cz/solapi/$rawUrl');
  if (params != null) {
    url = url.replace(queryParameters: params);
  }

  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'accessToken');

  print('starting request to $rawUrl');
  final startTime = DateTime.now();
  final response = await http.get(
    url,
    headers: {'Authorization': 'Bearer $accessToken'},
  );
  final endTime = DateTime.now();
  final duration = endTime.difference(startTime);
  print('request took ${duration.inMilliseconds} milliseconds');
  print('ending request');

  print('response is ${response.statusCode}');

  if (response.statusCode == 200) {
    return response;
  } else if (response.statusCode == 401 && accessToken != null) {
    // trying to refresh token
    print('refreshing token...');
    final refreshToken = await storage.read(key: 'refreshToken');

    print('starting refresh request');
    final resp = await http.post(
      Uri.parse('https://aplikace.skolaonline.cz/solapi/api/connect/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
        'client_id': 'test_client',
        'scope': 'offline_access sol_api',
      },
    );
    print('ending refresh request');

    print('refresh response is ${resp.statusCode}');

    // if successful, save the new tokens and retry the request
    if (resp.statusCode == 200) {
      final jsn = jsonDecode(resp.body);
      final accessToken = jsn['access_token'];
      final refreshToken = jsn['refresh_token'];

      await storage.write(key: 'accessToken', value: accessToken);
      await storage.write(key: 'refreshToken', value: refreshToken);

      print('starting request after refresh');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      print('ending request after refresh');

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception('failed to load data after refresh token');
      }
    } else {
      throw Exception('Failed to refresh token');
    }
  } else {
    Navigator.push(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
    throw Exception('Failed to load data');
  }
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
    return MaterialApp(
      title: 'Škola Offline',
      // TODO - dark theme + theme changing
      darkTheme: ThemeData.dark(
        useMaterial3: true,
        // colorScheme: ColorScheme.fromSeed(
        //   seedColor: Colors.deepPurple,
        // ),
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
