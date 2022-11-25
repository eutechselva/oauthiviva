import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

String ivivaUrl = 'https://dev-lucy.raseel.city';

String ivivaKeyCloackLoginUrl = '$ivivaUrl/IAM/LoginKeycloak/keycloak';
String ivivaGenerateApiUrl = '$ivivaUrl/Apps/System/generateapikey';

class IvivaAppBrowser extends InAppBrowser {
  final Completer<String> _completer = Completer<String>();
  var options = InAppBrowserClassOptions(
    crossPlatform: InAppBrowserOptions(
      hideUrlBar: false,
      toolbarTopBackgroundColor: Colors.white,
    ),
    inAppWebViewGroupOptions: InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        javaScriptEnabled: true,
        userAgent: 'random',
        cacheEnabled: false,
        clearCache: true,
      ),
    ),
  );

  @override
  Future onBrowserCreated() async {
    print("Browser Created!");
  }

  @override
  Future onLoadStart(url) async {
    print("Started $url");
  }

  @override
  Future onLoadStop(url) async {
    print("Stopped $url");
    String urlString = url.toString();

    if (urlString.endsWith('/Apps/User/userdashboard') ||
        urlString.endsWith('/Apps/UXP/portal/regular')) {
      hide();
      webViewController.loadUrl(
        urlRequest: URLRequest(
          url: Uri.parse(ivivaGenerateApiUrl),
        ),
      );
    }
    if (urlString == ivivaGenerateApiUrl) {
      var results = await webViewController.evaluateJavascript(
          source: "window.document.getElementById('apikey').innerHTML");

      print(results);
      close();
      _completer.complete(results.toString());
    }
  }

  @override
  void onLoadError(url, code, message) {
    print("Can't load $url.. Error: $message");
  }

  @override
  void onProgressChanged(progress) async {
    print("Progress: $progress");
    Uri? currentURL = await webViewController.getUrl();
    String urlString = currentURL.toString();
    print('urlString $urlString');

    if (urlString.contains('/Apps/UXP/ui/smart-parking')) {
      hide();
    }

    if (progress == 100 && urlString.contains('/Apps/UXP/ui/smart-parking')) {
      hide();
      webViewController.loadUrl(
        urlRequest: URLRequest(
          url: Uri.parse(ivivaGenerateApiUrl),
        ),
      );
    }
  }

  @override
  void onExit() {
    print("Browser closed!");
  }

  Future<String> getApiKey() async {
    await openUrlRequest(
        urlRequest: URLRequest(url: Uri.parse(ivivaKeyCloackLoginUrl)),
        options: options);

    return _completer.future;
  }
}

// class IvivaLoginAInAppView extends StatefulWidget {
//   const IvivaLoginAInAppView({super.key});

//   @override
//   State<IvivaLoginAInAppView> createState() => _IvivaLoginAInAppViewState();
// }

// class _IvivaLoginAInAppViewState extends State<IvivaLoginAInAppView> {
//   @override
//   Widget build(BuildContext context) {
//     return InAppWebView(
//       initialOptions: InAppWebViewGroupOptions(
//           crossPlatform: InAppWebViewOptions(
//         javaScriptEnabled: true,
//       )),
//     );
//   }
// }
