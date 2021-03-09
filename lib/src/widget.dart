import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'controller.dart';
import 'model.dart';

typedef IndexItemBuilder = Widget Function(int index);

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

Widget _buildConditionCell(bool isSelected, String content,
    {VoidCallback onTap}) {
  return GestureDetector(
    onTap: () {
      onTap?.call();
    },
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      margin: EdgeInsets.only(right: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.transparent,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Text(
        content,
        style: TextStyle(fontSize: 14, color: Colors.white),
        maxLines: 1,
      ),
    ),
  );
}

class _ConditionListView extends StatelessWidget {
  _ConditionListView({
    @required this.conditionName,
    @required this.itemCount,
    @required this.itemBuilder,
  });

  final String conditionName;
  final int itemCount;
  final IndexItemBuilder itemBuilder;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          conditionName,
          style: TextStyle(fontSize: 16, color: Colors.white),
          maxLines: 1,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Container(
              height: 30,
              child: ListView.builder(
                padding: EdgeInsets.all(0.0),
                shrinkWrap: true,
                itemBuilder: (_, index) {
                  return itemBuilder(index);
                },
                scrollDirection: Axis.horizontal,
                itemCount: itemCount,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LogTagListView extends StatefulWidget {
  @override
  __LogTagListViewState createState() => __LogTagListViewState();
}

class __LogTagListViewState extends State<_LogTagListView>
    with LogConsoleListener {
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
    return _ConditionListView(
      conditionName: 'Tag: ',
      itemCount: logConsoleController.tagList.length,
      itemBuilder: (index) {
        bool isSelected = logConsoleController.currentTagIndex == index;
        String tag = logConsoleController.tagList[index];
        int unreadCount = logConsoleController.getTagUnreadCount(tag);
        return Container(
          height: 40,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              _buildConditionCell(
                isSelected,
                tag,
                onTap: () {
                  logConsoleController.changeTag(index);
                },
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
          ),
        );
      },
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

  @override
  void onChangeLevel() {}
}

class _LogLevelListView extends StatefulWidget {
  @override
  __LogLevelListViewState createState() => __LogLevelListViewState();
}

class __LogLevelListViewState extends State<_LogLevelListView>
    with LogConsoleListener {
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
    return _ConditionListView(
      conditionName: 'Level: ',
      itemCount: logConsoleController.levelList.length,
      itemBuilder: (index) {
        bool isSelected = logConsoleController.currentLevelIndex == index;
        return _buildConditionCell(
          isSelected,
          logConsoleController.levelList[index],
          onTap: () {
            logConsoleController.changeLevel(index);
          },
        );
      },
    );
  }

  @override
  void onChangeCurrentLog() {}

  @override
  void onChangeSize(bool isFullScreen) {}

  @override
  void onChangeTag() {}

  @override
  void onToggleShow(bool isShowing) {}

  @override
  void onShowToast(String msg, bool showProgress) {}

  @override
  void onChangeLevel() {
    setState(() {});
  }
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

  @override
  void onChangeLevel() {}
}

class _LogTopFuncArea extends StatefulWidget {
  @override
  __LogTopFuncAreaState createState() => __LogTopFuncAreaState();
}

class __LogTopFuncAreaState extends State<_LogTopFuncArea> {
  TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: !logConsoleController.searchMode
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: _LogTagListView(),
                      ),
                      _LogLevelListView(),
                    ],
                  )
                : TextField(
                    controller: _textEditingController,
                    onSubmitted: (value) {
                      logConsoleController.searchLog(value);
                    },
                    style: TextStyle(color: Colors.blue),
                    decoration: InputDecoration(
                      filled: false,
                      isDense: true,
                      hintText: 'keywords, split with space',
                      hintStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                  ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: logConsoleController.searchMode
              ? [
                  _buildIconButton(
                    iconData: Icons.arrow_back,
                    onTap: () {
                      setState(() {
                        logConsoleController.resetSearchMode();
                      });
                    },
                  ),
                  _buildIconButton(
                    iconData: Icons.check,
                    onTap: () {
                      logConsoleController
                          .searchLog(_textEditingController.text);
                    },
                  ),
                ]
              : [
                  _buildIconButton(
                    iconData: Icons.remove,
                    onTap: logConsoleController.minConsole,
                  ),
                  _buildIconButton(
                    iconData: Icons.search,
                    onTap: () {
                      setState(() {
                        logConsoleController.searchMode = true;
                      });
                    },
                  ),
                ],
        ),
      ],
    );
  }
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
                style: TextStyle(color: Colors.white, fontSize: 8),
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
                style: TextStyle(color: Colors.white, fontSize: 6),
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

  @override
  void onChangeLevel() {}
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
                    _LogTopFuncArea(),
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
                  CircularProgressIndicator(),
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

  @override
  void onChangeLevel() {}
}
