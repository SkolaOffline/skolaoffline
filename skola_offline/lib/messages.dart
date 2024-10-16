import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:skola_offline/main.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;

class MessagesScreen extends StatefulWidget {
  @override
  MessagesScreenState createState() => MessagesScreenState();
}

class MessagesScreenState extends State<MessagesScreen> {
  List<dynamic> messageList = [];
  int selectedMessage = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    downloadMessages();
  }

  Future<void> downloadMessages() async {
    if (MyApp.of(context)?.getDummyMode() ?? false) {
      final dummyData =
          await rootBundle.loadString("lib/assets/dummy_messages.json");
      setState(() {
        messageList = parseMessages(dummyData);
        isLoading = false;
      });
    } else {
      try {
        // final storage = FlutterSecureStorage();
        // final accessToken = await storage.read(key: 'accessToken');

        final now = DateTime.now();
        final params = {
          'dateFrom': DateFormat('yyyy-MM-ddTHH:mm:ss.SSS')
              .format(now.subtract(Duration(days: 100))),
          'dateTo': DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(now),
        };

        // final url = Uri.parse(
        //         'https://aplikace.skolaonline.cz/solapi/api/v1/messages/received')
        //     .replace(queryParameters: params);

        // final response = await http.get(
        //   url,
        //   headers: {'Authorization': 'Bearer $accessToken'},
        // );

        final response =
            await makeRequest('api/v1/messages/received', params, context);

        if (response.statusCode == 200) {
          setState(() {
            messageList = parseMessages(response.body);
            isLoading = false;
          });
        } else {
          throw Exception('Failed to load messages: ${response.statusCode}');
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading messages: $e')),
        );
      }
    }
  }

  List<dynamic> parseMessages(String jsonString) {
    Map<String, dynamic> jsn = jsonDecode(jsonString);
    List<dynamic> messageJsn = jsn['messages'];
    return messageJsn
        .map((message) => {
              'sentDate': message['sentDate'],
              'read': message['read'],
              'sender': message['sender']['name'],
              'attachments': message['attachments'].toString(),
              'title': message['title'],
              'text': message['text'],
              'id': message['id'],
            })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Scaffold(
      appBar:AppBar(
        title: Center(child: Text(messageList[selectedMessage]['title'])),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Container(
        width:500,
        child:Drawer(
        child:    ListView.builder(
      padding: EdgeInsets.all(20.0),
      itemCount: messageList.length,
      itemBuilder: (context, index) {
        final message = messageList[index];
        return Column(
          children: [
            GestureDetector(
          onTap: () {
            setState(() {
              selectedMessage = index;
            });
          },
          child: MessageWidget(
          title: message['title'],
          content: message['text'],
          from: message['sender'],
          date: message['sentDate'],
          message: message,
          index:index,
          selected:index==selectedMessage
        )
            ),
            SizedBox(height:10)
          ],
          );
        
        
        
      },
    )
      ),
      ),
      body:Padding(
        padding: EdgeInsets.all(10),
        child:Html(
        data: messageList[selectedMessage]['text'],
        style: {
          'p': Style(
            fontSize: FontSize(16),
          ),
          'span': Style(
            fontSize: FontSize(16),
          ),
          'a': Style(
            fontSize: FontSize(16),
          ),
        },
      )
      )
    ),
    );
  }
}

class MessageWidget extends StatelessWidget {
  final String title;
  final String content;
  final String from;
  final String date;
  final dynamic message;
  final int index;
  final bool selected;

  const MessageWidget({
  super.key,
  required this.title,
  required this.content,
  required this.from,
  required this.date,
  required this.message,
  required this.index,
  required this.selected
  });


  @override
  Widget build(BuildContext context) {
    return Container(
            decoration: BoxDecoration(
              color: selected ? Theme.of(context).colorScheme.secondaryContainer : Theme.of(context).colorScheme.primaryContainer,
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
                            fontSize: 15,
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
                          Text(from,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          ),
                          Text(formatDateToDate(date),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
  }

  String formatDateToDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return DateFormat('d. M. yyyy').format(dateTime);
  }
}
