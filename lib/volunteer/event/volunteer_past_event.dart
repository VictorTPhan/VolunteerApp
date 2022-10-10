import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:volunteer_app/main.dart';
import 'package:volunteer_app/volunteer/event/volunteer_event_page.dart';

import '../../helper.dart';
class VolunteerPastEvent extends StatefulWidget {
  const VolunteerPastEvent({Key? key}) : super(key: key);

  @override
  State<VolunteerPastEvent> createState() => _VolunteerPastEventState();
}

class _VolunteerPastEventState extends State<VolunteerPastEvent> {
  List<EventLookup> eventLookups = [];
  List<EventInformation> eventInfo = [];

  _VolunteerPastEventState() {
    fetchSignedUpEvents();
  }

  //before page loads,
  //1. fetch user's signed up events
  //2. determine which ones are over
  //3. show them

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
    bool fitsCriteria = false;

    await FirebaseDatabase.instance.ref().child("Events").child(UID).child(timeStamp).once().
    then((event) {
      var info = event.snapshot.value as Map;

      //the event started at (event start date + event start time)
      String startDateString = info["start date"].toString();
      var splitStartDate = startDateString.split("/");
      startDateString = "20" + splitStartDate[2] + "-" + splitStartDate[0] + "-" + splitStartDate[1];
      print(startDateString);

      String startTimeString = info["start time"].toString();
      int hour = int.parse(startTimeString.substring(0,2));
      if (startTimeString.contains("PM")) hour+=12;
      startTimeString = hour.toString() + ":" + startTimeString.substring(3, 5);
      startTimeString += ":00";

      DateTime eventEndTime = DateTime.parse(startDateString + " " + startTimeString);

      if (eventEndTime.compareTo(DateTime.now()) < 0)
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
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Past Events"),
        backgroundColor: ColorPalette.mainColor,
      ),
      body: backgroundGradient(
        ListView.separated(
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
                      eventInfo[index].startDate + ", from " + eventInfo[index].startTime + " to " + eventInfo[index].endTime,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      "Location: " + eventInfo[index].location,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      "Volunteers: " + eventInfo[index].volunteers.toString() + "/" + eventInfo[index].spots.toString(),
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            style: formattedButtonStyle(),
                            onPressed: () {
                              EventToLookUp.lookup = EventLookup(eventLookups[index].timeStamp, eventLookups[index].UID);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const VolunteerEventPage()),
                              );
                            },
                            child: Text("More Info")
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) => const Divider(),
        ),
      ),
    );
  }
}
