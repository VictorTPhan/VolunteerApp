import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:volunteer_app/volunteer/volunteer_info.dart';
import 'package:volunteer_app/volunteer/volunteer_account_settings.dart';
import 'package:volunteer_app/volunteer/event/volunteer_event_find.dart';
import 'package:volunteer_app/volunteer/event/volunteer_event_view.dart';

import '../helper.dart';
import '../main.dart';

class VolunteerDash extends StatefulWidget {
  const VolunteerDash({Key? key}) : super(key: key);

  @override
  State<VolunteerDash> createState() => _VolunteerDashState();
}

class _VolunteerDashState extends State<VolunteerDash> {


  //fetch signed up events /
  //filter out events that are over /
  //calculate time until event starts
  //show user upcoming events

  List<EventLookup> eventLookups = [];
  List<EventInformation> eventInfo = [];

  _VolunteerDashState() {
    fetchSignedUpEvents();
  }

  Future<void> fetchSignedUpEvents() async {
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
    DateTime eventEndTime = DateTime(0);
    bool fitsCriteria = false;

    await FirebaseDatabase.instance.ref().child("Events").child(UID).child(timeStamp).once().
    then((event) {
      var info = event.snapshot.value as Map;

      //the event started at (event start date + event start time)
      String startDateString = info["start date"].toString();
      var splitStartDate = startDateString.split("/");
      startDateString = "20" + splitStartDate[2] + "-" + splitStartDate[0] + "-" + splitStartDate[1];

      String startTimeString = info["start time"].toString();
      int hour = int.parse(startTimeString.substring(0,2));
      if (startTimeString.contains("PM")) hour+=12;
      startTimeString = hour.toString() + ":" + startTimeString.substring(3, 5);
      startTimeString += ":00";

      DateTime eventEndTime = DateTime.parse(startDateString + " " + startTimeString);
      print("END TIME: " + eventEndTime.toString());
      print("NOW: " + DateTime.now().toString());

      if (eventEndTime.compareTo(DateTime.now()) > 0)
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
      else {
        print("Ignored one event.");
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
      if (mounted)
        setState(() {
          eventLookups.add(EventLookup(timeStamp, UID));
          eventInfo.add(eventInformation);
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: backgroundGradient(
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 50,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 70,
                          width: 300,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const VolunteerEventView()),
                              );
                            },
                            child: Text("Viewing Events"),
                            style: formattedButtonStyle()
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 70,
                          width: 300,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const VolunteerEventFind()),
                              );
                            },
                            child: Text("Finding Events"),
                              style: formattedButtonStyle()
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 70,
                          width: 300,
                          child: ElevatedButton(
                            onPressed: () {
                              VolunteerToLookUp.volunteerUID = getUID();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const VolunteerInfo()),
                              );
                            },
                            child: Text("Viewing User Info"),
                              style: formattedButtonStyle()
                          ),
                        ),
                      ),
                    ],
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
                  child: (eventInfo.isEmpty)
                      ?Text("You haven't signed up for any events yet.")
                      :ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: eventInfo.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
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
                            children: [
                              Text(
                                eventInfo[index].name,
                                style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              Text(
                                "on " + eventInfo[index].startDate + ", at " + eventInfo[index].startTime,
                                style: TextStyle(
                                  fontSize: 20
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) => const Divider(),
                  ),
                )
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VolunteerDeletion()),
            );
          },
          child: Icon(Icons.settings),
        ),
      ),
    );
  }
}
