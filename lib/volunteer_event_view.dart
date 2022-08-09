import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'helper.dart';
class VolunteerEventView extends StatefulWidget {
  const VolunteerEventView({Key? key}) : super(key: key);

  @override
  State<VolunteerEventView> createState() => _VolunteerEventViewState();
}

class _VolunteerEventViewState extends State<VolunteerEventView> {

  List<int> timeStamps = [];
  List<dynamic> events = [];

  _VolunteerEventViewState()
  {
    fetchEventData();
  }

  Future<void> fetchEventData() async {
    await FirebaseDatabase.instance.ref().child("Events").child(getUID()).once().
    then((event) {
      var info = event.snapshot.value as Map;

      setState(() {
        info.forEach((key, value) {
          timeStamps.add(int.parse(key));
          events.add(value);
        });
      });

    }).catchError((error) {
      print("could not fetch events: " + error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Viewing Events"),
      ),
    );
  }
}

