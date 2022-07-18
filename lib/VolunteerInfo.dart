import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:volunteer_app/helper.dart';
class VolunteerInfo extends StatefulWidget {
  const VolunteerInfo({Key? key}) : super(key: key);

  @override
  State<VolunteerInfo> createState() => _VolunteerInfoState();
}

class _VolunteerInfoState extends State<VolunteerInfo> {
  //stores user's name
  String userName = "";

  //constructors run before the screen is first loaded
  _VolunteerInfoState() {
    fetchData();
  }

  // we will make a method to grab the information.
  // methods are chunks of code that perform specific tasks
  // this is a special method called an asynchronous method (a method that runs in the background)
  Future<void> fetchData() async {
    await FirebaseDatabase.instance.ref().child("Volunteers").child(getUID()).once().
    then((event) {
      var info = event.snapshot.value as Map;

      // setState reloads the page with new information
      setState(() {
        //reloaded page will have correct username
        userName = info["name"];
      });
    }).
    catchError((error) {
      print("Could not grab information: " + error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar (
        title: Text ("Volunteer Info"),
      ),
      body: Column (
        children: [
          Text(userName),
          TextField(
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Email"
            ),
          ),
          TextField(
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Phone Number"
            ),
          ),
          TextField(
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Instrument(s)"
            ),
          ),
          TextField(
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Proof of talent"
            ),
          ),
        ],
      ),
    );
  }
}

