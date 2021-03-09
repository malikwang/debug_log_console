import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_extend/share_extend.dart';

import 'model.dart';

abstract class LogConsoleListener {
  void onChangeTag();
  void onChangeLevel();
  void onChangeCurrentLog();
  void onToggleShow(bool isShowing);
  void onChangeSize(bool isFullScreen);
  void onShowToast(String msg, bool showProgress);
}

bool enableConsoleWriteLog = false;
int logConsoleCapacity = 1000;

class DebugLogConsoleController {
  DebugLogConsoleController._() {
    _tagList = [_tagAll, _tagDefault];
    defaultTagLength = _tagList.length;
  }

  // logs in cache
  List<DebugLog> _logs = [];

  final List<LogConsoleListener> _listeners = [];

  // Default tags
  String _tagAll = 'All';
  String _tagDefault = 'Default';

  int defaultTagLength;
  List<String> _tagList = [];
  List<String> get tagList => _tagList;
  int _tagIndex = 0;

  List<String> get levelList {
    List<String> levels = ['All'];
    DebugLogLevel.values.forEach((level) {
      levels
          .add(level.toString().replaceAll('DebugLogLevel.', '').toUpperCase());
    });
    return levels;
  }

  int _levelIndex = 0;
  int get currentLevelIndex => _levelIndex;

  bool _writeLog = false;

  bool _fullScreen = false;
  bool _showing = false;

  Offset _offset;
  double minSize = 40;
  double margin = 20;

  set position(Offset offset) {
    Size deviceSize = window.physicalSize / window.devicePixelRatio;
    double x = offset.dx;
    double y = offset.dy;
    if (y < kToolbarHeight + 100) y = kToolbarHeight + 100;
    if (y > deviceSize.height - kBottomNavigationBarHeight)
      y = deviceSize.height - kToolbarHeight;
    if (!_fullScreen) {
      if (x <= deviceSize.width / 2) x = margin;
      if (x >= deviceSize.width / 2) x = deviceSize.width - margin - minSize;
    } else {
      // When Left or right drag exceed half width, auto minConsole
      if (x < 0 - consoleWidth / 2 ||
          x > deviceSize.width - margin - consoleWidth / 2) {
        minConsole();
      }
      x = margin;
    }
    _offset = Offset(x, y);
  }

  double get consoleWidth =>
      window.physicalSize.width / window.devicePixelRatio - 2 * margin;

  Offset get position {
    if (_offset == null) {
      _offset = Offset(margin, kToolbarHeight + 100);
    }
    if (isFullScreen && _offset.dx != margin) {
      _offset = Offset(margin, _offset.dy);
    }
    return _offset;
  }

  bool get isFullScreen => _fullScreen;
  bool get isShowing => _showing;

  bool searchMode = false;
  List<String> _keywords = [];

  void searchLog(String value) {
    searchMode = true;
    value = value.trim();
    if (value.isNotEmpty) {
      _keywords =
          value.split(' ').where((element) => element.isNotEmpty).toList();
    }
    _notifyCurrentLogChange();
  }

  void resetSearchMode() {
    searchMode = false;
    _keywords = [];
    _notifyCurrentLogChange();
  }

  List<DebugLog> get currentLogList {
    List<DebugLog> results;
    if (searchMode) {
      results = _logs;
      if (_keywords.isEmpty) return [];
      return results.where((log) {
        for (String keyword in _keywords) {
          if (log.msg.contains(keyword)) return true;
        }
        return false;
      }).toList();
    }
    if (currentIsAll) {
      results = _logs;
    } else {
      results = _fetchTagLogs(currentTag);
    }
    if (_levelIndex != 0) {
      results = results
          .where((e) => e.level == DebugLogLevel.values[_levelIndex - 1])
          .toList();
    }
    return results;
  }

  int get currentTagIndex => _tagIndex;
  String get currentTag => tagList[currentTagIndex];
  bool get currentIsAll => _tagIndex == 0;

  int getTagUnreadCount(String tag) {
    return _fetchTagLogs(tag).where((log) => !log.isRead).toList().length;
  }

  List<DebugLog> _fetchTagLogs(String tag) {
    return _logs.where((log) => log.tag == tag).toList();
  }

