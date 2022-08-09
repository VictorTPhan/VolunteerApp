import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:volunteer_app/helper.dart';
import 'package:volunteer_app/hospitality_event_page.dart';
class HospitalityEventView extends StatefulWidget {
  const HospitalityEventView({Key? key}) : super(key: key);

  @override
  State<HospitalityEventView> createState() => _HospitalityEventViewState();
}

class _HospitalityEventViewState extends State<HospitalityEventView> {
  List<int> timeStamps = [];
  List<dynamic> events = [];
  
  _HospitalityEventViewState()
  {
    fetchEventData();
  }
  
  Future<void> fetchEventData() async {
    await FirebaseDatabase.instance.ref().child("Events").child(getUID()).once().
    then((event) {
      var info = event.snapshot.value as Map;

      setState(() {
        info.forEach((key, value) {
          timeStamps.add(int.parse(key));
          events.add(value);
        });
      });

    }).catchError((error) {
      print("could not fetch events: " + error.toString());
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Viewing Event")
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
                            TimeStamp.timeStamp = timeStamps[index].toString();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => HospitalityEventPage()),
                            );
                          },
                          child: Text("More Info")
                      ),
                      ElevatedButton(
                          onPressed: () {
                          },
                          child: Text("Check Signups")
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

