import 'package:flutter/material.dart';
import 'package:skola_offline/l10n/app_localizations.dart';
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
                          AppLocalizations.of(context)!.default_timetable,
                          style: TextStyle(fontSize: 20),
                        ),
                        DropdownButton<bool>(
                            value: MyApp.of(context)
                                    ?.getDefaultToWeeklyTimetable() ??
                                false,
                            items: [
                              DropdownMenuItem(
                                  value: true,
                                  child: Text(
                                      AppLocalizations.of(context)!.weekly)),
                              DropdownMenuItem(
                                  value: false,
                                  child:
                                      Text(AppLocalizations.of(context)!.daily))
                            ],
                            onChanged: (bool? value) {
                              MyApp.of(context)
                                  ?.setDefaultToWeeklyTimetable(value ?? false);
                            })
                      ],
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context)!.disclaimer,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        ]),
                  ],
                ))));
  }
}
