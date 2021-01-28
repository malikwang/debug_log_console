# DebugLogConsole

Using a draggable and hoverable panel to display the key info/log of app state, network requests, etc. The info/log can be copied or shared as file.

#  Features

- The console is **Draggable** and can be **Minimized**.
- Each info/log can be added with a tag and level. Tags are free to add and have **Unread Count** reminder. Level is divided into Info/Warning/Error.
- The console implements: 
  - **Long Press to copy single log**
  - **Tap to display full content of single log**
  - **Copy recent 50/100 logs**
  - **Share all logs as .txt file**
  - **Clear all**

# Demo

| Show/Draggable/Minimized/Hide | Basic |
|:---:|:---:|
| ![](https://raw.githubusercontent.com/malikwang/debug_log_console/master/images/1.gif) | ![](https://raw.githubusercontent.com/malikwang/debug_log_console/master/images/2.gif) |

| Operation on single log | Operation on logs |
|:---:|:---:|
|![](https://raw.githubusercontent.com/malikwang/debug_log_console/master/images/3.gif) |![](https://raw.githubusercontent.com/malikwang/debug_log_console/master/images/4.gif) |

# How to use
**Use DebugLogConsole wrap app homepage.**

```dart
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
```

# Methods

```dart
logConsoleController.log(msg, tag: , level: );
```
| Parameter | Required | Format |
|---|---|---|
| `msg` | Yes |String||
| `tag` | No |String||
| `level` | No |DebugLogLevel||

```dart
logConsoleController.logInfo(msg, tag: );
logConsoleController.logWarning(msg, tag: );
logConsoleController.logError(msg, tag: );
```

# Notes

- Other params

| Parameter | Format | Description |
|---|---|---|
| `enableConsoleWriteLog` | Bool |**The default value is False and set to True when console is showing**. You can mannully change this value depends on your app env, for example, enable this flag when app in Debug env.|
| `logConsoleCapacity` | int |The max count of logs and default value is 1000. **The extra logs would not be cleared immediately, but at the timing of minimizing the console**.|

- About tag

There are two pre-defined tags in the console: 

| Tag | Description |
|---|---|
| `All` |All the logs also show in this tag.|
| `Default` |The parameter `tag` in logConsoleController.log(...) is optional, so these logs are untagged would show in this tag.|

# Future work

- Support custom icon.
- Support custom log level and color.
- Support change pre-defined tags.
