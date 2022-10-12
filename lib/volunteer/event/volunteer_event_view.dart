import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:volunteer_app/helper.dart';
import 'package:volunteer_app/main.dart';
import 'package:volunteer_app/volunteer/event/volunteer_event_page.dart';
import 'package:volunteer_app/volunteer/event/volunteer_past_event.dart';

class VolunteerEventView extends StatefulWidget {
  const VolunteerEventView({Key? key}) : super(key: key);

  @override
  State<VolunteerEventView> createState() => _VolunteerEventViewState();
}

class _VolunteerEventViewState extends State<VolunteerEventView> {

  //Signups
    //UID
      //UID1
        //timeStamp

  List<EventLookup> eventLookups = [];
  List<EventInformation> eventInfo = [];
  int amountOfPastEvents = 0;

  _VolunteerEventViewState() {
    fetchSignedUpEvents();
  }

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

  Future<bool> seeIfEventExists(String UID, String timeStamp) async {
    var result = await FirebaseDatabase.instance.ref().child("Events").child(UID).child(timeStamp).once();
    return result.snapshot.value != null;
  }

  Future<void> fetchEventData(String UID, String timeStamp) async {
    //if event doesn't exist, don't bother
    bool eventExists = await seeIfEventExists(UID, timeStamp);
    if (eventExists == false) {
      //remove event UID/timeStamp from your signUps
      await FirebaseDatabase.instance.ref().child("Signups").child(getUID()).child(UID).child(timeStamp).remove().
      then((value) {
        print("removed nonexistent event from sign up list");
      }).catchError((error) {
        print("Could not remove nonexistent event: " + error.toString());
      });
    };

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
        amountOfPastEvents++;
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
          amountOfPastEvents;
        });
    }
  }

  Future<void> leaveEvent(EventLookup lookup, int index) async {
    await FirebaseDatabase.instance.ref().child("Events").child(lookup.UID).child(lookup.timeStamp).child("volunteers").child(getUID()).remove().
    then((value) {
      print("removed event");
    }).catchError((error) {
      print("Could not leave event: " + error.toString());
    });

    await FirebaseDatabase.instance.ref().child("Signups").child(getUID()).child(lookup.UID).child(lookup.timeStamp).remove().
    then((value) {
      print("removed event from your list");
    }).catchError((error) {
      print("Could not update list: " + error.toString());
    });

    if (mounted)
      setState(() {
        eventInfo.removeAt(index);
        eventLookups.removeAt(index);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Events"),
        backgroundColor: ColorPalette.mainColor,
      ),
      body: backgroundGradient(
        (eventInfo.isEmpty)
            ?const Center(
              child: Text(
                  "You aren't part of any active events.",
                style: TextStyle(
                  fontSize: 20
                ),
              ),
            )
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
                        ElevatedButton(
                            style: formattedButtonStyle(),
                            onPressed: () {
                              leaveEvent(eventLookups[index], index);
                            },
                            child: Text("Leave event")
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
      floatingActionButton: amountOfPastEvents > 0?
        FloatingActionButton(
          backgroundColor: ColorPalette.mainColor,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VolunteerPastEvent()),
            );
          },
          child: Icon(Icons.remove_red_eye_outlined),
        ):Container()
    );
  }
}
