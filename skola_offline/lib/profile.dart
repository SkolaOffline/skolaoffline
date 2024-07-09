import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:skola_offline/dummy_app_state.dart';
import 'package:url_launcher/url_launcher.dart'; // Import the url_launcher package

class ProfileScreen extends StatefulWidget {
  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DummyAppState _dummyAppState = DummyAppState();

  // Dummy data
  final Map<String, dynamic> _dummyLoginResponse = {
    "access_token": "dummy_access_token",
    "refresh_token": "dummy_refresh_token",
  };

  final Map<String, dynamic> _dummyUserResponse = {
    "personID": "dummy_person_id",
    "schoolYearId": "dummy_school_year_id",
  };

  Future<void> login(String username, String password) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Logging in...'),
            ],
          ),
        );
      },
    );

    final storage = FlutterSecureStorage();
    await storage.write(key: 'username', value: username);
    await storage.write(key: 'password', value: password);

    try {
      Map<String, dynamic> data;

      if (_dummyAppState.useDummyData) {
        // Use dummy data
        data = _dummyLoginResponse;
      } else {
        // Make the actual network request
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

        if (response.statusCode == 400) {
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop(); // Close the loading dialog
          _showErrorDialog(
              'Wrong credentials', 'Please check your username and password.');
          return;
        }

        if (response.statusCode != 200) {
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop(); // Close the loading dialog
          _showErrorDialog('Error', 'An error occurred while logging in.');
          return;
        }

        data = json.decode(response.body);
      }

      String accessToken = data['access_token'];
      String refreshToken = data['refresh_token'];

      await storage.write(key: 'accessToken', value: accessToken);
      await storage.write(key: 'refreshToken', value: refreshToken);

      // Get user data
      Map<String, dynamic> jsonResponse;

      if (_dummyAppState.useDummyData) {
        // Use dummy user data
        jsonResponse = _dummyUserResponse;
      } else {
        // Make the actual network request
        final userResponse = await http.get(
          Uri.parse("https://aplikace.skolaonline.cz/solapi/api/v1/user"),
          headers: {'Authorization': 'Bearer $accessToken'},
        );
        jsonResponse = json.decode(userResponse.body);
      }

      await storage.write(key: 'userId', value: jsonResponse['personID']);
      await storage.write(
          key: 'schoolYearId', value: jsonResponse['schoolYearId']);

      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(); // Close the loading dialog
      _showSuccessDialog('Success', 'You have been logged in.');
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => MyHomePage()),
      // );
    } catch (e) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(); // Close the loading dialog
      _showErrorDialog('Error', 'An unexpected error occurred: $e');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed:() {
                Navigator.of(context).pop();  
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Login'),
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  String username = _usernameController.text;
                  String password = _passwordController.text;
                  await login(username, password);
                },
                icon: Icon(Icons.login),
                label: Text('Login'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                ),
              ),
              SizedBox(height: 20), 
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 5,),
                  Text(
                    'Settings',
                      style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text('Here (in the future) you can change the settings of the app.'),
                  Text('Like the color or theme of the app.'),
                  Text('For now, you can only use dummy data.'),
                ],
              ),
              SwitchListTile(
                title: Text('Use Dummy Data'),
                value: _dummyAppState.useDummyData,
                onChanged: (bool value) {
                  setState(() {
                    _dummyAppState.useDummyData = value;
                  });
                },
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Icon(Icons.info),
                Text(
                  'About',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  launchUrl(Uri.parse('https://github.com/SkolaOffline/skolaoffline'));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.code),
                    Text('Github (Issues, Code, etc.)'),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  launchUrl(Uri.parse('mailto:bettateam.skolaoffline@gmail.com'));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.email),
                    Text('Email us'),
                  ],
                ),
              ),
             ],
          ),
        ),
      ),
    );
  }
}
