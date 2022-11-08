import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

String ivivaUrl = 'https://dev-lucy.raseel.city';

String ivivaLoginUrl = '$ivivaUrl/Apps/Auth/userlogin';
String logoutURL = '$ivivaUrl/Apps/Auth/userlogout';
String ivivaGenerateApiUrl = '$ivivaUrl/Apps/System/generateapikey';

class OauthIvivaView extends StatefulWidget {
  const OauthIvivaView({super.key});

  @override
  State<OauthIvivaView> createState() => _OauthIvivaViewState();
}

class _OauthIvivaViewState extends State<OauthIvivaView> {
  @override
  Widget build(BuildContext context) {
    back(String? apikey) {
      Navigator.pop(context, apikey);
    }

    WebViewController? controllerEx;

    return Scaffold(
      body: SafeArea(
        child: WebView(
          userAgent: 'random',
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            controllerEx = webViewController;
          },
          onProgress: (int progress) async {
            String? _url = await controllerEx?.currentUrl();
            print(_url);
            print('WebView is loading (progress : $progress%)');
            // TODO - if any uxp url , this has to be done , wait until it fully loads
            if ((_url ?? "").contains("/Apps/UXP/ui/smart-parking") &&
                progress == 100) {
              await controllerEx?.loadUrl(ivivaGenerateApiUrl);
            }
          },
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          onPageFinished: (String url) async {
            print('Page finished loading: $url');
            if (url.endsWith('/Apps/Auth/userlogout')) {
              controllerEx?.clearCache();
              await controllerEx?.loadUrl(ivivaLoginUrl);
            }

            if (url.endsWith('/Apps/User/userdashboard') ||
                url.endsWith('/Apps/UXP/portal/regular')) {
              await controllerEx?.loadUrl(ivivaGenerateApiUrl);
            }
            if (url == ivivaGenerateApiUrl) {
              String? apikey = await controllerEx?.runJavascriptReturningResult(
                  "window.document.getElementById('apikey').innerHTML");
              print(apikey);

              back(apikey);
            }
          },
          initialUrl: logoutURL,
          navigationDelegate: (NavigationRequest request) async {
            return NavigationDecision.navigate;
          },
        ),
      ),
    );
  }
}
