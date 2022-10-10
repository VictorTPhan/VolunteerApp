import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:volunteer_app/main.dart';

import 'helper.dart';

class EventView extends StatefulWidget {
  const EventView({Key? key}) : super(key: key);

  @override
  State<EventView> createState() => EventViewState();
}

class EventViewState extends State<EventView> {

  EventInformation eventInformation = EventInformation("", "", "", "", "", "", "", "", 0);

  EventViewState() {
    fetchInfo();
  }

  //write a method that fetches information about an event given a timestamp
  Future<void> fetchInfo() async {
    await FirebaseDatabase.instance.ref().child("Events").child(EventToLookUp.lookup.UID).child(EventToLookUp.lookup.timeStamp).once().
    then((event) {
      var info = event.snapshot.value as Map;
      setState(() {
        eventInformation = EventInformation(
            info["description"],
            info["end time"],
            info["location"],
            info["name"],
            info["requirement"],
            info["spots"],
            info["start date"],
            info["start time"],
            0
        );
      });
    }).catchError((error) {
      print("Could not fetch info: " + error.toString());
    });
  }

  Widget scaffoldBody() {
    const TextStyle label = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );

    const TextStyle info = TextStyle(
        fontSize: 16
    );

    return Center(
      child: Column(
        children: [
          Expanded(
            flex: 7,
            child: Text(
              eventInformation.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          Expanded(
              flex: 25,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: ColorPalette.backgroundColor,
                      border: Border.all(
                        width: 4.0,
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20))
                  ),
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Description",
                            style: label
                        ),
                        Text(
                            "        " + eventInformation.description,
                            style: info
                        ),
                      ],
                    ),
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
                  decoration: BoxDecoration(
                      color: ColorPalette.backgroundColor,
                      border: Border.all(
                        width: 4.0,
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20))
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Requirement",
                            style: label
                        ),
                        Text(
                            "        " + eventInformation.requirement,
                            style: info
                        ),
                      ],
                    ),
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
                decoration: BoxDecoration(
                    color: ColorPalette.backgroundColor,
                    border: Border.all(
                      width: 4.0,
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(20))
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "General Information",
                        style: label,
                      ),
                      Text(
                        eventInformation.startDate,
                        style: info,
                      ),
                      Text(
                        eventInformation.startTime + " to " + eventInformation.endTime,
                        style: info,
                      ),
                      Text(
                        eventInformation.location,
                        style: info,
                      ),
                      Text(
                        "Spots: " + eventInformation.spots.toString(),
                        style: info,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: backgroundGradient(scaffoldBody())
    );
  }
}
