import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:skola_offline/dummy_app_state.dart';
import 'package:flutter/services.dart' show rootBundle;

class MessagesScreen extends StatefulWidget {
  @override
  MessagesScreenState createState() => MessagesScreenState();
}

class MessagesScreenState extends State<MessagesScreen> {
  List<dynamic> messageList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    downloadMessages();
  }

  Future<void> downloadMessages() async {
    final dummyAppState = DummyAppState();
    bool useDummyData = dummyAppState.useDummyData;
    if (useDummyData) {
      final dummyData =
          await rootBundle.loadString("lib/assets/dummy_messages.json");
      setState(() {
        messageList = parseMessages(dummyData);
        isLoading = false;
      });
    } else {
      try {
        final storage = FlutterSecureStorage();
        final accessToken = await storage.read(key: 'accessToken');

        final now = DateTime.now();
        final params = {
          'dateFrom': DateFormat('yyyy-MM-ddTHH:mm:ss.SSS')
              .format(now.subtract(Duration(days: 100))),
          'dateTo': DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(now),
        };

        final url = Uri.parse(
                'https://aplikace.skolaonline.cz/solapi/api/v1/messages/received')
            .replace(queryParameters: params);

        final response = await http.get(
          url,
          headers: {'Authorization': 'Bearer $accessToken'},
        );

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
          : MessagesList(messageList: messageList),
    );
  }
}

class MessagesList extends StatelessWidget {
  final List<dynamic> messageList;

  const MessagesList({Key? key, required this.messageList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(20.0),
      itemCount: messageList.length,
      itemBuilder: (context, index) {
        final message = messageList[index];
        return MessageWidget(
          title: message['title'],
          content: message['text'],
          from: message['sender'],
          date: message['sentDate'],
          message: message,
        );
      },
    );
  }
}

class MessageWidget extends StatefulWidget {
  final String title;
  final String content;
  final String from;
  final String date;
  final dynamic message;

  const MessageWidget({
    Key? key,
    required this.title,
    required this.content,
    required this.from,
    required this.date,
    required this.message,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MessageWidgetState createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _toggleExpanded,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
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
                          widget.title,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: _isExpanded ? null : 2,
                          overflow: _isExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(widget.from),
                          Text(formatDateToDate(widget.date)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: _isExpanded ? 8 : 0),
                  Html(
                    data: _isExpanded ? widget.content : '',
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
                  ),
                  // Text(_isExpanded ? widget.content : ''),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }

  String formatDateToDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return DateFormat('d. M. yyyy').format(dateTime);
  }
}
