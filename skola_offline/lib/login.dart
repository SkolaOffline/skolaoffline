import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:skola_offline/main.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Dummy data
  final Map<String, dynamic> _dummyLoginResponse = {
    "access_token": "dummy_access_token",
    "refresh_token": "dummy_refresh_token",
  };

  final Map<String, dynamic> _dummyUserResponse = {
    "personID": "dummy_person_id",
    "schoolYearId": "dummy_school_year_id",
    "fullName": "Dummy Mode"
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
              Text(AppLocalizations.of(context)!.logging_loading),
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

      // ignore: use_build_context_synchronously
      if (MyApp.of(context)?.getDummyMode() ?? false) {
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
          _showErrorDialog('Wrong credentials',
              "Please check your username and password. If you don't have a skola online account you may try this app using dummy mode by loging in as 'dummy:mode'.");
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

      // ignore: use_build_context_synchronously
      if (MyApp.of(context)?.getDummyMode() ?? false) {
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
      await storage.write(key: 'fullName', value: jsonResponse['fullName']);

      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(); // Close the loading dialog
      _showSuccessDialog('Success', 'You have been logged in.');
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
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context)
                    .pop(); //This has to be here, i have no fricking idea why
                //lol
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
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profile),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
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
                  labelText: AppLocalizations.of(context)!.username,
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.password,
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  String username = _usernameController.text;
                  String password = _passwordController.text;

                  if (username == 'dummy' && password == 'mode') {
                    MyApp.of(context)?.setDummyMode(true);
                    _showSuccessDialog('Success', 'Dummy data mode enabled!');
                  } else {
                    MyApp.of(context)?.setDummyMode(false);
                  }
                  await login(username, password);
                },
                icon: Icon(Icons.login),
                label: Text(AppLocalizations.of(context)!.login),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "If you don't have an aplikace.skolaonline.cz account, u can use dummy mode by logging in as:\nusername: dummy\npassword: mode",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
