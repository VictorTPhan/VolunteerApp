import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:volunteer_app/helper.dart';
import 'package:volunteer_app/volunteer/volunteer_dash.dart';

class VolunteerForm extends StatefulWidget {
  const VolunteerForm({Key? key}) : super(key: key);

  @override
  State<VolunteerForm> createState() => _VolunteerFormState();
}

class _VolunteerFormState extends State<VolunteerForm> {
  //name
  TextEditingController nameController = TextEditingController();
  //description
  TextEditingController descriptionController = TextEditingController();
  //phone number
  String phoneNumber = "";
  //age
  TextEditingController ageController = TextEditingController();
  //instrument
  TextEditingController instrumentController = TextEditingController();
  //we will request proof of talent

  //bool is true/false
  bool formCompleted = true;

  //upload the data to firebase
  Future<void> updateInfo() async {
    await FirebaseDatabase.instance.ref().child("Volunteers").child(getUID()).set(
      {
        "name": nameController.text,
        "description": descriptionController.text,
        "phone number": phoneNumber,
        "age" : ageController.text,
        "instrument": instrumentController.text
      }
    ).then((value) {
      print("Successfully uploaded your data");

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const VolunteerDash()),
      );
    }).catchError((error) {
      print("We could not upload your data");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Let's get to know you!"),
      ),
      body: Column(
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
                labelText: "Description (optional)"
            ),
          ),
          IntlPhoneField(
            decoration: InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(
                borderSide: BorderSide(),
              ),
            ),
            onChanged: (phone) {
              setState(() {
                phoneNumber = phone.number;
              });
            },
            onCountryChanged: (country) {
              print('Country changed to: ' + country.name);
            },
          ),
          TextField(
            controller: ageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Age"
            ),
          ),
          TextField(
            controller: instrumentController,
            maxLines: null,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Instrument"
            ),
          ),
          if (formCompleted == false)
            Text("You must fill in all parts of the form!"),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  formCompleted = validate(
                    [
                      nameController.text,
                      ageController.text,
                      instrumentController.text,
                      phoneNumber
                    ]
                  );

                  if (formCompleted){
                    updateInfo();
                  }
                });
              },
              child: Text("Complete")
          )
        ],
      ),
    );
  }
}
