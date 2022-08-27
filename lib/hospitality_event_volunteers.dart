import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:volunteer_app/helper.dart';
import 'package:volunteer_app/volunteer_public_profile.dart';

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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(EventToLookUp.lookup.timeStamp),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: users.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            color: Colors.blue[100],
            child: Column(
              children: [
                Text(users[index].name),
                Text(users[index].phoneNumber),
                Text(users[index].instrument),
                ElevatedButton(
                    onPressed: () {
                      VolunteerToLookUp.volunteerUID = users[index].UID;

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const VolunteerPublicProfile()),
                      );
                    },
                    child: Text("More Info")
                )
              ],
            )
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
    );
  }
}
