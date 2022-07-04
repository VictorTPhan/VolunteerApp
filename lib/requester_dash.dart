import 'package:flutter/material.dart';

class RequesterDash extends StatefulWidget {
  const RequesterDash({Key? key}) : super(key: key);

  @override
  State<RequesterDash> createState() => _RequesterDashState();
}

class _RequesterDashState extends State<RequesterDash> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Requester Dash"),
      ),
      body: Column(
        children: [
          
        ],
      ),
    );
  }
}
