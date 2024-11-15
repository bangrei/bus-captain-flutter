import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewPage extends StatefulWidget {
  static const path = '/webview';

  WebviewPage({Key? key}) : super(key: key);

  @override
  _WebviewPageState createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {
  final _webViewController = WebViewController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String url = (ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>)['url'];
    return Scaffold(
      appBar: AppBar(
        title: const Text("", textScaler: TextScaler.noScaling,),
      ),
      body: WebViewWidget(
        controller: _webViewController
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(url))
        ),
      );
  }
}