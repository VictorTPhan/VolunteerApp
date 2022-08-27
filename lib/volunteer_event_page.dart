import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'helper.dart';

class VolunteerEventPage extends StatefulWidget {
  const VolunteerEventPage({Key? key}) : super(key: key);

  @override
  State<VolunteerEventPage> createState() => _VolunteerEventPageState();
}

class _VolunteerEventPageState extends State<VolunteerEventPage> {

  String name = "";
  String description = "";
  String startDate = "";
  String startTime = "";
  String endTime = "";
  String location = "";
  String requirement = "";
  String spots = "";

  _VolunteerEventPageState() {
    fetchInfo();
  }

  //write a method that fetches information about an event given a timestamp
  Future<void> fetchInfo() async {
    await FirebaseDatabase.instance.ref().child("Events").child(EventToLookUp.lookup.UID).child(EventToLookUp.lookup.timeStamp).once().
    then((event) {
      var info = event.snapshot.value as Map;
      setState(() {
        name = info["name"];
        description = info["description"];
        startDate = info["start date"];
        startTime = info["start time"];
        endTime = info["end time"];
        location = info["location"];
        requirement = info["requirement"];
        spots = info["spots"];
      });
    }).catchError((error) {
      print("Could not fetch info: " + error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(EventToLookUp.lookup.timeStamp),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 40,
              ),
            ),
            Text(
              description,
              style: TextStyle(
                  fontSize: 18
              ),
            ),
            Text(
              startDate,
              style: TextStyle(
                  fontSize: 18
              ),
            ),
            Text(
              startTime + " to " + endTime,
              style: TextStyle (
                  fontSize: 18
              ),
            ),
            Text(
              "Location: " + location,
              style: TextStyle(
                  fontSize: 18
              ),
            ),
            Text(
              "Requirements: " + requirement,
              style: TextStyle(
                  fontSize: 18
              ),
            ),
            Text(
              "Spots Needed: " + spots,
              style: TextStyle(
                  fontSize: 18
              ),
            )
          ],
        ),
      ),
    );
  }
}
