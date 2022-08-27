import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:volunteer_app/helper.dart';
import 'package:volunteer_app/volunteer_event_page.dart';

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

  _VolunteerEventViewState() {
    fetchSignedUpEvents();
  }

  Future<void> fetchSignedUpEvents() async {
    await FirebaseDatabase.instance.ref().child("Signups").child(getUID()).once().
    then((event) async {
      var users = event.snapshot.value as Map;

      //for each user
      users.forEach((UID, events) {
        var eventList = events as Map;

        //for each timestamp
        eventList.forEach((timestamp, value) {
          //add timestamp to list
          setState(() {
            eventLookups.add(EventLookup(timestamp, UID));
            print(timestamp + " " + UID);
          });
        });
      });
    }).catchError((error) {
      print("Could not grab events: " + error.toString());
    });

    for(EventLookup eventLookup in eventLookups)
      {
        await fetchEventData(eventLookup.UID, eventLookup.timeStamp);
      }
  }

  Future<void> fetchEventData(String UID, String timeStamp) async {
    var eventInformation;

    await FirebaseDatabase.instance.ref().child("Events").child(UID).child(timeStamp).once().
    then((event) {
      var info = event.snapshot.value as Map;

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
    }).catchError((error) {
      print("Could not grab event information: " + error.toString());
    });

    //does it have any volunteers?
    await FirebaseDatabase.instance.ref().child("Events").child(UID).child(timeStamp).child("volunteers").once().
    then((event) {
      var info = event.snapshot.value as Map;
      eventInformation.volunteers = info.length;
    }).catchError((error) {
      print("There are no volunteers for: " + UID + " " + timeStamp);
    });

    setState(() {
      eventInfo.add(eventInformation);
    });
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
      ),
      body: ListView.separated(
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
                        onPressed: () {
                          leaveEvent(eventLookups[index], index);
                        },
                        child: Text("Leave event")
                    ),
                  ],
                )
              ],
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
    );
  }
}
