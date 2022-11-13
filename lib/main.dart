import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:oauth2/oauth2.dart';
import 'package:oauthiviva/user_details.dart';
import 'app_route.dart';

void main() {
  runApp(const MyApp());
}

String ivivaURL = 'http://lucy1.avles.local';

String authorizeUrl = "$ivivaURL/oauth2/auth";
String tokenUrl = "$ivivaURL/oauth2/token";
String redirectUri = "com.example.oauthiviva://oauth2redirect";
String customUriScheme = "com.example.oauthiviva";
String clientId = "e52954b1e0a46bad3fef7b24eb0e45cec9e4bc0121189436";
String clientSecret =
    "7f63ed52b9f8d49e239d3c6ff83e2a057579186edbe6fdd9f584664abc07cfcd941d317cb718f3461add004dd2d5d58a";
Iterable<String> scopes = ["user:read"];
String logoutUrl = "$ivivaURL/Apps/Auth/userlogout";
String meURL = '$ivivaURL/Lucy/test/user_details';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sample Flutter app - iViva oauth',
      onGenerateRoute: AppRouteGenerator.generateRoute,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Sample Flutter app - iViva oauth'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> gitHubDetails(BuildContext context) async {}

  Future<void> googleDetails(BuildContext context) async {}

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future<dynamic> redirect() async {
      var authCodeGrant = oauth2.AuthorizationCodeGrant(
        clientId,
        Uri.parse(authorizeUrl),
        Uri.parse(tokenUrl),
        secret: clientSecret,
        basicAuth: false,
      );

      Uri authorizationUrl = authCodeGrant
          .getAuthorizationUrl(Uri.parse(redirectUri), scopes: scopes);

      final Completer completer = Completer();
      final flutterWebviewPlugin = FlutterWebviewPlugin();

      await flutterWebviewPlugin
          .launch(
        logoutUrl,
      )
          .whenComplete(() async {
        await Future.delayed(const Duration(seconds: 1));
        flutterWebviewPlugin.reloadUrl(authorizationUrl.toString());
      });
      flutterWebviewPlugin.onUrlChanged.listen((String redirectUrl) async {
        if (redirectUrl.contains("/Apps/Auth/userlogin") ||
            redirectUrl.contains("/Apps/Auth/userlogout") ||
            redirectUrl.contains(authorizeUrl)) {
        } else {
          flutterWebviewPlugin.close();
          flutterWebviewPlugin.dispose();

          Uri responseUrl = Uri.parse(redirectUrl);

          Client client = await authCodeGrant
              .handleAuthorizationResponse(responseUrl.queryParameters);

          completer.complete(client);

          return;
        }
      });

      return completer.future;
    }

    Future<void> ivivaDetails(BuildContext context) async {
      var client = await redirect();
      var response = await client?.get(Uri.parse(meURL));
      if (response?.statusCode == 200) {
        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UserDetailsScreen(
                    details: response?.body.toString() ?? "",
                  )),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                gitHubDetails(context);
              },
              child: const Text("Github login details"),
            ),
            ElevatedButton(
              onPressed: () {
                googleDetails(context);
              },
              child: const Text("google login details"),
            ),
            ElevatedButton(
              onPressed: () {
                ivivaDetails(context);
              },
              child: const Text("iviva login details"),
            ),
          ],
        ),
      ),
    );
  }
}
