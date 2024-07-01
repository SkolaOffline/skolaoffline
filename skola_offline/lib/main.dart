// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
        primarySwatch: Colors.blue,
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
  // test login
  Future<void> testLogin() async {
    final storage = FlutterSecureStorage();
    String? username = await storage.read(key: 'username');
    String? password = await storage.read(key: 'password');
    String? accessToken = await storage.read(key: 'accessToken');
    String? refreshToken = await storage.read(key: 'refreshToken');

    print('username: $username');
    print('password: $password');
    print('accessToken: $accessToken');
    print('refreshToken: $refreshToken');
  }

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
        title: Text('Škola Offline'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Add this line
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Timetable',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_numbered_outlined),
            label: 'Marks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mark_as_unread),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_off),
            label: 'Absences',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class TimetableScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Timetable Screen'),
    );
  }
}

class MarksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Marks Screen'),
    );
  }
}

class MessagesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Message Screen'),
    );
  }
}

class AbsencesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Absences Screen'),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  TextEditingController _usernameController = TextEditingController(); // Add this line
  TextEditingController _passwordController = TextEditingController(); // Add this line

  Future<void> login(username, password) async {
    showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
    return Dialog(
      child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        CircularProgressIndicator(),
        SizedBox(height: 16.0),
        Text('Logging in...'),
        ],
      ),
      ),
    );
    },
    );


    final storage = FlutterSecureStorage();
    await storage.write(key: 'username', value: username);
    await storage.write(key: 'password', value: password);
 
    final response = await http.post(
      Uri.parse('https://aplikace.skolaonline.cz/solapi/api/connect/token'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: <String, String>{
        'grant_type': 'password',
        'username': username,
        'password': password,
        'client_id': 'test_client',
        'scope': 'openid offline_access profile sol_api',
      },
    );

    Navigator.of(context).pop();

    if (response.statusCode == 400) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Wrong credentials'),
            content: Text('Please check your username and password.'),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }
    if (response.statusCode != 200) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(response.body),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    } else {
      showDialog(context: context, builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('You have been logged in.'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      });
    }


    // print(response.body);
    Map<String, dynamic> data = json.decode(response.body);
    String accessToken = data['access_token'];
    print('expires in: ${data['expires_in']}');
    String refreshToken = data['refresh_token'];

    await storage.write(key: 'accessToken', value: accessToken);
    await storage.write(key: 'refreshToken', value: refreshToken);

  }

  Future<void> logout() async {
    final storage = FlutterSecureStorage();

    final response = await http.post(
      Uri.parse('https://aplikace.skolaonline.cz/solapi/api/v1/user/logout'),
      headers: {
        "Authorization": "Bearer ${await storage.read(key: 'accessToken')}",
      },
    );

    if (response.statusCode != 200) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(response.body),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
    else {
      await storage.deleteAll();
      showDialog(context: context, builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('You have been logged out.'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      });
    }
    
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('John Doe'),
                  ],
                ),
              ],
            ),
            TextField(
              controller: _usernameController, // Add this line
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            TextField(
              controller: _passwordController, // Add this line
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            SizedBox(height: 20,),
            ElevatedButton(
                onPressed: () async {
                String username = _usernameController.text;
                String password = _passwordController.text;
                await login(username, password);
              },

              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.login),
                    Text('Login (takes ~5 seconds)'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 15,),
            ElevatedButton(
              onPressed: () {
                logout();
              }, 
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    Text('Logout'),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}