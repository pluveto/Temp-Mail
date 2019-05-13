// 该类负责在内存保存配置
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class ConfigRuntime {
  /// 临时邮箱（不含后缀）
  static String tempMail = "";

  /// 获取到邮箱的时间
  static int applyTime = 0;
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localConfigFile async {
    final path = await _localPath;
    return File('$path/tmp-mail-config.json');
  }

  static Future<File> saveConfig() async {
    final file = await _localConfigFile;
    var map = Map<String, dynamic>();
    map['mail'] = tempMail;
    map['time'] = applyTime;
    return file.writeAsString(json.encode(map));
  }

  /// 加载配置文件（若错误则使用静态默认值）
  static Future loadConfig() async {
    try {
      final file = await _localConfigFile;
      String contents = await file.readAsString();
      await fromJsonObj(json.decode(contents));
    } finally {}
  }

  static Future fromJsonObj(json) async {
    tempMail = json['mail'];
    applyTime = json['time'];
  }
}
