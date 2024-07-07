import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:skola_offline/timetable.dart';
import 'package:skola_offline/marks.dart';
import 'package:skola_offline/messages.dart';
import 'package:skola_offline/profile.dart';
import 'package:skola_offline/absences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = FlutterSecureStorage();
  // TODO invalidate the access token
  storage.write(key: 'accessToken', value: 'your_access_token_here');

  runApp(MyApp());
}



Future<http.Response> makeRequest(
  String rawUrl,
  Map<String, dynamic>? params,
  ) async {
  // TODO - we could cache the requests...
  // but it would be SO much work

  var url = Uri.parse('https://aplikace.skolaonline.cz/solapi/$rawUrl');
  if (params != null) {
    url = url.replace(queryParameters: params);
  }

  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'accessToken');

  final response = await http.get(
    url,
    headers: {'Authorization': 'Bearer $accessToken'},
  );


  if (response.statusCode == 200) {
    return response;
  } else if (response.statusCode == 401) {
    print('refreshing token...');
    // TODO refresh the token
    final refreshToken = await storage.read(key: 'refreshToken');
    final resp = await http.post(
      Uri.parse('https://aplikace.skolaonline.cz/solapi/api/connect/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
        'client_id': 'web',
        'client_secret': 'web',
      },
    );
    print('refresh response is ${resp.statusCode}');

    if (resp.statusCode == 200) {
      final jsn = jsonDecode(resp.body);
      final accessToken = jsn['access_token'];
      final refreshToken = jsn['refresh_token'];

      await storage.write(key: 'accessToken', value: accessToken);
      await storage.write(key: 'refreshToken', value: refreshToken);
    } else {
      // TODO show dialog
      throw Exception('Failed to refresh token');
    }


    throw Exception('Failed to load data');
  } else {
    throw Exception('Failed to load data');
  }


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
            // Icon(Icons.school),
            Image(
              image: AssetImage('lib/assets/skolaoffline_logo.png'),
              height: 40,
              // width: MediaQuery.of(context).size.width * 0.5,
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
