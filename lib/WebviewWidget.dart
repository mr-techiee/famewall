import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewWidget extends StatefulWidget {
  String? webUrl="";
  WebViewWidget({this.webUrl});
  @override
  _WebViewState createState() => _WebViewState();
}

class _WebViewState extends State<WebViewWidget> {

  final Completer<WebViewController> _controller =
  Completer<WebViewController>();

  var _stackToView = 1;

  void _handleLoad(String value) {
    setState(() {
      _stackToView = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Builder(builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.close, color: Colors.black,),
              onPressed: () {
                Navigator.pop(context);
              },
            );
          }),
          backgroundColor: Colors.white10,
          elevation: 0,
        ),
        body: IndexedStack(
          index: _stackToView,
          children: [
            Column(
              children: <Widget>[
                Expanded(
                    child: WebView(
                      initialUrl: widget.webUrl,
                      javascriptMode: JavascriptMode.unrestricted,
                      onPageFinished: _handleLoad,
                      onWebViewCreated: (WebViewController webViewController) {
                        _controller.complete(webViewController);
                      },
                    )),
              ],
            ),
            Container(
                child: Center(child: CircularProgressIndicator(),)
            ),
          ],
        ));
  }
}