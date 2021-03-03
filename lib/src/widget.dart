import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'controller.dart';
import 'model.dart';

Widget _buildIconButton({
  IconData iconData,
  VoidCallback onTap,
  EdgeInsetsGeometry padding,
}) {
  return GestureDetector(
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: padding ?? EdgeInsets.all(8),
      child: Icon(
        iconData,
        color: Colors.white,
      ),
    ),
    onTap: onTap,
  );
}

class _LogTagListView extends StatefulWidget {
  @override
  __LogTagListViewState createState() => __LogTagListViewState();
}

class __LogTagListViewState extends State<_LogTagListView>
    with LogConsoleListener {
  Widget _buildTagView(bool isSelected, String tag, {int unreadCount = 0}) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 5,
          ),
          margin: EdgeInsets.only(top: 10, right: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.transparent,
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.blue,
              width: 1,
            ),
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: Text(
            tag,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? Colors.white : Colors.blue,
            ),
            maxLines: 1,
          ),
        ),
        if (unreadCount > 0)
          Positioned(
            child: Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Text(
                '+$unreadCount',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                ),
                maxLines: 1,
              ),
            ),
            top: 0,
            right: 0,
          ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    logConsoleController.addListener(this);
  }

  @override
  void dispose() {
    logConsoleController.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            'Tags:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
            maxLines: 1,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: ListView.builder(
              shrinkWrap: true,
              itemBuilder: (_, index) {
                bool isSelected = logConsoleController.currentTagIndex == index;
                String tag = logConsoleController.tagList[index];
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    logConsoleController.changeTag(index);
                  },
                  child: _buildTagView(isSelected, tag,
                      unreadCount: logConsoleController.getTagUnreadCount(tag)),
                );
              },
              scrollDirection: Axis.horizontal,
              itemCount: logConsoleController.tagList.length,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void onChangeCurrentLog() {}

  @override
  void onChangeSize(bool isFullScreen) {}

  @override
  void onChangeTag() {
    setState(() {});
  }

  @override
  void onToggleShow(bool isShowing) {}

  @override
  void onShowToast(String msg, bool showProgress) {}
}

class _TapShowAll extends StatefulWidget {
  _TapShowAll({@required this.log});

  final DebugLog log;
  @override
  __TapShowAllState createState() => __TapShowAllState();
}

class __TapShowAllState extends State<_TapShowAll> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    DebugLog log = widget.log;
    Color color = Colors.greenAccent;
    if (log.level == DebugLogLevel.warning) {
      color = Colors.orangeAccent;
    }
    if (log.level == DebugLogLevel.error) {
      color = Colors.redAccent;
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () async {
        String text = '【' + log.tag + '】' + log.toString();
        await Clipboard.setData(ClipboardData(text: text));
        logConsoleController.showToast('Copied Success.');
      },
      onTap: () {
        setState(() {
          _showAll = true;
        });
      },
      child: Container(
        alignment: Alignment.centerLeft,
        child: _showAll
            ? Text(
                '${logConsoleController.currentIsAll ? '【' + log.tag + '】' : ''}' +
                    log.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Text(
                '${logConsoleController.currentIsAll ? '【' + log.tag + '】' : ''}' +
                    log.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
      ),
    );
  }
}

class _LogContentView extends StatefulWidget {
  @override
  __LogContentViewState createState() => __LogContentViewState();
}

