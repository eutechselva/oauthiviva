import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:oauthiviva/user_details.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

String authorizeUrl = "https://mobile.v4.iviva.cloud/oauth2/auth";
String tokenUrl = "https://mobile.v4.iviva.cloud/oauth2/token";
String redirectUri = "com.example.oauthiviva://oauth2redirect";
String customUriScheme = "com.example.oauthiviva";
String clientId = "beb89a31b3ad85e77b5f5dfb47282c1d631df3b3cac1e3de";
String clientSecret =
    "a04074be51be3935f48ab6023edca976871a3690fb9afe694208f1ff297b90fdd4bc917238c696bc262807bd722adf87";
Iterable<String> scopes = ["user:read"];
String logoutUrl = "https://mobile.v4.iviva.cloud/Apps/Auth/userlogout";

class OauthIvivaView extends StatefulWidget {
  const OauthIvivaView({super.key});

  @override
  State<OauthIvivaView> createState() => _OauthIvivaViewState();
}

class _OauthIvivaViewState extends State<OauthIvivaView> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    var authCodeGrant = oauth2.AuthorizationCodeGrant(
      clientId,
      Uri.parse(authorizeUrl),
      Uri.parse(tokenUrl),
      secret: clientSecret,
      basicAuth: false,
    );

    Uri authorizationUrl = authCodeGrant
        .getAuthorizationUrl(Uri.parse(redirectUri), scopes: scopes);

    return Scaffold(
      body: WebView(
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
          webViewController.loadUrl(authorizationUrl.toString());
        },
        onProgress: (int progress) {
          print('WebView is loading (progress : $progress%)');
        },
        onPageStarted: (String url) {
          print('Page started loading: $url');
        },
        onPageFinished: (String url) {
          print('Page finished loading: $url');
        },
        initialUrl: logoutUrl,
        navigationDelegate: (NavigationRequest request) async {
          if (request.url.startsWith(redirectUri)) {
            print('redirectUri $request}');
            Uri responseUrl = Uri.parse(request.url);

            Client client = await authCodeGrant
                .handleAuthorizationResponse(responseUrl.queryParameters);
            var response = await client?.get(Uri.parse(
                "https://mobile.v4.iviva.cloud/Lucy/oauth_test/user_details"));
            if (response?.statusCode == 200) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UserDetailsScreen(
                          details: response?.body.toString() ?? "",
                        )),
              );
            }
          }

          return NavigationDecision.navigate;
        },
      ),
    );
  }
}
