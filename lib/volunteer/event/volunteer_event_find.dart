import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:volunteer_app/main.dart';
import 'package:volunteer_app/volunteer/event/volunteer_event_page.dart';
import '../../helper.dart';

class VolunteerEventFind extends StatefulWidget {
  const VolunteerEventFind({Key? key}) : super(key: key);

  @override
  State<VolunteerEventFind> createState() => _VolunteerEventFindState();
}

class _VolunteerEventFindState extends State<VolunteerEventFind> {

  List<EventLookup> eventLookups = [];
  List<EventInformation> eventInfo = [];

  _VolunteerEventFindState() {
    fetchEventLookups();
  }

  Future<void> fetchEventLookups() async {
    await FirebaseDatabase.instance.ref().child("Events").once().
    then((event) async {
      var users = event.snapshot.value as Map;

      //for each user
      users.forEach((UID, events) {
        var eventList = events as Map;

        //for each timestamp
        eventList.forEach((timestamp, value) async {
          //check to see if user signed up for this
          bool signedUp = await didUserAlreadySignUp(UID, timestamp);
          print(signedUp);
          if (!signedUp)
            {
              //add timestamp to list
              setState(() {
                eventLookups.add(EventLookup(timestamp, UID));
                print("added: " + timestamp + " " + UID);
              });

              await fetchEventData(UID, timestamp);
            }
        });
      });
    }).catchError((error) {
      print("Could not grab events: " + error.toString());
    });
  }

  Future<bool> didUserAlreadySignUp(String UID, String timeStamp) async {
    //does it contain a volunteer section?]
      //yes, is the user in it?
        //no, return false
        //yes, return true
      //no, return false

    bool result = true;

    await FirebaseDatabase.instance.ref().child("Events").child(UID).child(timeStamp).once().
    then((event) {
      var info = event.snapshot.value as Map;
      //does it contain a volunteer section?
      if (info.containsKey("volunteers"))
        {
          var volunteers = info["volunteers"];

          //if yes, is the user in it?
          if (volunteers.containsKey(getUID()))
            {
              print("User already signed up for this event");
              result = true;
            }
          else
            {
              print("User did not sign up for this event");
              result = false;
            }
        }
      else
        {
          print("This event never had volunteers");
          result = false;
        }
    }).catchError((error) {
      print("Error in finding if user signed up for " + UID + " " + timeStamp + ": " + error.toString());
    });

    return result;
  }

  Future<void> fetchEventData(String UID, String timeStamp) async {
    var eventInformation;

    await FirebaseDatabase.instance.ref().child("Events").child(UID).child(timeStamp).once().
    then((event) {
      var info = event.snapshot.value as Map;

      //the event ended at (event start date + event end time)
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

      if (eventEndTime.compareTo(DateTime.now()) > 0) {
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
    await FirebaseDatabase.instance.ref().child("Events").child(UID).child(timeStamp).child("volunteers").once().
    then((event) {
      var info = event.snapshot.value as Map;
      eventInformation.volunteers = info.length;
    }).catchError((error) {
      print("There are no volunteers for: " + UID + " " + timeStamp);
    });

    setState(() {
      if (eventInformation != null) eventInfo.add(eventInformation);
    });
  }

  void checkIfCanSignUp(String UID, String timeStamp, EventInformation eventInfo, int index) async {
    //does it still have spots?
    if (int.parse(eventInfo.spots) <= eventInfo.volunteers)
      {
        return;
      }
    else
      {
        signUp(UID, timeStamp, index);
      }
  }

  Future<void> signUp(String UID, String timeStamp, int index) async {
    //add yourself to volunteer section
    await FirebaseDatabase.instance.ref().child("Events").child(UID).child(timeStamp).child("volunteers").update(
        {
          getUID() : getUID()
        }).then((value) {
       print("Signed up for event");
    }).catchError((error) {
      print("Could not sign up for event: " + error.toString());
    });

    //update your own internal list
    await FirebaseDatabase.instance.ref().child("Signups").child(getUID()).child(UID).update(
        {
          timeStamp: timeStamp
        }).then((value) {
          print("Updated sign up list");
    }).catchError((error) {
      print("Could not update sign up list: " + error.toString());
    });

    setState(() {
      eventLookups.removeAt(index);
      eventInfo.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Find Events"),
        backgroundColor: ColorPalette.mainColor,
      ),
      body: backgroundGradient(
        (eventInfo.isEmpty)
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      "Currently no events to look at right now. Come back later!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                      ),
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
                              checkIfCanSignUp(eventLookups[index].UID, eventLookups[index].timeStamp, eventInfo[index], index);
                            },
                            child: Text("Sign Up")
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
      )
    );
  }
}
