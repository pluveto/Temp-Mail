import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study_flutter/model/config_runtime.dart';
import 'package:study_flutter/model/received_mail_item.dart';
import 'package:study_flutter/page/view_mail_page.dart';
import 'package:study_flutter/util/api.dart';

// Flutter 的 widget 分为两种，一种是 StatelessWidget，
// 另一种则是 StatefulWidget，
// 前者一般用于静态内容的显示，而后者则用于存在交互和逻辑的内容。
// https://stackoverflow.com/questions/47501710/what-is-the-relation-between-stateful-and-stateless-widgets-in-flutter

/// 首页
class HomePage extends StatefulWidget {
  final state = HomePageState();
  @override
  State<StatefulWidget> createState() => state;
  HomePageState getState() => state;
}

// Flutter 的 StatefulWidget 为什么需要额外定义 state？
// https://www.v2ex.com/t/524171

// 有些Widget是Statful（有状态的），而其他的一些是Stateless（无状态的）。
// 比如继承自StatefulWidget的有Checkbox、Radio、Slider、Form等，

// 这些Widget用户都是可以做一些交互的,
// 同样的继承自StatelessWidget的Widget有Text、Icon等。

// 有状态和无状态的主要区别在于：
// 有状态的Widget在其内部都有一个state
// 用来标记是否发生了变化，然后调用setState()方法来更新自己。

// flutter 生命周期:
// https://segmentfault.com/a/1190000015211309

class HomePageState extends State<HomePage> {
  var tempMailTextEditingController = TextEditingController();
  var receivedEmailList = new List<ReceivedMailItem>();

  @override
  Widget build(BuildContext context) {
    var tempMainTextField = TextField(
        controller: tempMailTextEditingController,
        // 点击时复制
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
          Clipboard.setData(
              new ClipboardData(text: tempMailTextEditingController.text));
          _showToast(context, "复制成功");
        });

    var receivedEmailListView = ListView.builder(
      itemCount: receivedEmailList.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: FlutterLogo(size: 56.0),
            title: Text(receivedEmailList[index].subject),
            subtitle: Text('来自：' + receivedEmailList[index].from),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ViewMailPage(mailItem: receivedEmailList[index])));
            },
          ),
        );
      },
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
    );
    return Container(
        padding: const EdgeInsets.all(5.0),
        //艹他妈的，这缩进太特么恶心人！！！
        child: Row(
          children: <Widget>[
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('临时邮箱（点击复制）',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: tempMainTextField,
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('收件箱',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                receivedEmailListView
              ],
            )),
          ],
        ));
  }

  void _showToast(BuildContext context, String toastContent) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(toastContent),
        action: SnackBarAction(
            label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  // 在页面第一次打开后执行
  @override
  void initState() {
    super.initState();
    ConfigRuntime.loadConfig().then((res) {
      if (ConfigRuntime.tempMail == "") {
        _getTempMail();
        return;
      }
      //如果超过了12小时，也重新获取邮箱
      if (DateTime.now().millisecond > ConfigRuntime.applyTime + 43200000) {
        print('applyTime: ' + ConfigRuntime.applyTime.toString());
        print('now: ' + DateTime.now().millisecondsSinceEpoch.toString());
        print('later: ' + (ConfigRuntime.applyTime + 43200000).toString());
        _getTempMail();
        return;
      }
      tempMailTextEditingController.text =
          ConfigRuntime.tempMail + "@linshiyouxiang.net";
    });
  }

  /// 获取并**自动设置**临时邮箱，同时更新配置文件中获取邮箱的时间，并保存配置
  Future _getTempMail() async {
    // 当widget状态改变时, State 对象调用setState(), 告诉框架去重绘widget.
    // 重绘widget 其实就是重新执行build
    var _tempMail = await Api.getMailBox();
    ConfigRuntime.tempMail = _tempMail;
    ConfigRuntime.applyTime = DateTime.now().millisecondsSinceEpoch;
    await ConfigRuntime.saveConfig();
    setState(() {
      tempMailTextEditingController.text =
          ConfigRuntime.tempMail + "@linshiyouxiang.net";
    });
  }

  Future refreshMail() async {
    // 当widget状态改变时, State 对象调用setState(), 告诉框架去重绘widget.
    // 重绘widget 其实就是重新执行build
    if (ConfigRuntime.tempMail == "") return;
    var mails = await Api.getMails(ConfigRuntime.tempMail);
    setState(() {
      receivedEmailList = mails;
    });
  }
}
