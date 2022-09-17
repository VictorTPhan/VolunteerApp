import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:volunteer_app/helper.dart';
import 'package:volunteer_app/hospitality_event_page.dart';
import 'package:volunteer_app/hospitality_event_volunteers.dart';
class HospitalityEventView extends StatefulWidget {
  const HospitalityEventView({Key? key}) : super(key: key);

  @override
  State<HospitalityEventView> createState() => _HospitalityEventViewState();
}

class _HospitalityEventViewState extends State<HospitalityEventView> {
  List<int> timeStamps = [];
  List<EventInformation> eventInfo = [];
  
  _HospitalityEventViewState()
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

    await FirebaseDatabase.instance.ref().child("Events").child(getUID()).child(timeStamp).once().
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
          title: Text("Viewing Event")
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
                          onPressed: () {
                            EventToLookUp.lookup = EventLookup(timeStamps[index].toString(), getUID());

                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => HospitalityEventVolunteers()),
                            );
                          },
                          child: Text("Check Signups")
                      ),
                      ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => askDeletionPermission(context, timeStamps[index]),
                            );
                          },
                          child: Text("Delete Event")
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

