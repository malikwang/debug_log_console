import 'package:debug_log_console/debug_log_console.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DebugLogConsole',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DebugLogConsole(
        child: MyHomePage(title: 'DebugLogConsole'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _tagController;
  TextEditingController _msgController;

  int _selectedValue = 0;

  @override
  void initState() {
    _tagController = TextEditingController();
    _msgController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                onPressed: logConsoleController.showConsole,
                child: Text('Show Console'),
              ),
              FlatButton(
                onPressed: logConsoleController.removeConsole,
                child: Text('Hide Console'),
              ),
              Row(
                children: [
                  Container(
                    width: 50,
                    child: Text('Tag:'),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      style: TextStyle(fontSize: 12),
                      decoration: InputDecoration(
                          hintText: 'The tag of log, can be empty.'),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 50,
                    child: Text('Msg:'),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      style: TextStyle(fontSize: 12),
                      decoration: InputDecoration(
                          hintText: 'The content of log, cannot be empty.'),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 50,
                    child: Text('Level:'),
                  ),
                  DropdownButton(
                    value: _selectedValue,
                    items: [
                      DropdownMenuItem(
                        child: Text('Info',
                            style: TextStyle(color: Colors.greenAccent)),
                        value: 0,
                      ),
                      DropdownMenuItem(
                        child: Text('Warning',
                            style: TextStyle(color: Colors.orangeAccent)),
                        value: 1,
                      ),
                      DropdownMenuItem(
                        child: Text('Error',
                            style: TextStyle(color: Colors.redAccent)),
                        value: 2,
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedValue = value;
                      });
                    },
                  ),
                ],
              ),
              FlatButton(
                onPressed: () {
                  if (_msgController.text.isEmpty) {
                    logConsoleController
                        .showToast('The content of log cannot be empty.');
                  } else {
                    if (logConsoleController.isShowing) {
                      logConsoleController.log(
                        _msgController.text,
                        level: DebugLogLevel.values[_selectedValue],
                        tag: _tagController.text,
                      );
                    } else {
                      logConsoleController
                          .showToast('The log console is not showing!');
                    }
                  }
                },
                child: Text('Add log'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (logConsoleController.isShowing) {
            logConsoleController.logInfo(
              'Press Increment',
              tag: 'Increment',
            );
          } else {
            logConsoleController.showToast('The log console is not showing!');
          }
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
