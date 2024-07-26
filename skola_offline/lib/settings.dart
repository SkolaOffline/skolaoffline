import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:skola_offline/absences.dart';
import 'package:skola_offline/app_settings.dart';
import 'package:url_launcher/url_launcher.dart'; // Import the url_launcher package
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:skola_offline/main.dart';

class SettingsScreen extends StatelessWidget{
@override
Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 5,),
                  Text(
                    AppLocalizations.of(context)!.settings,
                      style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                padding: const EdgeInsets.all(8),
                children: [
                  Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppLocalizations.of(context)!.language+ ': ',
                            style: TextStyle(fontSize: 20),),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Dark mode',
                            style: TextStyle(fontSize: 20),),
                            Switch(value: MyApp.of(context)?.getDarkMode() ?? false, onChanged: (value){
                              // MyApp.of(context)?.setDarkMode(value);
                              value = true; // A bit of trolling while dark mode is not active. 
                            })
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Dark marks',
                            style: TextStyle(fontSize: 20),),
                            Switch(value: MyApp.of(context)?.getDarkMarks() ?? false, onChanged: (value){
                              MyApp.of(context)?.setDarkMarks(value);
                            })
                          ],
                        ),

                ],
          )
        )
      )
    );
  }
}