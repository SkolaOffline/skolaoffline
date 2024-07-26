import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skola_offline/dummy_app_state.dart';
import 'package:skola_offline/login.dart';
import 'package:url_launcher/url_launcher.dart'; // Import the url_launcher package
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:skola_offline/main.dart';

class ProfileScreen extends StatefulWidget {
  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final _dummyAppState = DummyAppState();
  String _fullName='User';
  bool isLoading = true;
  @override
  void initState(){
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
                style:TextStyle(fontSize: 30)
              ),
              ElevatedButton(onPressed: (){
                _dummyAppState.useDummyData = false;
                Navigator.push(context, 
                MaterialPageRoute(builder: (context) => LoginScreen()));
              }, child: Text(AppLocalizations.of(context)!.change_user)),
              SizedBox(height: 20), 
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Icon(Icons.settings),
              //     SizedBox(width: 5,),
              //     Text(
              //       AppLocalizations.of(context)!.settings,
              //         style: TextStyle(
              //         fontSize: 20,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //   ],
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context)!.language+ ': '),
                  DropdownButton<Locale>(value:Localizations.localeOf(context) ,items: AppLocalizations.supportedLocales.map<DropdownMenuItem<Locale>>((Locale value){
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value.languageCode)
                      );
                  }).toList(),
                  onChanged: (Locale? value){
                    MyApp.of(context)?.setLocale(value ?? Locale('en'));
                  })
                ],
              ),
              Column(
                children: [
                  Text(AppLocalizations.of(context)!.settings_placeholder_text_1),
                  Text(AppLocalizations.of(context)!.settings_placeholder_text_2),
                  Text(AppLocalizations.of(context)!.settings_placeholder_text_3),
                ],
              ),
              // SwitchListTile(
              //   title: Text('Use Dummy Data'),
              //   value: _dummyAppState.useDummyData,
              //   onChanged: (bool value) {
              //     setState(() {
              //       _dummyAppState.useDummyData = value;
              //     });
              //   },
              // ),
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
                  launchUrl(Uri.parse('https://github.com/SkolaOffline/skolaoffline'));
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
                  launchUrl(Uri.parse('mailto:bettateam.skolaoffline@gmail.com'));
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
