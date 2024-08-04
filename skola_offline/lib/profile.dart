import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skola_offline/login.dart';
import 'package:url_launcher/url_launcher.dart'; // Import the url_launcher package
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  String _fullName = 'User';
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _readUserData();
  }

  Future<void> _readUserData() async {
    final storage = FlutterSecureStorage();
    final fullName = await storage.read(key: 'fullName');
    setState(() {
      _fullName = fullName ?? 'Fuck McFuckFace';
      isLoading = false;
    });
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
              Text(
                  isLoading ? AppLocalizations.of(context)!.loading : _fullName,
                  style: TextStyle(fontSize: 30)),
              ElevatedButton(
                  onPressed: () {
                    //TODO: Change dummy mode!!!
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                  child: Text(AppLocalizations.of(context)!.change_user)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info),
                  Text(
                    AppLocalizations.of(context)!.about,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  launchUrl(Uri.parse(
                      'https://github.com/SkolaOffline/skolaoffline'));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.code),
                    Text(AppLocalizations.of(context)!.github),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  launchUrl(
                      Uri.parse('mailto:bettateam.skolaoffline@gmail.com'));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.email),
                    Text(AppLocalizations.of(context)!.email_us),
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
