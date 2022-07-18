import 'package:flutter/material.dart';
import 'package:volunteer_app/VolunteerInfo.dart';

class VolunteerDash extends StatefulWidget {
  const VolunteerDash({Key? key}) : super(key: key);

  @override
  State<VolunteerDash> createState() => _VolunteerDashState();
}

class _VolunteerDashState extends State<VolunteerDash> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Volunteer Dash"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VolunteerInfo()),
                );
              },
              child: Text("Viewing Events"),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VolunteerInfo()),
                );
              },
              child: Text("Finding Events"),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VolunteerInfo()),
                );
              },
              child: Text("Viewing User Info"),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
