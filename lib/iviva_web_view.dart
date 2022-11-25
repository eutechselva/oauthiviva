import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

String ivivaUrl = 'https://dev-lucy.raseel.city';

String ivivaKeyCloackLoginUrl = '$ivivaUrl/IAM/LoginKeycloak/keycloak';
String ivivaGenerateApiUrl = '$ivivaUrl/Apps/System/generateapikey';

class OauthIvivaView extends StatefulWidget {
  const OauthIvivaView({super.key});

  @override
  State<OauthIvivaView> createState() => _OauthIvivaViewState();
}

class _OauthIvivaViewState extends State<OauthIvivaView> {
  void initState() {
    super.initState();
    // Enable virtual display.
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    WebViewController? controllerEx;
    back(String? apikey) {
      apikey = apikey?.replaceAll('"', "");
      Navigator.pop(context, apikey);
    }

    return Scaffold(
      body: SafeArea(
        child: WebView(
          userAgent: 'random',
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            webViewController.clearCache();
            controllerEx = webViewController;
            final cookieManager = CookieManager();
            cookieManager.clearCookies();
          },
          onProgress: (int progress) async {
            String? _url = await controllerEx?.currentUrl();
            print('WebView is loading (progress : $progress%) $_url');

            // TODO - if any uxp url , this has to be done , wait until it fully loads
            if (((_url ?? "").contains("/Apps/UXP/ui/smart-parking") ||
                    (_url ?? "").endsWith('/Apps/UXP/portal/regular')) &&
                progress == 100) {
              await controllerEx?.loadUrl(ivivaGenerateApiUrl);
            }
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

              back(apikey);
            }
          },
          initialUrl: ivivaKeyCloackLoginUrl,
          navigationDelegate: (NavigationRequest request) async {
            return NavigationDecision.navigate;
          },
        ),
      ),
    );
  }
}
