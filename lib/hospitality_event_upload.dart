import 'package:date_field/date_field.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:volunteer_app/helper.dart';

import 'hospitality_dash.dart';
class HospitalityEventUpload extends StatefulWidget {
  const HospitalityEventUpload({Key? key}) : super(key: key);

  @override
  State<HospitalityEventUpload> createState() => _HospitalityEventUploadState();
}

class _HospitalityEventUploadState extends State<HospitalityEventUpload> {
  TextEditingController nameController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();
  var startDate;
  var startTime;
  var endTime;
  TextEditingController locationController = new TextEditingController();
  TextEditingController requirementController = new TextEditingController();
  TextEditingController spotsController = new TextEditingController();

  Future<void> uploadForm() async {
    //Events
      //UID
        //timestamp
          //form data

    int timestamp = DateTime.now().millisecondsSinceEpoch;
    DateTime sD = startDate as DateTime;
    DateTime sT = startTime as DateTime;
    DateTime eT = endTime as DateTime;
    await FirebaseDatabase.instance.ref().child("Events").child(getUID()).child(timestamp.toString()).set(
        {
          "name": nameController.text,
          "description": descriptionController.text,
          "start date": DateFormat("MM/dd/yy").format(sD),
          "start time": DateFormat ("hh:mm").format(sT) + " " + sT.timeZoneName,
          "end time": DateFormat ("hh:mm").format(eT) + " " + sT.timeZoneName,
          "location": locationController.text,
          "requirement": requirementController.text,
          "spots": spotsController.text,
        }).then((value) {
       print("Uploaded form successfully");

       //navigate back to the dashboard page for hospitality members
       Navigator.push(
         context,
         MaterialPageRoute(builder: (context) => const HospitalityDash()),
       );
    }).catchError((error) {
      print("Could not upload form: " + error.toString());
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text ("Uploading Events"),
      ),
      body: ListView(
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Name"
            ),
          ),
          TextField(
            maxLines: null,
            controller: descriptionController,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Description"
            ),
          ),
          DateTimeField(
              decoration: const InputDecoration(
                  hintText: 'Start Date'),
              selectedDate: startDate,
              mode: DateTimeFieldPickerMode.date,
              onDateSelected: (DateTime value) {
                setState(() {
                  startDate = value;
                });
              }),
          DateTimeField(
              decoration: const InputDecoration(
                  hintText: 'Start Time'),
              selectedDate: startTime,
              mode: DateTimeFieldPickerMode.time,
              onDateSelected: (DateTime value) {
                setState(() {
                  startTime = value;
                });
              }),
          DateTimeField(
              decoration: const InputDecoration(
                  hintText: 'End Time'),
              selectedDate: endTime,
              mode: DateTimeFieldPickerMode.time,
              onDateSelected: (DateTime value) {
                setState(() {
                  endTime = value;
                });
              }),
          TextField(
            controller: locationController,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Location"
            ),
          ),
          TextField(
            maxLines: null,
            controller: requirementController,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Requirement for Volunteers"
            ),
          ),
          TextField(
            controller: spotsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Spots"
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          uploadForm();
        },
        child: Icon(Icons.check),
      ),
    );
  }
}