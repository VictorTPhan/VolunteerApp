import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:volunteer_app/helper.dart';
import 'package:volunteer_app/main.dart';
import 'package:volunteer_app/volunteer/volunteer_public_profile.dart';

class HospitalityEventVolunteers extends StatefulWidget {
  const HospitalityEventVolunteers({Key? key}) : super(key: key);

  @override
  State<HospitalityEventVolunteers> createState() => _HospitalityEventVolunteersState();
}

class _HospitalityEventVolunteersState extends State<HospitalityEventVolunteers> {

  List<VolunteerData> users = [];

  _HospitalityEventVolunteersState() {
    fetchParticipants();
  }

  Future<void> fetchParticipants() async {
    List<String> UIDs = [];

    await FirebaseDatabase.instance.ref().child("Events").child(getUID()).child(EventToLookUp.lookup.timeStamp).child("volunteers").once().
    then((event) {
      var volunteers = event.snapshot.value as Map;
      volunteers.forEach((key, value) {
        UIDs.add(key);
      });
    }).catchError((error) {
      print("error fetching data: " + error.toString());
    });

    for(String UID in UIDs)
      {
        await FirebaseDatabase.instance.ref().child("Volunteers").child(UID).once().
        then((event) {
          var info = event.snapshot.value as Map;

          if (mounted)
            setState(() {
              users.add(
                  VolunteerData(
                      UID,
                      info["name"],
                      info["description"],
                      info["phone number"],
                      info["instrument"],
                      int.parse(info["age"])
                  )
              );
            });
        }).catchError((error) {
          print("could not fetch user data for user " + UID + ": " + error.toString());
        });
      }
  }

  Future<void> removeVolunteer(String UID) async {
    await FirebaseDatabase.instance.ref().child("Events").child(getUID()).child(EventToLookUp.lookup.timeStamp).child("volunteers").child(UID).remove().
    then((value) {
      print("Removed user " + UID + " from this event.");
    }).catchError((error) {
      print("Could not remove user from event: " + error.toString());
    });

    await FirebaseDatabase.instance.ref().child("Signups").child(UID).child(getUID()).child(EventToLookUp.lookup.timeStamp).remove().
    then((value) {
      print("Removed user signup " + UID + ".");
    }).catchError((error) {
      print("Could not remove user signup: " + error.toString());
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorPalette.mainColor,
        title: Text("See Volunteers"),
      ),
      body: backgroundGradient(
        ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: users.length,
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
              child: Column(
                children: [
                  Text(
                      users[index].name,
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold
                      ),
                  ),
                  Text(
                      users[index].phoneNumber,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                  ),
                  Text(users[index].instrument,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                          style: formattedButtonStyle(),
                          onPressed: () {
                            VolunteerToLookUp.volunteerUID = users[index].UID;

                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const VolunteerPublicProfile()),
                            );
                          },
                          child: Text("More Info")
                      ),
                      ElevatedButton(
                          style: formattedButtonStyle(),
                          onPressed: () {
                            removeVolunteer(users[index].UID).then((value) {
                              if (mounted)
                                setState(() {
                                  users.remove(users[index]);
                                });
                            });
                          },
                          child: Text("Remove")
                      ),
                    ],
                  )
                ],
              )
            );
          },
          separatorBuilder: (BuildContext context, int index) => const Divider(),
        ),
      ),
    );
  }
}
