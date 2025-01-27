import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveDemoPage extends StatefulWidget {
  @override
  _HiveDemoPageState createState() => _HiveDemoPageState();
}

class _HiveDemoPageState extends State<HiveDemoPage> {
  final TextEditingController _textFieldController1 = TextEditingController();
  final TextEditingController _textFieldController2 = TextEditingController();
  String _hiveTextField1 = '';
  String _hiveTextField2 = '';

  @override
  void initState() {
    super.initState();
    Hive.box('myBox').watch(key: 'textField1').listen((event) {
      setState(() {
        _hiveTextField1 = event.value;
        _textFieldController1.text = event.value;
      });
    });
    Hive.box('myBox').watch(key: 'textField2').listen((event) {
      setState(() {
        _hiveTextField2 = event.value;
        _textFieldController2.text = event.value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hive Demo Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _textFieldController1,
              decoration: InputDecoration(
                labelText: 'Text Field 1',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _textFieldController2,
              decoration: InputDecoration(
                labelText: 'Text Field 2',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Handle button press
                print('Button pressed');
                print('Text Field 1: ${_textFieldController1.text}');
                print('Text Field 2: ${_textFieldController2.text}');
                Hive.box('myBox').put('textField1', _textFieldController1.text);
                Hive.box('myBox').put('textField2', _textFieldController2.text);
              },
              child: Text('Push data'),
            ),
            SizedBox(height: 16.0),
            Text('Hive Text Field 1: $_hiveTextField1'),
            Text('Hive Text Field 2: $_hiveTextField2'),
          ],
        ),
      ),
    );
  }
}