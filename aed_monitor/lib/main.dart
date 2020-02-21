import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter/material.dart';

void main() async {

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final title = 'AED Cabinet Monitor';
    return MaterialApp(
      title: title,
      home: MyHomePage(
        title: title,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
//  final Socket channel;

  MyHomePage({Key key, @required this.title})
      : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    child: Text("Configure Device",
                        style: TextStyle(
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                            fontSize: 20.0
                        )
                    ),
                    color: Colors.red,
                    onPressed: _configDevice,
                  ),
                  RaisedButton(
                    child: Text("Active Mode",
                        style: TextStyle(
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                            fontSize: 20.0
                        )
                    ),
                    color: Colors.red,
                    onPressed: _activeMode,
                  ),
                  RaisedButton(
                    child: Text("Sleep Mode",
                        style: TextStyle(
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                            fontSize: 20.0
                        )
                    ),
                    color: Colors.red,
                    onPressed: _sleepMode,
                  ),
                  RaisedButton(
                    child: Text("Send Test Email",
                        style: TextStyle(
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                            fontSize: 20.0
                        )
                    ),
                    color: Colors.red,
                    onPressed: _sendEmail,
                  ),
                  RaisedButton(
                    child: Text("Turn Off Device",
                        style: TextStyle(
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                            fontSize: 20.0
                        )
                    ),
                    color: Colors.red,
                    onPressed: _powerOff,
                  ),
                ],
              ),
            )
        )
    );
  }

  void _configDevice() {
//    widget.channel.write("CONFIG\n");
  }

  void _activeMode() {
//    widget.channel.write("ACTIVE\n");
  }

  void _sleepMode() {
//    widget.channel.write("SLEEP\n");
  }

  void _sendEmail() {
//    widget.channel.write("EMAIL\n");
  }

  void _powerOff() {
//    widget.channel.write("POWER\n");
  }

  @override
  void dispose() {
//    widget.channel.close();
    super.dispose();
  }
}