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

    const TextStyle label = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );

    const TextStyle info = TextStyle(
      fontSize: 16
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
                "Hosted by: ____",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            Expanded(
              flex: 25,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
                    color: Colors.lightBlueAccent[100],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Description",
                            style: label
                        ),
                        Text(
                            "        " + description,
                               style: info
                        ),
                      ],
                    ),
                  ),
                )
            ),
            Expanded(
                flex: 25,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
                    color: Colors.lightBlueAccent[100],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Requirement",
                          style: label
                        ),
                        Text(
                          requirement,
                          style: info
                        ),
                      ],
                    ),
                  ),
                )
            ),
            Expanded(
                flex: 25,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
                    color: Colors.lightBlueAccent[100],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "General Information",
                          style: label,
                        ),
                        Text(
                            startDate,
                            style: info,
                        ),
                        Text(
                          startTime + " to " + endTime,
                          style: info,
                        ),
                        Text(
                            location,
                            style: info,
                        ),
                        Text(
                            "spots: " + spots,
                          style: info,
                        ),
                      ],
                    ),
                  ),
                ),
            ),
          ],
        ),
      ),
    );
  }
}
