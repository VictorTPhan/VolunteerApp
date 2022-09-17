import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:volunteer_app/volunteer_event_find.dart';
import 'package:volunteer_app/volunteer_event_view.dart';
import 'package:volunteer_app/volunteer_info.dart';

import 'helper.dart';

class VolunteerDash extends StatefulWidget {
  const VolunteerDash({Key? key}) : super(key: key);

  @override
  State<VolunteerDash> createState() => _VolunteerDashState();
}

class _VolunteerDashState extends State<VolunteerDash> {

  _VolunteerDashState() {
    fetchSignedUpEvents();
  }

  //fetch signed up events /
  //filter out events that are over /
  //calculate time until event starts
  //show user upcoming events

  List<EventLookup> eventLookups = [];
  List<EventInformation> eventInfo = [];
  List<int> upcomingTimes = [];

  Future<void> fetchSignedUpEvents() async {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    List<EventLookup> unfilteredEvents = [];

    await FirebaseDatabase.instance.ref().child("Signups").child(getUID()).once().
    then((event) async {
      var users = event.snapshot.value as Map;

      //for each user
      users.forEach((UID, events) {
        var eventList = events as Map;

        //for each timestamp
        eventList.forEach((timestamp, value) {
          unfilteredEvents.add(EventLookup(timestamp, UID));
          print(timestamp + " " + UID);
        });
      });
    }).catchError((error) {
      print("could not look at event:" + error.toString());
    });

    for(EventLookup eventLookup in unfilteredEvents)
    {
      await fetchEventData(eventLookup.UID, eventLookup.timeStamp);
    }
  }

  Future<void> fetchEventData(String UID, String timeStamp) async {
    var eventInformation;
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    DateTime eventEndTime = DateTime(0);
    bool fitsCriteria = false;

    await FirebaseDatabase.instance.ref().child("Events").child(UID).child(timeStamp).once().
    then((event) {
      var info = event.snapshot.value as Map;

      //the event ended at (event start date + event end time)
      String startDateString = info["start date"].toString();
      var splitStartDate = startDateString.split("/");
      startDateString = "20" + splitStartDate[2] + "-" + splitStartDate[0] + "-" + splitStartDate[1];

      String endTimeString = info["end time"].toString();
      endTimeString = endTimeString.substring(0, 5);
      endTimeString += ":00";

      eventEndTime = DateTime.parse(startDateString + " " + endTimeString);

      //what we want
      if (eventEndTime.millisecondsSinceEpoch >= currentTime)
      {
        eventInformation = EventInformation(
          info["description"],
          info["end time"],
          info["location"],
          info["name"],
          info["requirement"],
          info["spots"],
          info["start date"],
          info["start time"],
          0,
        );
        print(info["name"]);
        fitsCriteria = true;
      }
    }).catchError((error) {
      print("Could not fetch data for event: " + error.toString());
    });

    if (fitsCriteria)
    {
      //does it have any volunteers?
      await FirebaseDatabase.instance.ref().child("Events").child(UID).child(timeStamp).child("volunteers").once().
      then((event) {
        var info = event.snapshot.value as Map;
        eventInformation.volunteers = info.length;
      }).catchError((error) {
        print("There are no volunteers for: " + UID + " " + timeStamp);
      });

      //look up the event at the specified timestamp
      setState(() {
        eventLookups.add(EventLookup(timeStamp, UID));
        eventInfo.add(eventInformation);
        upcomingTimes.add(eventEndTime.difference(DateTime.now()).inDays);
      });
    }
  }

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
              flex: 50,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
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
                    ElevatedButton(
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
                    ElevatedButton(
                      onPressed: () {
                        VolunteerToLookUp.volunteerUID = getUID();
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
            ),
            Text(
              "Upcoming Events",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold
              ),
            ),
            Expanded(
              flex: 50,
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: eventInfo.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    color: Colors.blue[100],
                    child: Column(
                      children: [
                        Text(
                          eventInfo[index].name,
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        Text(
                          upcomingTimes[index] == 0? "Today": "In " + upcomingTimes[index].toString() + " days",

                        )
                      ],
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) => const Divider(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
