enum DebugLogLevel {
  info,
  warning,
  error,
}

class DebugLog {
  DebugLog(
    this.tag,
    this.msg, {
    this.time,
    this.level = DebugLogLevel.info,
    this.isRead = false,
  });

  String tag;
  String msg;
  DateTime time;
  DebugLogLevel level;
  bool isRead;

  String get timeString {
    return "${time.month.toString().padLeft(2, '0')}-"
        "${time.day.toString().padLeft(2, '0')} ${time.hour.toString().padLeft(2, '0')}"
        ":${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}";
  }

  DebugLog.fromJson(Map<String, dynamic> json) {
    if (json != null) {
      tag = json['tag'];
      msg = json['msg'];
      time = DateTime.fromMillisecondsSinceEpoch(
          json['time'] ?? DateTime.now().millisecondsSinceEpoch);
      level = DebugLogLevel.values[json['level'] ?? 0];
      isRead = json['isRead'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['tag'] = this.tag;
    data['msg'] = this.msg;
    data['time'] = this.time.millisecondsSinceEpoch;
    data['level'] = DebugLogLevel.values.indexOf(this.level);
    data['isRead'] = this.isRead;
    return data;
  }

  @override
  String toString() {
    String prefix = '';
    switch (level) {
      case DebugLogLevel.info:
        prefix = 'Info ';
        break;
      case DebugLogLevel.warning:
        prefix = 'Warning ';
        break;
      case DebugLogLevel.error:
        prefix = 'Error ';
        break;
    }
    return prefix + timeString + ': ' + msg;
  }
}
