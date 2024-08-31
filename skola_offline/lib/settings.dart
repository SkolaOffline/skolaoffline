import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:skola_offline/main.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.settings),
              SizedBox(
                width: 5,
              ),
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
                        Text(
                          '${AppLocalizations.of(context)!.language}: ',
                          style: TextStyle(fontSize: 20),
                        ),
                        DropdownButton<Locale>(
                            value: Localizations.localeOf(context),
                            items: AppLocalizations.supportedLocales
                                .map<DropdownMenuItem<Locale>>((Locale value) {
                              return DropdownMenuItem(
                                  value: value,
                                  child: Text(value.languageCode));
                            }).toList(),
                            onChanged: (Locale? value) {
                              MyApp.of(context)
                                  ?.setLocale(value ?? Locale('en'));
                            })
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.dark_mode,
                          style: TextStyle(fontSize: 20),
                        ),
                        Switch(
                            value: MyApp.of(context)?.getDarkMode() ?? false,
                            onChanged: (value) {
                              MyApp.of(context)?.setDarkMode(value);
                            })
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.dark_marks,
                          style: TextStyle(fontSize: 20),
                        ),
                        Switch(
                            value: MyApp.of(context)?.getDarkMarks() ?? false,
                            onChanged: (value) {
                              MyApp.of(context)?.setDarkMarks(value);
                            })
                      ],
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              "Disclaimer:\nWe are not in any way asociated with Škola Online, skolaonline.cz, BAKALÁŘI software s.r.o. or any other related subjects. This project is for educational purposes only.",
                              style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow:TextOverflow.visible
                        ),
                        ]),
                  ],
                ))));
  }
}
