import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:http/http.dart' as http;
import 'package:skola_offline/main.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;

class MarksBySubjectScreen extends StatefulWidget {
  @override
  MarksBySubjectScreenState createState() => MarksBySubjectScreenState();
}

class MarksBySubjectScreenState extends State<MarksBySubjectScreen> {
  List<dynamic> subjects = [];
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
          await rootBundle.loadString('lib/assets/dummy_marks.json');
      setState(() {
        subjects = json.decode(dummyData)['subjects'];
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
          'api/v1/students/$userId/marks/bySubject',
          null,
          // ignore: use_build_context_synchronously
          context,
        );

        if (response.statusCode == 200) {
          if (_mounted) {
            setState(() {
              subjects = json.decode(response.body)['subjects'];
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
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchMarks,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return SubjectCard(subject: subject);
                },
              ),
      ),
    );
  }
}

class SubjectCard extends StatelessWidget {
  final Map<String, dynamic> subject;

  const SubjectCard({Key? key, required this.subject}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final dummyAppState = DummyAppState();
    // bool useDummyData = dummyAppState.useDummyData;
    //Done: this is shitty workaround, fix dummy data to have 'subject' key somehow, probably error in loading dummy data
    // if (useDummyData) {
    //   return Card(
    //     elevation: 4,
    //     margin: EdgeInsets.all(8),
    //     color: Theme.of(context).colorScheme.primaryContainer,
    //     child: ExpansionTile(
    //       title: Text(
    //         subject['name'],
    //         style: TextStyle(fontWeight: FontWeight.bold),
    //       ),
    //       subtitle: RichText(
    //           text: TextSpan(
    //               text: AppLocalizations.of(context)!.average + ': ', // Normal text
    //               style: DefaultTextStyle.of(context).style,
    //               children: <TextSpan>[
    //             TextSpan(
    //               text: '${subject['averageText']}', // Bold text
    //               style: TextStyle(
    //                 fontWeight: FontWeight.bold,
    //                 fontSize: 16,
    //               ),
    //             )
    //           ])),
    //       children: [
    //         ListView.builder(
    //           shrinkWrap: true,
    //           physics: NeverScrollableScrollPhysics(),
    //           itemCount: subject['marks'].length,
    //           itemBuilder: (context, index) {
    //             final mark = subject['marks'][index];
    //             return Column(
    //               children: [
    //                 ListTile(
    //                   tileColor: Theme.of(context).colorScheme.onSecondary,
    //                   // focusColor: Theme.of(context).colorScheme.secondaryContainer,
    //                   title: Text(
    //                     mark['theme'].substring(0, 1).toUpperCase() +
    //                         mark['theme'].substring(1),
    //                     style: TextStyle(fontWeight: FontWeight.w600),
    //                   ),
    //                   // subtitle: Text('Date: ${mark['markDate'].split('T')[0]}'),
    //                   subtitle: Text(formatDateToDate(mark['markDate']),
    //                       style: TextStyle(fontSize: 12)),
    //                   trailing: Row(
    //                     mainAxisSize: MainAxisSize.min,
    //                     children: [
    //                       SizedBox(width: 8),
    //                       Padding(
    //                         padding: const EdgeInsets.only(
    //                             left: 6.0,
    //                             right:
    //                                 6.0), // Adds 16 pixels of padding on the left and 32 pixels on the right
    //                         // child: Text('Weight: ${mark['weight']}',
    //                         child: Text('${(mark['weight'] * 10).toInt()}',
    //                             style: TextStyle(
    //                                 fontSize: 15, fontWeight: FontWeight.w400)),
    //                       ),
    //                       SizedBox(width: 8),
    //                       Container(
    //                         width: 30,
    //                         height: 40,
    //                         padding: EdgeInsets.all(8),
    //                         decoration: BoxDecoration(
    //                           color: _getMarkColor(mark['markText']),
    //                           borderRadius: BorderRadius.circular(5),
    //                           boxShadow: [
    //                             BoxShadow(
    //                               color: Colors.grey.withOpacity(0.5),
    //                               spreadRadius: 2,
    //                               blurRadius: 6,
    //                               offset: Offset(4, 4),
    //                             ),
    //                           ],
    //                         ),
    //                         child: Center(
    //                           child: Text(
    //                             mark['markText'],
    //                             style: TextStyle(
    //                                 fontWeight: FontWeight.bold, fontSize: 20,
    //                                 color:Colors.black,
    //                                 ),
    //                           ),
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                   onTap: () =>
    //                       _showMarkDetails(context, mark, subject['teachers']),
    //                 ),
    //                 Divider(
    //                   height: 0,
    //                 ),
    //               ],
    //             );
    //           },
    //         ),
    //       ],
    //     ),
    //   );
    // } else {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: ExpansionTile(
        title: Text(
          subject['subject']['name'],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: RichText(
            text: TextSpan(
                text:
                    AppLocalizations.of(context)!.average + ': ', // Normal text
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
              TextSpan(
                text: '${subject['averageText']}', // Bold text
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              )
            ])),
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: subject['marks'].length,
            itemBuilder: (context, index) {
              final mark = subject['marks'][index];
              return Column(
                children: [
                  ListTile(
                    tileColor: Theme.of(context).colorScheme.onSecondary,
                    // focusColor: Theme.of(context).colorScheme.secondaryContainer,
                    title: Text(
                      mark['theme'].substring(0, 1).toUpperCase() +
                          mark['theme'].substring(1),
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    // subtitle: Text('Date: ${mark['markDate'].split('T')[0]}'),
                    subtitle: Text(formatDateToDate(mark['markDate']),
                        style: TextStyle(fontSize: 12)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 6.0,
                              right:
                                  6.0), // Adds 16 pixels of padding on the left and 32 pixels on the right
                          // child: Text('Weight: ${mark['weight']}',
                          child: Text('${(mark['weight'] * 10).toInt()}',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w400)),
                        ),
                        SizedBox(width: 8),
                        Container(
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
                      ],
                    ),
                    onTap: () =>
                        _showMarkDetails(context, mark, subject['teachers']),
                  ),
                  Divider(
                    height: 0,
                  ),
                ],
              );
            },
          ),
        ],
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
    // final dateFormatter = DateFormat('y-MM-ddTHH:mm:ss.000');
    final dateFormatter = DateFormat('dd.MM.yyyy');
    return dateFormatter.format(DateTime.parse(date));
  }

  void _showMarkDetails(
      BuildContext context, Map<String, dynamic> mark, List<dynamic> teachers) {
    String teacherName = AppLocalizations.of(context)!.unknown;
    for (var teacher in teachers) {
      if (teacher['id'] == mark['teacherId']) {
        teacherName = teacher['displayName'];
        break;
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(mark['theme']),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // Text('Date: ${mark['markDate'].split('T')[0]}'),
                Text('Date: ${formatDateToDate(mark['markDate'])}'),
                Text('Mark: ${mark['markText']}'),
                Text('Weight: ${mark['weight']}'),
                // Text('Type: ${mark['type']}'),
                if (mark['typeNote'] != null)
                  Text('Type Note: ${mark['typeNote']}'),
                if (mark['comment'] != null)
                  Text('Comment: ${mark['comment']}'),
                if (mark['verbalEvaluation'] != null)
                  Text('Verbal Evaluation: ${mark['verbalEvaluation']}'),
                Text('Teacher: $teacherName'),
                if (mark['classRankText'] != null)
                  Text('Class Rank: ${mark['classRankText']}'),
                if (mark['classAverage'] != null)
                  Text('Class Average: ${mark['classAverage']}'),
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
