import 'package:flutter/material.dart';

class UserDetailsScreen extends StatefulWidget {
  final String details;
  const UserDetailsScreen({Key? key, required this.details}) : super(key: key);

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("User Details"),
        ),
        body: SafeArea(child: Text(widget.details)));
  }
}
