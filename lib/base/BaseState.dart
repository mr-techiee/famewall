import 'dart:async';

import 'package:flutter/cupertino.dart';

class BasePage extends StatefulWidget {
  BasePage({Key? key}) : super(key: key);

  @override
  BasePageState createState() => BasePageState();
}

class BasePageState<T extends BasePage> extends State<T>
    with WidgetsBindingObserver {

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }


}
