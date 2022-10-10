import 'package:date_field/date_field.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:volunteer_app/helper.dart';
import 'package:volunteer_app/main.dart';

import '../../event_page.dart';
class HospitalityEventPage extends EventView {
  const HospitalityEventPage({Key? key}) : super(key: key);

  @override
  State<EventView> createState() => _HospitalityEventPageState();
}

class TimeStamp {
  static String timeStamp = "";
}

class _HospitalityEventPageState extends EventViewState {

  TextEditingController nameController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();
  TextEditingController locationController = new TextEditingController();
  TextEditingController requirementController = new TextEditingController();
  TextEditingController spotsController = new TextEditingController();

  bool formIsValid = true;

  Future<void> uploadForm() async {
    //Events
    //UID
    //timestamp
    //form data

    await FirebaseDatabase.instance.ref().child("Events").child(getUID()).child(TimeStamp.timeStamp).update(
        {
          "name": nameController.text,
          "description": descriptionController.text,
          "location": locationController.text,
          "requirement": requirementController.text,
          "spots": spotsController.text,
        }).then((value) {
      print("Uploaded form successfully");
      fetchInfo();
    }).catchError((error) {
      print("Could not upload form: " + error.toString());
    });
  }

  Widget showEditPopUp(BuildContext context) {
    nameController.text = eventInformation.name;
    descriptionController.text = eventInformation.description;
    locationController.text = eventInformation.location;
    requirementController.text = eventInformation.requirement;
    spotsController.text = eventInformation.spots.toString();

    return SingleChildScrollView(
      child: AlertDialog(
        title: Text('Edit Event Info'),
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
            if (formIsValid == false)
              Text("Form not completed!"),
            ElevatedButton(
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
                    );
                    if (formIsValid)
                    {
                      uploadForm();
                      Navigator.pop(context);
                    }
                  });
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
      body: backgroundGradient(scaffoldBody()),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorPalette.mainColor,
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => showEditPopUp(context),
          );
        },
        child: Icon(
            Icons.edit,
            color: Colors.white,
        ),
      ),
    );
  }
}
