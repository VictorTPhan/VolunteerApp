import 'package:date_field/date_field.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:volunteer_app/helper.dart';
import 'package:volunteer_app/main.dart';

import 'hospitality_event_view.dart';
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

  bool formIsValid = true;

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
          "start time": DateFormat("hh:mm a").format(sT) + " " + sT.timeZoneName,
          "end time": DateFormat("hh:mm a").format(eT) + " " + sT.timeZoneName,
          "location": locationController.text,
          "requirement": requirementController.text,
          "spots": spotsController.text,
        }).then((value) {
       print("Uploaded form successfully");

       //navigate back to the dashboard page for hospitality members
       Navigator.push(
         context,
         MaterialPageRoute(builder: (context) => const HospitalityEventView()),
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
      body: backgroundGradient(
        ListView(
          children: [
            formattedTextField(nameController, "Name", false),
            formattedTextField(descriptionController, "Description", false, true),
            DateTimeField(
                decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Start Date'),
                initialDate: DateTime.now(),
                selectedDate: startDate,
                mode: DateTimeFieldPickerMode.date,
                onDateSelected: (DateTime value) {
                  setState(() {
                    startDate = value;
                  });
                }),
            DateTimeField(
                decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
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
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'End Time'),
                selectedDate: endTime,
                mode: DateTimeFieldPickerMode.time,
                onDateSelected: (DateTime value) {
                  setState(() {
                    endTime = value;
                  });
                }),
            formattedTextField(locationController, "Location", false),
            formattedTextField(requirementController, "Requirement for Volunteers", false),
            TextField(
              controller: spotsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                  labelText: "Spots"
              ),
            ),
            if (formIsValid == false)
              Text("Form not completed!")
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorPalette.mainColor,
        onPressed: () {
          setState(() {
            formIsValid = validate(
                [
                  nameController.text,
                  descriptionController.text,
                  locationController.text,
                  requirementController.text,
                  spotsController.text
                ]
            )
            && validateDateTimes(startDate, startTime, endTime);
            if (formIsValid)
              {
                uploadForm();
              }
          });
        },
        child: Icon(
            Icons.check,
          color: Colors.white,
        ),
      ),
    );
  }
}