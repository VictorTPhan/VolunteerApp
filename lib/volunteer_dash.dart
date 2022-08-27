import 'package:flutter/material.dart';
import 'package:volunteer_app/volunteer_event_find.dart';
import 'package:volunteer_app/volunteer_event_view.dart';
import 'package:volunteer_app/volunteer_info.dart';

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

            Expanded(
              flex: 70,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const VolunteerEventView()),
                        );
                      },
                      child: Text("Viewing Events"),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const VolunteerEventFind()),
                        );
                      },
                      child: Text("Finding Events"),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 30,
              child: ElevatedButton(
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
            ),
          ],
        ),
      ),
    );
  }
}
