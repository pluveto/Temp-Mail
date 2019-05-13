import 'package:flutter/material.dart';

import 'page/home_page.dart';

//加载配置文件

void main() {
  runApp(MyApp());
}

class MyApp extends MaterialApp {
  //     Scaffold 实现了基本的 Material 布局。
  // 只要是在 Material 中定义了的单个界面显示的
  // 布局控件元素，都可以使用 Scaffold 来绘制。
  //
  //     提供展示抽屉（drawers，比如：左边栏）、通知
  //（snack bars） 以及 底部按钮（bottom sheets）。

  //     我们可以将 Scaffold 理解为一个布局的容器。
  // 可以在这个容器中绘制我们的用户界面。

  // http://blog.chengyunfeng.com/?p=1042

  final homePage = new HomePage();
  Widget get home => Scaffold(
        appBar: AppBar(
          title: const Text("Temp Mail"),
        ),
        // 写不写new是可选的
        body: homePage,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            homePage.getState().refreshMail();
          },
          child: Icon(Icons.thumb_up),
          backgroundColor: Colors.pink,
        ),
      );
}
