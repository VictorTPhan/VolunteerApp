import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:volunteer_app/helper.dart';
class HospitalityEventPage extends StatefulWidget {
  const HospitalityEventPage({Key? key}) : super(key: key);

  @override
  State<HospitalityEventPage> createState() => _HospitalityEventPageState();
}

class TimeStamp {
  static String timeStamp = "";
}

class _HospitalityEventPageState extends State<HospitalityEventPage> {

  String name = "";
  String description = "";
  String startDate = "";
  String startTime = "";
  String endTime = "";
  String location = "";
  String requirement = "";
  String spots = "";

  TextEditingController nameController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();
  TextEditingController locationController = new TextEditingController();
  TextEditingController requirementController = new TextEditingController();
  TextEditingController spotsController = new TextEditingController();

  _HospitalityEventPageState() {
    fetchInfo();
  }

  //write a method that fetches information about an event given a timestamp
  Future<void> fetchInfo() async {
    await FirebaseDatabase.instance.ref().child("Events").child(getUID()).child(TimeStamp.timeStamp).once().
    then((event) {
      var info = event.snapshot.value as Map;
      setState(() {
        name = info["name"];
        description = info["description"];
        startDate = info["start date"];
        startTime = info["start time"];
        endTime = info["end time"];
        location = info["location"];
        requirement = info["requirement"];
        spots = info["spots"];
      });
    }).catchError((error) {
      print("Could not fetch info: " + error.toString());
    });
  }

  Widget showEditPopUp(BuildContext context) {
    return SingleChildScrollView(
      child: AlertDialog(
        title: Text('Edit your profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Name"
              ),
            ),
            TextField(
              controller: descriptionController,
              maxLines: null,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Description"
              ),
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Location"
              ),
            ),
            TextField(
              controller: requirementController,
              maxLines: null,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Requirement"
              ),
            ),
            TextField(
              controller: spotsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Spots"
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  //updateInfo().then((value) {
                  //  fetchData();
                  //});
                  Navigator.pop(context);
                },
                child: Text("Done")
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TimeStamp.timeStamp),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
                name,
                style: TextStyle(
                  fontSize: 40,
                ),
            ),
            Text(
              description,
              style: TextStyle(
                fontSize: 18
              ),
            ),
            Text(
              startDate,
              style: TextStyle(
                fontSize: 18
              ),
            ),
            Text(
              startTime + " to " + endTime,
              style: TextStyle (
                fontSize: 18
              ),
            ),
            Text(
                "Location: " + location,
              style: TextStyle(
                fontSize: 18
              ),
            ),
            Text(
                "Requirements: " + requirement,
              style: TextStyle(
                fontSize: 18
              ),
            ),
            Text(
                "Spots Needed: " + spots,
              style: TextStyle(
                fontSize: 18
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => showEditPopUp(context),
          );
        },
        child: Icon(Icons.edit),
      ),
    );
  }
}