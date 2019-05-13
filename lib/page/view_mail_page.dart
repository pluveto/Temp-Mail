import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:study_flutter/model/config_runtime.dart';
import 'package:study_flutter/model/received_mail_item.dart';
import 'package:study_flutter/util/api.dart';

class ViewMailPage extends StatefulWidget {
  final ReceivedMailItem mailItem;
  ViewMailPage({Key key, @required this.mailItem}) : super(key: key);
  final state = ViewMailPageState();
  @override
  State<StatefulWidget> createState() => state;
  ViewMailPageState getState() => state;
}

class ViewMailPageState extends State<ViewMailPage> {
  /// 为了显示邮件正文，引入了一个WebView，HTML 就存在这个变量里
  var _mailUrl = "";
  var _mailLoaded = false;
  InAppWebViewController _controller;
  InAppWebView mailWebView;
  InAppWebView getMailWebView() {
    mailWebView = new InAppWebView(
      initialUrl: _mailUrl,
      onWebViewCreated: (InAppWebViewController controller) {
        if (!_mailLoaded) {
          _controller = controller;
          _loadHtmlFromAssets();
        }
      },
      onLoadStop: (InAppWebViewController controller, String url) {
        controller.injectScriptCode("!function() {"
            "    \"use strict\";"
            "    function e(e) {"
            "        try {"
            "            if (\"undefined\" == typeof console)"
            "                return;"
            "            \"error\"in console ? console.error(e) : console.log(e)"
            "        } catch (e) {}"
            "    }"
            "    function t(e) {"
            "        return d.innerHTML = '<a href=\"' + e.replace(/\"/g, \"&quot;\") + '\"></a>',"
            "        d.childNodes[0].getAttribute(\"href\") || \"\""
            "    }"
            "    function r(e, t) {"
            "        var r = e.substr(t, 2);"
            "        return parseInt(r, 16)"
            "    }"
            "    function n(n, c) {"
            "        for (var o = \"\", a = r(n, c), i = c + 2; i < n.length; i += 2) {"
            "            var l = r(n, i) ^ a;"
            "            o += String.fromCharCode(l)"
            "        }"
            "        try {"
            "            o = decodeURIComponent(escape(o))"
            "        } catch (u) {"
            "            e(u)"
            "        }"
            "        return t(o)"
            "    }"
            "    function c(t) {"
            "        for (var r = t.querySelectorAll(\"a\"), c = 0; c < r.length; c++)"
            "            try {"
            "                var o = r[c]"
            "                  , a = o.href.indexOf(l);"
            "                a > -1 && (o.href = \"mailto:\" + n(o.href, a + l.length))"
            "            } catch (i) {"
            "                e(i)"
            "            }"
            "    }"
            "    function o(t) {"
            "        for (var r = t.querySelectorAll(u), c = 0; c < r.length; c++)"
            "            try {"
            "                var o = r[c]"
            "                  , a = o.parentNode"
            "                  , i = o.getAttribute(f);"
            "                if (i) {"
            "                    var l = n(i, 0)"
            "                      , d = document.createTextNode(l);"
            "                    a.replaceChild(d, o)"
            "                }"
            "            } catch (h) {"
            "                e(h)"
            "            }"
            "    }"
            "    function a(t) {"
            "        for (var r = t.querySelectorAll(\"template\"), n = 0; n < r.length; n++)"
            "            try {"
            "                i(r[n].content)"
            "            } catch (c) {"
            "                e(c)"
            "            }"
            "    }"
            "    function i(t) {"
            "        try {"
            "            c(t),"
            "            o(t),"
            "            a(t)"
            "        } catch (r) {"
            "            e(r)"
            "        }"
            "    }"
            "    var l = \"/cdn-cgi/l/email-protection#\""
            "      , u = \".__cf_email__\""
            "      , f = \"data-cfemail\""
            "      , d = document.createElement(\"div\");"
            "    i(document),"
            "    function() {"
            "        var e = document.currentScript || document.scripts[document.scripts.length - 1];"
            "        e.parentNode.removeChild(e)"
            "    }()"
            "}();");
        controller.injectScriptCode("document.body.innerHTML = "
            "document.querySelector(\".mail-info\").outerHTML + "
            "\"<b>以下为正文</b><hr /> \" + "
            "document.querySelector(\".mail-content\").outerHTML;");
      },
    );
    return mailWebView;
  }

  @override
  Widget build(BuildContext ctxt) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("查看邮件"),
      ),
      body: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /*
              Text(widget.mailItem.subject,
                  textAlign: TextAlign.left, style: TextStyle(fontSize: 20)),
              Text('发件人：' + widget.mailItem.from, textAlign: TextAlign.left),
              Text('时间：' + widget.mailItem.date, textAlign: TextAlign.left),
              Text('正文：', textAlign: TextAlign.left),*/
              Expanded(child: getMailWebView())
            ],
          )),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  /// 申请一个文件地址（不读取文件，一般此时文件还出于待建立状态）
  Future<File> _getLocalHtmlFile() async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    return new File('$dir/mail.html');
  }

  void _writeLocalHtmlFile(String data) async {
    File file = await _getLocalHtmlFile();
    File afterFile = await file.writeAsString(data);
    setState(() {
      _mailUrl = afterFile.uri.toString();
      print("url" + _mailUrl);
    });
  }

  _loadHtmlFromAssets() async {
    var html =
        await Api.getMailHTML(ConfigRuntime.tempMail, widget.mailItem.id);
    _controller.loadUrl(Uri.dataFromString(html,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
    _writeLocalHtmlFile(html);
    print(html);
  }
}
