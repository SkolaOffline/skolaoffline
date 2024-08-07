import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:skola_offline/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skola_offline/api_cubit.dart';

class AbsencesScreen extends StatefulWidget {
  @override
  AbsencesScreenState createState() => AbsencesScreenState();
}

class AbsencesScreenState extends State<AbsencesScreen> {
  List<dynamic> absencesSubjectList = [];
  bool isLoading = true;
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _fetchAbsences();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> _fetchAbsences() async {
    try {
      final absencesData = await downloadAbsences();
      if (_mounted) {
        setState(() {
          absencesSubjectList = parseAbsences(absencesData);
          isLoading = false;
        });
      }
    } catch (e) {
      print('error fetching absences: $e');
      if (_mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  List<dynamic> parseAbsences(String jsonString) {
    final absencesData = jsonDecode(jsonString);
    List<dynamic> absencesList = [];

    final absenceAllInAll = {
      'subjectName': 'Dohromady',
      'absences': absencesData['summaryAbsenceAll'],
      'percentage': absencesData['absenceAllPercentage'],
      'numberOfHours': absencesData['summaryNumberOfHours'],
      'excused': absencesData['summaryNumberOfExcused'],
      'unexcused': absencesData['summaryNumberOfUnexcused'],
      'notCounted': absencesData['summaryNumberOfNotCounted'],
      'allowedAbsences': -1,
      'allowedPercentage': -1,
    };
    absencesList.add(absenceAllInAll);

    for (var absence in absencesData['subjects']) {
      final absenceDict = {
        'subjectName': absence['subject']['name'],
        'absences': absence['absenceAll'],
        'percentage': absence['absenceAllPercentage'],
        'numberOfHours': absence['numberOfHours'],
        'excused': absence['numberOfExcused'],
        'unexcused': absence['numberOfUnexcused'],
        'notCounted': absence['numberOfNotCounted'],
        'allowedAbsences': absence['allowedAbsence'],
        'allowedPercentage': absence['allowedAbsencePercentage'],
      };
      absencesList.add(absenceDict);
    }

    return absencesList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                for (var subject in absencesSubjectList)
                  AbsenceInSubjectCard(absence: subject, context: context)
              ],
            ),
    );
  }

  Future<String> downloadAbsences() async {
    if (MyApp.of(context)?.getDummyMode() ?? false) {
      return await rootBundle.loadString('lib/assets/dummy_absences.json');
    } else {
      String dateFrom() {
        final today = DateTime.now();

        if (today.month > 2 && today.month < 9) {
          // Second half of the academic year (Spring semester)
          final secondSemester = DateTime(today.year, 2, 1);
          return secondSemester.toIso8601String().split('T')[0];
        } else {
          // First half of the academic year (Fall semester)
          final firstSemester = DateTime(today.year, 9, 1);
          return firstSemester.toIso8601String().split('T')[0];
        }
      }

      final params = {
        'dateFrom': dateFrom(),
        'dateTo': DateTime(DateTime.now().year, 6, 30)
            .toIso8601String()
            .split('T')[0],
      };

      // final response = await makeRequest(
      //     'api/v1/absences/inSubject',
      //     null,
      //     // ignore: use_build_context_synchronously
      //     context,
      //   );

      final apiCubit = context.read<ApiCubit>();
      final response = await apiCubit.makeRequest(
        'api/v1/absences/inSubject',
        params,
        context,
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception(
            'Failed to load absences\n${response.statusCode}\n${response.body}');
      }
    }
  }

  // ignore: non_constant_identifier_names
  Widget AbsenceInSubjectCard(
      {required final absence, required final BuildContext context}) {
    return Column(
      children: [
        Card(
          elevation: 5,
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              children: [
                SizedBox(
                  width: 7,
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    absence['subjectName'] ??
                        AppLocalizations.of(context)!.unknown_subject,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.absence,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        absence['absences']?.toString() ?? 'N/A',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Percentage',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        absence['percentage'] != null
                            ? '${absence['percentage']}%'
                            : 'N/A',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 5,
        )
      ],
    );
  }
}
