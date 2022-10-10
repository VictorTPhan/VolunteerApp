import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:volunteer_app/helper.dart';
import 'package:volunteer_app/hospitality/event/hospitality_event_page.dart';
import 'package:volunteer_app/main.dart';

import 'hospitality_event_volunteers.dart';
class HospitalityPastEvent extends StatefulWidget {
  const HospitalityPastEvent({Key? key}) : super(key: key);

  @override
  State<HospitalityPastEvent> createState() => _HospitalityPastEventState();
}

class _HospitalityPastEventState extends State<HospitalityPastEvent> {
  List<int> timeStamps = [];
  List<EventInformation> eventInfo = [];

  _HospitalityPastEventState()
  {
    fetchEventInfo();
  }

  Future<void> fetchEventInfo() async {
    await FirebaseDatabase.instance.ref().child("Events").child(getUID()).once().
    then((event) {
      var info = event.snapshot.value as Map;

      setState(() {
        info.forEach((key, value) {
          timeStamps.add(int.parse(key));
        });
      });

    }).catchError((error) {
      print("could not fetch events: " + error.toString());
    });

    for(int timeStamp in timeStamps)
    {
      await fetchEventData(timeStamp.toString());
    }
  }

  Future<void> fetchEventData(String timeStamp) async {
    var eventInformation;

    int currentTime = DateTime.now().millisecondsSinceEpoch;

    await FirebaseDatabase.instance.ref().child("Events").child(getUID()).child(timeStamp).once().
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
      }
      print(info["name"]);
    }).catchError((error) {
      print("Could not grab event information: " + error.toString());
    });

    //does it have any volunteers?
    await FirebaseDatabase.instance.ref().child("Events").child(getUID()).child(timeStamp).child("volunteers").once().
    then((event) {
      var info = event.snapshot.value as Map;
      eventInformation.volunteers = info.length;
    }).catchError((error) {
      print("There are no volunteers for: " + getUID() + " " + timeStamp);
    });

    setState(() {
      if (eventInformation != null) eventInfo.add(eventInformation);
    });
  }

  Future<void> deleteEvent(int timeStamp) async{
    await FirebaseDatabase.instance.ref().child("Events").child(getUID()).child(timeStamp.toString()).remove().then((value) async{
      setState(() {
        eventInfo.clear();
      });
      await fetchEventInfo();
    });
  }

  Widget askDeletionPermission(BuildContext context, int timeStamp) {
    return SingleChildScrollView(
      child: AlertDialog(
        title: Text('Are you sure you want to delete this event?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
                onPressed: () {
                  deleteEvent(timeStamp);
                  Navigator.pop(context);
                },
                child: Text("Yes")
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("No")
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: ColorPalette.mainColor,
          title: Text("Past Events")
      ),
      body: backgroundGradient((eventInfo.isEmpty)
          ?Center(child: Text("You haven't made any events yet."))
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
                            TimeStamp.timeStamp = timeStamps[index].toString();
                            EventToLookUp.lookup = EventLookup(timeStamps[index].toString(), getUID());
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => HospitalityEventPage()),
                            );
                          },
                          child: Text("More Info")
                      ),
                      ElevatedButton(
                          style: formattedButtonStyle(),
                          onPressed: () {
                            EventToLookUp.lookup = EventLookup(timeStamps[index].toString(), getUID());

                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => HospitalityEventVolunteers()),
                            );
                          },
                          child: Text("Check Signups")
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),)
    );
  }
}