class __LogContentViewState extends State<_LogContentView>
    with LogConsoleListener {
  Widget get emptyView {
    return Container(
      alignment: Alignment.center,
      child: Text(
        'Empty',
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  void initState() {
    logConsoleController.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    logConsoleController.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (logConsoleController.currentLogList.isEmpty) {
      return emptyView;
    }
    return Container(
      key: PageStorageKey<String>(logConsoleController.currentTag),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.all(0.0),
        itemBuilder: (_, index) => _TapShowAll(
            log: logConsoleController.currentLogList.reversed.elementAt(index)),
        separatorBuilder: (_, __) => Divider(
          color: Colors.white,
        ),
        itemCount: logConsoleController.currentLogList.length,
      ),
    );
  }

  @override
  void onChangeCurrentLog() {
    setState(() {});
  }

  @override
  void onChangeSize(bool isFullScreen) {}

  @override
  void onChangeTag() {}

  @override
  void onToggleShow(bool isShowing) {}

  @override
  void onShowToast(String msg, bool showProgress) {}
}

class _LogBottomAction extends StatefulWidget {
  @override
  __LogBottomActionState createState() => __LogBottomActionState();
}

class __LogBottomActionState extends State<_LogBottomAction>
    with LogConsoleListener {
  @override
  void initState() {
    logConsoleController.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    logConsoleController.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (logConsoleController.currentTagIndex != 0) return Container();
    return Row(
      children: [
        Expanded(
          child: Container(
            alignment: Alignment.centerLeft,
            child: _buildIconButton(
              iconData: Icons.cleaning_services,
              onTap: logConsoleController.clearAllLogs,
            ),
          ),
        ),
        _buildIconButton(
          iconData: Icons.ios_share,
          onTap: logConsoleController.shareLog,
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            _buildIconButton(
              iconData: Icons.copy,
              onTap: () => logConsoleController.copyLog(50),
            ),
            Positioned(
              right: 13,
              bottom: 13,
              child: Text(
                '50',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                ),
              ),
            ),
          ],
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            _buildIconButton(
              iconData: Icons.copy,
              onTap: () => logConsoleController.copyLog(100),
            ),
            Positioned(
              right: 13,
              bottom: 15,
              child: Text(
                '100',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 6,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void onChangeCurrentLog() {}

  @override
  void onChangeSize(bool isFullScreen) {}

  @override
  void onChangeTag() {
    setState(() {});
  }

  @override
  void onShowToast(String msg, bool showProgress) {}

  @override
  void onToggleShow(bool isShowing) {}
}

class DebugLogConsole extends StatefulWidget {
  DebugLogConsole({
    @required this.child,
  });

  final Widget child;
  @override
  _DebugLogConsoleState createState() => _DebugLogConsoleState();
}

class _DebugLogConsoleState extends State<DebugLogConsole>
    with LogConsoleListener {
  OverlayEntry _overlayEntry;
  OverlayEntry _toast;
  bool _fullScreen = false;

  void _insertOverlay() {
    _buildOverlay();
    Overlay.of(context).insert(_overlayEntry);
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry.remove();
      _overlayEntry = null;
    }
  }

  _updateView() {
    if (logConsoleController.isShowing) {
      if (_fullScreen != logConsoleController.isFullScreen) {
        _removeOverlay();
        _fullScreen = logConsoleController.isFullScreen;
      }
      if (_overlayEntry == null) {
        _insertOverlay();
      }
    } else {
      _removeOverlay();
    }
  }

  Widget get tagListView {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(vertical: 10),
      height: 40,
      child: Row(
        children: [
          Expanded(child: _LogTagListView()),
          _buildIconButton(
            iconData: Icons.remove,
            onTap: logConsoleController.minConsole,
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget get minView {
    return GestureDetector(
      onTap: logConsoleController.maxConsole,
      child: Container(
        width: logConsoleController.minSize,
        height: logConsoleController.minSize,
        child: Icon(
          Icons.data_usage,
          color: Colors.white,
        ),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.all(
            Radius.circular(logConsoleController.minSize / 2),
          ),
        ),
      ),
    );
  }

  Widget get maxView {
    return ClipRRect(
      key: GlobalKey(),
      borderRadius: BorderRadius.all(Radius.circular(10)),
      child: Material(
        child: Container(
          width: logConsoleController.consoleWidth,
          height: MediaQuery.of(context).size.height / 2,
          color: Colors.grey.withOpacity(0.7),
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    tagListView,
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.symmetric(
                              horizontal: BorderSide(color: Colors.white)),
                        ),
                        child: _LogContentView(),
                      ),
                    ),
                  ],
                ),
              ),
              _LogBottomAction(),
            ],
          ),
        ),
        color: Colors.transparent,
      ),
    );
  }

  void _buildOverlay() {
    Widget consoleWidget =
        logConsoleController.isFullScreen ? maxView : minView;
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: logConsoleController.position.dy,
          left: logConsoleController.position.dx,
          child: Draggable(
            child: consoleWidget,
            feedback: consoleWidget,
            childWhenDragging: Container(),
            ignoringFeedbackSemantics: false,
            onDraggableCanceled: (Velocity velocity, Offset offset) {
              logConsoleController.position = offset;
            },
          ),
        );
      },
    );
  }

  void _removeToast() {
    if (_toast != null) {
      _toast.remove();
      _toast = null;
    }
  }

  @override
  void initState() {
    logConsoleController.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    logConsoleController.removeListener(this);
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void onChangeCurrentLog() {}

  @override
  void onChangeSize(bool isFullScreen) {
    _updateView();
  }

  @override
  void onChangeTag() {}

  @override
  void onToggleShow(bool isShowing) {
    _updateView();
  }

  @override
  void onShowToast(String msg, bool showProgress) {
    _removeToast();
    if (msg == null || msg.isEmpty) return;
    _toast = OverlayEntry(
      builder: (context) {
        if (showProgress) {
          return Center(
            child: Container(
              alignment: Alignment.center,
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Platform.isAndroid
                      ? CircularProgressIndicator()
                      : Theme(
                          data: ThemeData.dark(),
                          child: CupertinoActivityIndicator(
                            radius: 15,
                          ),
                        ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Material(
                      child: Text(
                        msg,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      color: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Center(
          child: IntrinsicHeight(
            child: IntrinsicWidth(
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Material(
                  child: Text(
                    msg,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(_toast);
    if (!showProgress) {
      Future.delayed(Duration(seconds: 1)).then((value) {
        _removeToast();
      });
    }
  }
}
