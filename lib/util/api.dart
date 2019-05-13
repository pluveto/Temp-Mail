import 'dart:io';

import 'dart:convert';

import 'package:study_flutter/model/received_mail_item.dart';

class Api {
  static Future<String> getHTML() async {
    var httpClient = new HttpClient();
    var uri = new Uri.https('www.linshiyouxiang.net', '/');
    var request = await httpClient.getUrl(uri);
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();
    return responseBody;
  }

  static Future<String> getMailBox() async {
    var url = "https://www.linshiyouxiang.net/api/v1/mailbox/keepalive";
    var httpClient = new HttpClient();
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();
    return json.decode(responseBody)['mailbox'];
  }

  /// 获取邮件列表。邮件列表项的模型见 model/ReceivedMailItem 类
  static Future<List<ReceivedMailItem>> getMails(String tempMail) async {
    var url = "https://www.linshiyouxiang.net/api/v1/mailbox/" + tempMail;
    var httpClient = new HttpClient();
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();
    List listRaw = json.decode(responseBody);
    List<ReceivedMailItem> list =
        listRaw.map((m) => ReceivedMailItem.fromJsonObj(m)).toList();

    return list;
  }

  static Future<String> getMailHTML(String username, String mailId) async {
    var httpClient = new HttpClient();
    var uri =
        new Uri.https('www.linshiyouxiang.net', '/mailbox/$username/$mailId');
    print("uri: " + uri.toString());
    var request = await httpClient.getUrl(uri);
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();
    return responseBody;
  }
}
