import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class MessagesScreen extends StatefulWidget {
  @override
  MessagesScreenState createState() => MessagesScreenState();
}

class MessagesScreenState extends State<MessagesScreen> {
  List<dynamic> messageList = [];

  @override
  void initState() {
    super.initState();
    downloadMessages().then((value) {
      setState(() {
        messageList = parseMessages(value);
      });
    });
  }

  Future<String> downloadMessages() async {
    final storage = FlutterSecureStorage();
    final accessToken = await storage.read(key: 'accessToken');

    final params = {
      // TODO - not hardcoded
      'dateFrom': '2024-04-01T00:00:00.000',
      'dateTo': '2024-08-01T00:00:00.000',
    };

    final url = Uri.parse(
            'https://aplikace.skolaonline.cz/solapi/api/v1/messages/received')
        .replace(queryParameters: params);

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      // print(response.body);
      return response.body;
    } else {
      // TODO - handle exceptions
      throw Exception(
          'Failed to load messages\n${response.statusCode}\n${response.body}');
    }
  }

  List<dynamic> parseMessages(String jsonString) {
    Map<String, dynamic> jsn = jsonDecode(jsonString);
    List<dynamic> messageJsn = jsn['messages'];
    var messages = [];

    for (var message in messageJsn) {
      var messg = {
        'sentDate': message['sentDate'],
        'read': message['read'],
        'sender': message['sender']['name'],
        'attachments': message['attachemnts'].toString(),
        'title': message['title'],
        'text': message['text']
        // parse(message['text'])
        // .outerHtml
        // .replaceAll(RegExp(r''), '')
        ,
        'id': message['id'],
      };
      messages.add(messg);
    }

    return messages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // body: ListView(children: [
        // Text(
        // 'Zprávy',
        // style: Theme.of(context).textTheme.displayMedium!.copyWith(),
        // ),
        body: Messages(messageList: messageList, context: context)
        // ],)
        );
  }

  String formatDateToDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    //TODO: USE DateFormat - better build-in version of the same thing
    String formatedDate =
        '${dateTime.day}. ${dateTime.month}. ${dateTime.year}';
    // print(formatedDate);
    return formatedDate;
  }

  // ignore: non_constant_identifier_names
  Widget Messages(
      {required List<dynamic> messageList, required BuildContext context}) {
    if (messageList.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(
                width: 10,
              ),
              Text('Loading...'),
            ],
          ),
        ],
      );
    } else {
      return Scaffold(
          body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            for (var message in messageList)
              MessageWidget(
                  title: message['title'],
                  content: message['text'],
                  context: context,
                  from: message['sender'],
                  date: message['sentDate'],
                  message: message),
          ],
        ),
      ));
    }
  }

  // ignore: non_constant_identifier_names
  Widget MessageWidget({
    required String title,
    required String content,
    required BuildContext context,
    required String from,
    required String date,
    required final message,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(from),
                        Text(formatDateToDate(date)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Html(
                  data: content,
                  style: {
                    'p': Style(
                      fontSize: FontSize(16),
                    ),
                  },
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }
}
