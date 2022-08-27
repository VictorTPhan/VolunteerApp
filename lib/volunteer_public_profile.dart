import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'helper.dart';

class VolunteerPublicProfile extends StatefulWidget {
  const VolunteerPublicProfile({Key? key}) : super(key: key);

  @override
  State<VolunteerPublicProfile> createState() => _VolunteerPublicProfileState();
}

class _VolunteerPublicProfileState extends State<VolunteerPublicProfile> {

  VolunteerData volunteerData = VolunteerData("", "", "", "", "", 0);

  _VolunteerPublicProfileState()
  {
    fetchData();
  }

  Future<void> fetchData() async {
    await FirebaseDatabase.instance.ref().child("Volunteers").child(VolunteerToLookUp.volunteerUID).once().
    then((event) {
      var info = event.snapshot.value as Map;

      setState(() {
        volunteerData = VolunteerData(
            VolunteerToLookUp.volunteerUID,
            info["name"],
            info["description"],
            info["phone number"],
            info["instrument"],
            int.parse(info["age"])
        );
      });
    }).catchError((error) {
      print("Could not grab account: " + error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar (
        title: Text ("Volunteer Info"),
      ),
      body: Center(
        child: Column (
          children: [
            Text(volunteerData.name),
            Text(volunteerData.description),
            Text("Age: " + volunteerData.age.toString()),
            Text("Instrument(s): " + volunteerData.instrument),
            Text("Phone Number: " + volunteerData.phoneNumber),
          ],
        ),
      )
    );
  }
}
