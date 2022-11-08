import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

String ivivaUrl = 'http://lucy1.avles.local';

String ivivaLoginUrl = '$ivivaUrl/Apps/Auth/userlogin';
String ivivaGenerateApiUrl = '$ivivaUrl/Apps/System/generateapikey';

class OauthIvivaView extends StatefulWidget {
  const OauthIvivaView({super.key});

  @override
  State<OauthIvivaView> createState() => _OauthIvivaViewState();
}

class _OauthIvivaViewState extends State<OauthIvivaView> {
  @override
  Widget build(BuildContext context) {
    back() {
      Navigator.pop(context);
    }

    WebViewController? controllerEx;

    return Scaffold(
      body: SafeArea(
        child: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            controllerEx = webViewController;
          },
          onProgress: (int progress) {
            print('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          onPageFinished: (String url) async {
            print('Page finished loading: $url');
            if (url.endsWith('/Apps/User/userdashboard')) {
              await controllerEx?.loadUrl(ivivaGenerateApiUrl);
            }
            if (url == ivivaGenerateApiUrl) {
              String? apikey = await controllerEx?.runJavascriptReturningResult(
                  "window.document.getElementById('apikey').innerHTML");
              print(apikey);
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('apikey', apikey ?? "");
              back();
            }
          },
          initialUrl: ivivaLoginUrl,
          navigationDelegate: (NavigationRequest request) async {
            return NavigationDecision.navigate;
          },
        ),
      ),
    );
  }
}
