import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'helper.dart';
class VolunteerEventView extends StatefulWidget {
  const VolunteerEventView({Key? key}) : super(key: key);

  @override
  State<VolunteerEventView> createState() => _VolunteerEventViewState();
}

class _VolunteerEventViewState extends State<VolunteerEventView> {

  List<EventLookup> eventLookups = [];
  List<EventInformation> eventInfo = [];

  _VolunteerEventViewState()
  {
    fetchSignedUpEvents();
  }
  
  Future<void> fetchSignedUpEvents() async {

    //Signups
      //Volunteer UID
        //Hospitality UID
          //timestamp

    //grab event lookup for every event the user signed up for
    await FirebaseDatabase.instance.ref().child("Signups").child(getUID()).once().
    then((event) {
      //contain list of hospitality users and the timestamp for events under it

      //Hospitality UID
        //timestamp
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

    //we have the event lookup, but no info for the events
    //so we will now grab it
    for (EventLookup eventLookup in eventLookups)
      {
        await fetchEventData(eventLookup.UID, eventLookup.timeStamp);
      }
  }

  //type             name                 parameters
  Future<void> fetchEventData(String UID, String timeStamp) async {
    var eventInformation;

    //Events
      //Hospitality UID
        //timestamp
          //desc
          //name
          //etc...

    //make firebase call based on the UID and the timestamp that we have
    await FirebaseDatabase.instance.ref().child("Events").child(UID).child(timeStamp).once().
    then((event) {
      //save whatever was under that spot as a variable
      var info = event.snapshot.value as Map;

      //grab everything we need
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

    //some events that don't have volunteers
    //they won't have a spot that says "volunteers"
    //let's assume that there no volunteers be default
    //check to see how many volunteers have signed up
    await FirebaseDatabase.instance.ref().child("Events").child(UID).child(timeStamp).child("volunteers").once().
    then((event) {
      //Events
        //hospitality
          //timestamp
            //info
            //volunteers
              //UID
              //UID2
              //UID3

      var info = event.snapshot.value as Map;
      eventInformation.volunteers = info.length;
    }).catchError((error) {
      print("There are no volunteers for: " + UID + " " + timeStamp);
    });

    setState(() {
      eventInfo.add(eventInformation);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Viewing Events"),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: eventInfo.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            color: Colors.blue[200],
            child: Column(
              children: [
                Text(eventInfo[index].name)
              ],
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
    );
  }
}

