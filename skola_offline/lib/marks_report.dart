import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skola_offline/l10n/app_localizations.dart';
// import 'package:http/http.dart' as http;
import 'package:skola_offline/main.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;

class MarksReportScreen extends StatefulWidget {
  @override
  MarksReportScreenState createState() => MarksReportScreenState();
}

class MarksReportScreenState extends State<MarksReportScreen> {
  List<dynamic> certificateTerms = [];
  bool isLoading = true;
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _fetchMarks();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> _fetchMarks() async {
    if (MyApp.of(context)?.getDummyMode() ?? false) {
      final dummyData =
          await rootBundle.loadString('lib/assets/dummy_report.json');
      setState(() {
        certificateTerms = json.decode(dummyData)['certificateTerms'];
        isLoading = false;
      });
    } else {
      try {
        final storage = FlutterSecureStorage();
        final userId = await storage.read(key: 'userId');
        // final accessToken = await storage.read(key: 'accessToken');

        // final url = Uri.parse(
        //     "https://aplikace.skolaonline.cz/solapi/api/v1/students/$userId/marks/bySubject");

        // final response = await http.get(
        //   url,
        //   headers: {'Authorization': 'Bearer $accessToken'},
        // );

        final response = await makeRequest(
          'api/v1/students/$userId/marks/final',
          null,
          // ignore: use_build_context_synchronously
          context,
        );

        if (response.statusCode == 200) {
          if (_mounted) {
            setState(() {
              certificateTerms = json.decode(response.body)['certificateTerms'];
              isLoading = false;
            });
          }
        } else {
          throw Exception('Failed to load marks');
        }
      } catch (e) {
        print('Error fetching marks: $e');
        if (_mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    certificateTerms = certificateTerms.reversed.toList();
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchMarks,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(12.0),
                child: ListView.builder(
                  itemCount: certificateTerms.length,
                  itemBuilder: (context, index) {
                    final term = certificateTerms[index];
                    return TermCard(term: term);
                  },
                ),
              ),
      ),
    );
  }
}

class TermCard extends StatelessWidget {
  final Map<String, dynamic> term;

  const TermCard({super.key, required this.term});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            '${term['gradeName']} - ${term['semesterName']}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('School Year: ${term['schoolYearName']}'),
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: term['finalMarks'].length,
              itemBuilder: (context, index) {
                var mark = term['finalMarks'][index];
                mark['markText'] ??= "NaN";
                final subject = term['subjects'].firstWhere(
                  (s) => s['id'] == mark['subjectId'],
                  orElse: () => {'name': 'Unknown Subject'},
                );
                return Column(
                  children: [
                    ListTile(
                      tileColor: Theme.of(context).colorScheme.onSecondary,
                      title: Text(
                        subject['name'],
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(formatDateToDate(mark['markDate']),
                          style: TextStyle(fontSize: 12)),
                      trailing: Container(
                        width: 30,
                        height: 40,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getMarkColor(mark['markText']),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 6,
                              offset: Offset(4, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            mark['markText'],
                            style: TextStyle(
                              color:
                                  (MyApp.of(context)?.getDarkMarks() ?? false)
                                      ? Colors.black
                                      : Color.fromARGB(255, 202, 196, 208),
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      onTap: () => _showMarkDetails(context, mark, subject),
                    ),
                    Divider(height: 0),
                  ],
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Achievement: ${term['achievementText']}'),
                    Text('Marks Average: ${term['marksAverage']}'),
                    Text('Absent Hours: ${term['absentHours']}'),
                    Text('Excused Hours: ${term['excusedHours']}'),
                    Text('Not Excused Hours: ${term['notExcusedHours']}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMarkColor(String mark) {
    switch (mark) {
      case '1':
        return Colors.green;
      case '2':
        return Colors.lightGreen;
      case '3':
        return Colors.yellow;
      case '4':
        return Colors.orange;
      case '5':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String formatDateToDate(String date) {
    final dateFormatter = DateFormat('dd.MM.yyyy');
    return dateFormatter.format(DateTime.parse(date));
  }

  void _showMarkDetails(BuildContext context, Map<String, dynamic> mark,
      Map<String, dynamic> subject) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(subject['name']),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    '${AppLocalizations.of(context)!.date}: ${formatDateToDate(mark['markDate'])}'),
                Text(
                    '${AppLocalizations.of(context)!.mark}: ${mark['markText']}'),
                Text(
                    '${AppLocalizations.of(context)!.edit_date}: ${formatDateToDate(mark['editDate'])}'),
                if (mark['verbalEvaluation'] != null)
                  Text(
                      '${AppLocalizations.of(context)!.verbal_evaluation}: ${mark['verbalEvaluation']}'),
                Text(
                    '${AppLocalizations.of(context)!.released}: ${mark['released'] ? 'Yes' : 'No'}'),
                Text(
                    '${AppLocalizations.of(context)!.unclassified}: ${mark['unclassified'] ? 'Yes' : 'No'}'),
                Text(
                    '${AppLocalizations.of(context)!.unevaluated}: ${mark['unevaluated'] ? 'Yes' : 'No'}'),
                Text(
                    '${AppLocalizations.of(context)!.recognized}: ${mark['recognized'] ? 'Yes' : 'No'}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
