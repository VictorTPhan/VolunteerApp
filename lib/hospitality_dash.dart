import 'package:flutter/material.dart';
import 'package:volunteer_app/hospitality_info.dart';

class HospitalityDash extends StatefulWidget {
  const HospitalityDash({Key? key}) : super(key: key);

  @override
  State<HospitalityDash> createState() => _HospitalityState();
}

class _HospitalityState extends State<HospitalityDash> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hospitality Dash"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HospitalityInfo()),
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
                  MaterialPageRoute(builder: (context) => const HospitalityInfo()),
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
                  MaterialPageRoute(builder: (context) => const HospitalityInfo()),
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
