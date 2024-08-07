import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:skola_offline/main.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skola_offline/api_cubit.dart';

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
    List<dynamic> parseMessages(Map<String, dynamic> response) {
      List<dynamic> messageJsn = response['messages'];
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

    List<dynamic> parseMessagesJson(String jsonString) {
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

    if (MyApp.of(context)?.getDummyMode() ?? false) {
      final dummyData =
          await rootBundle.loadString("lib/assets/dummy_messages.json");
      setState(() {
        messageList = parseMessagesJson(dummyData);
        isLoading = false;
      });
    } else {
      try {
        // final storage = FlutterSecureStorage();
        // final accessToken = await storage.read(key: 'accessToken');
        final apiCubit = context.read<ApiCubit>();
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

        // final response =
        //     await makeRequest('api/v1/messages/received', params, context);
        final response = await apiCubit.makeRequest(
            'api/v1/messages/received', params, context);

        setState(() {
          messageList = parseMessages(response);
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading messages: $e'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: downloadMessages,
            ),
          ),
        );
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: downloadMessages,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : MessagesList(messageList: messageList),
      ),
    );
  }
}

class MessagesList extends StatelessWidget {
  final List<dynamic> messageList;

  const MessagesList({super.key, required this.messageList});

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
    super.key,
    required this.title,
    required this.content,
    required this.from,
    required this.date,
    required this.message,
  });

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