  void _awaitBuilding(Function callback) {
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      callback();
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        callback();
      });
    }
  }

  _notifySizeChange() {
    void callback() {
      for (final listener in _listeners) {
        listener?.onChangeSize(_fullScreen);
      }
    }

    _awaitBuilding(callback);
  }

  _notifyShowChange() {
    void callback() {
      for (final listener in _listeners) {
        listener?.onToggleShow(_showing);
      }
    }

    _awaitBuilding(callback);
  }

  _notifyTagChange() {
    void callback() {
      _notifyCurrentLogChange();
      for (final listener in _listeners) {
        listener?.onChangeTag();
      }
    }

    _awaitBuilding(callback);
  }

  _notifyLevelChange() {
    void callback() {
      _notifyCurrentLogChange();
      for (final listener in _listeners) {
        listener?.onChangeLevel();
      }
    }

    _awaitBuilding(callback);
  }

  _notifyCurrentLogChange() {
    void callback() {
      for (final listener in _listeners) {
        listener?.onChangeCurrentLog();
      }
    }

    _awaitBuilding(callback);
  }

  showToast(String msg, {bool showProgress = false}) {
    void callback() {
      for (final listener in _listeners) {
        listener?.onShowToast(msg, showProgress);
      }
    }

    _awaitBuilding(callback);
  }

  void maxConsole() {
    _fullScreen = true;
    _notifySizeChange();
  }

  void minConsole() {
    _fullScreen = false;
    _clearExtraLogs();
    _notifySizeChange();
  }

  void toggleSize() {
    _fullScreen = !_fullScreen;
    _notifySizeChange();
  }

  void showConsole() {
    // Remember previous write state.
    _writeLog = enableConsoleWriteLog;
    enableConsoleWriteLog = true;
    _showing = true;
    _notifyShowChange();
  }

  void removeConsole() {
    _showing = false;

    // Reset previous write state.
    enableConsoleWriteLog = _writeLog;
    _notifyShowChange();
  }

  void toggleShow() {
    _showing = !_showing;
    if (_showing) {
      showConsole();
    } else {
      removeConsole();
    }
  }

  void changeTag(int index) {
    _tagIndex = index;
    _fetchTagLogs(currentTag).forEach((log) {
      log.isRead = true;
    });
    _notifyTagChange();
  }

  void changeLevel(int index) {
    _levelIndex = index;
    _notifyLevelChange();
  }

  Future<Directory> _getLogShareDirectory() async {
    final document = await getTemporaryDirectory();
    final logDirectory = Directory('${document.path}/LogConsole/TmpShare');
    if (!(logDirectory.existsSync())) {
      logDirectory.createSync(recursive: true);
    }
    return logDirectory;
  }

  void clearAllLogs() {
    _logs = [];
    _notifyTagChange();
  }

  // Clear extra log beyond capacity
  // Clear timing：minimize console
  void _clearExtraLogs() {
    if (_logs.length > logConsoleCapacity) {
      _logs = _logs.sublist(_logs.length - logConsoleCapacity);
    }
  }

  void copyLog(int count) async {
    logConsoleController.showToast('', showProgress: true);
    List<DebugLog> tmpLogs = [];
    _logs.toList().reversed.forEach((log) {
      if (tmpLogs.length == count) return;
      tmpLogs.add(log);
    });
    String text = tmpLogs
        .map((log) => '[' + log.tag + ']' + log.toString())
        .toList()
        .join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    logConsoleController.showToast('Copied Success.');
  }

  void shareLog() async {
    logConsoleController.showToast('Processing...', showProgress: true);
    String text = _logs
        .toList()
        .reversed
        .map((log) => '[' + log.tag + ']' + log.toString())
        .toList()
        .join('\n');
    final shareDirectory = await _getLogShareDirectory();
    final shareFile = File(
        '${shareDirectory.path}/share_${DateTime.now().millisecondsSinceEpoch}.txt');
    // ignore: avoid_print
    print('log path: ' + shareFile.path);
    shareFile.writeAsStringSync(text, flush: true);
    await ShareExtend.share(shareFile.path, "file");
    logConsoleController.showToast('');
  }

  void log(String msg, {String tag, DebugLogLevel level}) {
    if (!enableConsoleWriteLog) return;

    if (tag == null || tag.isEmpty) {
      tag = _tagDefault;
    }

    level = level ?? DebugLogLevel.info;

    if ((msg?.isEmpty ?? true)) return;
    bool contained = tagList.contains(tag);
    if (!contained) {
      if (_tagList.length <= defaultTagLength) {
        _tagList.add(tag);
      } else {
        _tagList.insert(defaultTagLength, tag);
      }
    }
    DebugLog log = DebugLog(tag, msg,
        level: level, time: DateTime.now(), isRead: tag == tagList[_tagIndex]);
    _logs.add(log);
    if (tag == tagList[_tagIndex]) {
      _notifyCurrentLogChange();
    } else {
      _notifyTagChange();
    }
  }

  void logInfo(String msg, {String tag}) {
    log(msg, tag: tag, level: DebugLogLevel.info);
  }

  void logWarning(String msg, {String tag}) {
    log(msg, tag: tag, level: DebugLogLevel.warning);
  }

  void logError(String msg, {String tag}) {
    log(msg, tag: tag, level: DebugLogLevel.error);
  }

  void addListener(LogConsoleListener listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  bool removeListener(LogConsoleListener listener) {
    return _listeners.remove(listener);
  }
}

final DebugLogConsoleController logConsoleController =
    DebugLogConsoleController._();
