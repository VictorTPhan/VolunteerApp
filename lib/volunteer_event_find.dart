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

  List<int> timeStamps = [];
  List<String> associatedUID = [];
  List<dynamic> events = [];

  _VolunteerEventFindState()
  {
    fetchEventData();
  }

  Future<void> fetchEventData() async {
    await FirebaseDatabase.instance.ref().child("Events").child("PCjY9P8bWoNetIIMlGqLymdEBoG3").once().
    then((event) {
      var info = event.snapshot.value as Map;

      setState(() {
        info.forEach((key, value) {
          associatedUID.add("PCjY9P8bWoNetIIMlGqLymdEBoG3");
          timeStamps.add(int.parse(key));
          events.add(value);
        });
      });

    }).catchError((error) {
      print("could not fetch events: " + error.toString());
    });
  }

  Future<void> signUp(String UID, String timeStamp) async {
    await FirebaseDatabase.instance.ref().child("Events").child(UID).child(timeStamp).child("volunteers").update(
        {
          getUID() : getUID()
        }
    ).then((value) {
      print("Successfully signed up");
    }).catchError((error) {
      print("Could not sign up: " + error.toString());
    });

    await FirebaseDatabase.instance.ref().child("Signups").child(getUID()).child(UID).update(
        {
          timeStamp : timeStamp
        }
    ).then((value) {
      print("Updated sign up list");
    }).catchError((error) {
      print("Could not update list: " + error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Finding Events"),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: timeStamps.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            color: Colors.blue[100],
            child: Column(
              children: [
                Text(
                  associatedUID[index],
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold
                  ),
                ),
                Text(
                  events[index]["name"],
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold
                  ),
                ),
                Text(
                  events[index]["start date"] + ", from " + events[index]["start time"] + " to " + events[index]["end time"],
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                Text(
                  "Location: " + events[index]["location"],
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                Text(
                  "Volunteers: 3/" + events[index]["spots"],
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          PageInfo.UID = associatedUID[index];
                          PageInfo.timeStamp = timeStamps[index].toString();

                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const VolunteerEventPage()),
                          );
                        },
                        child: Text("More Info")
                    ),
                    ElevatedButton(
                        onPressed: () {
                          signUp(associatedUID[index], timeStamps[index].toString());
                        },
                        child: Text("Sign Up")
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

