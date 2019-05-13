/// 接受到的邮件项，不含正文。
class ReceivedMailItem {
  String mailbox;
  String id;
  String from;
  String subject;
  String date;
  int size;
  bool seen;

  ReceivedMailItem();

  /// 把已经解序列化的ojb转换为本类对象
  static ReceivedMailItem fromJsonObj(obj) {
    var thisObj = ReceivedMailItem();
    thisObj.mailbox = obj['mailbox'];
    thisObj.id = obj['id'];
    thisObj.from = obj['from'];
    thisObj.subject = obj['subject'];
    thisObj.date = obj['date'];
    return thisObj;
  }
}
