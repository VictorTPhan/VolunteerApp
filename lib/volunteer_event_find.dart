import 'package:date_field/date_field.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:volunteer_app/volunteer_event_page.dart';

import 'helper.dart';
class VolunteerEventFind extends StatefulWidget {
  const VolunteerEventFind({Key? key}) : super(key: key);

  @override
  State<VolunteerEventFind> createState() => _VolunteerEventFindState();
}

class _VolunteerEventFindState extends State<VolunteerEventFind> {

  List<EventLookup> eventLookups = [];
  List<EventInformation> eventInfo = [];

  _VolunteerEventFindState()
  {
    fetchEventLookUps();
  }

  //fetch event lookups
  Future<void> fetchEventLookUps() async {

    //Events
      //UID
      //UID1
        //timestamp
        //timestamp
          //info goes here...
      //UID2

    await FirebaseDatabase.instance.ref().child("Events").once().
    then((event) {
      //list of users
      var users = event.snapshot.value as Map;

      //for every user
      users.forEach((UID, events) {
        //grab a list of all their timeStamps
        var eventList = events as Map;

        //for every timestamp in the list:
        eventList.forEach((timestamp, value) async {
          //check to see if the user already signed up
          bool signedUp = await didUserAlreadySignUp(UID, timestamp);

          print(signedUp);

          if (signedUp == false)
            {
              //add to list if user did not sign up
              setState(() {
                eventLookups.add(EventLookup(timestamp, UID));
                print("added: " + timestamp + " " + UID);
              });

              //search up data for event
              await fetchEventDate(UID, timestamp);
            }
        });
      });
    }).catchError((error) {
      print("Could not grab events: " + error.toString());
    });
  }

  //fetch event lookups for a given timestamp and uid
  Future<void> fetchEventDate(String UID, String timeStamp) async {
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

  //checker to see if the volunteer already signed up
  Future<bool> didUserAlreadySignUp(String UID, String timeStamp) async {
    bool result = true;

    await FirebaseDatabase.instance.ref().child("Events").child(UID).child(timeStamp).once().
    then((event) {
      var info = event.snapshot.value as Map;

      //does the event have any volunteers at all?
      if (info.containsKey("volunteers"))
        {
          var volunteers = info["volunteers"];

          //does our volunteer list contain this user?
          if (volunteers.containsKey(getUID()))
            {
              result = true;
            }
          else
            {
              result = false;
            }
        }
      else {
        result = false;
      }
    }).catchError((error) {
      print("Error in finding if user signed up for " + UID + " " + timeStamp + ": " + error.toString());
    });

    return result;
  }

  //check if user can sign up (is there space for the volunteer?)
  //sign up process

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

