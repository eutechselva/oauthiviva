import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:oauthiviva/user_details.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_route.dart';
import 'iviva_web_view.dart';

void main() {
  runApp(const MyApp());
}

String meURL = "http://lucy1.avles.local/Lucy/test/user_details";

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
  String? _apikey;
  @override
  void dispose() {
    super.dispose();
  }

  getApiKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _apikey = prefs.getString('apikey');
    setState(() {});
    return;
  }

  setApiKey(String? apiKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (apiKey != null) prefs.setString('apikey', apiKey);
    await getApiKey();
    return;
  }

  clearApiKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('apikey');
    await getApiKey();
    return;
  }

  getMyDetails() async {
    var client = http.Client();

    http.Response res = await client.get(
      Uri.parse(meURL),
      headers: {
        'Authorization': "APIKEY ${_apikey ?? ''}",
        "Content-Type": "application/x-www-form-urlencoded"
      },
    );
    print(res);
    userDetailsNavigate(res.body);
  }

  userDetailsNavigate(String userDetails) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailsScreen(
          details: userDetails,
        ),
      ),
    );
  }

  @override
  void initState() {
    getApiKey();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            _apikey == null
                ? ElevatedButton(
                    onPressed: () async {
                      //ivivaDetails(context);
                      String? apikey = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OauthIvivaView(),
                        ),
                      );
                      setApiKey(apikey);
                    },
                    child: const Text("iviva login details"),
                  )
                : Container(),
            _apikey != null
                ? ElevatedButton(
                    onPressed: () {
                      getMyDetails();
                    },
                    child: const Text("get my details"),
                  )
                : Container(),
            _apikey != null
                ? ElevatedButton(
                    onPressed: () async {
                      await clearApiKey();
                    },
                    child: const Text("clear apikey"),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
