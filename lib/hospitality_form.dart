import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:volunteer_app/hospitality_dash.dart';

import 'helper.dart';

class HospitalityForm extends StatefulWidget {
  const HospitalityForm({Key? key}) : super(key: key);

  @override
  State<HospitalityForm> createState() => _HospitalityFormState();
}

class _HospitalityFormState extends State<HospitalityForm> {
  //name
  TextEditingController nameController = TextEditingController();
  //description
  TextEditingController descriptionController = TextEditingController();
  //phone number
  String phoneNumber = "";
  //address
  TextEditingController addressController = TextEditingController();

  //bool is true/false
  bool formCompleted = true;

  //upload the data to firebase
  Future<void> updateInfo() async {
    await FirebaseDatabase.instance.ref().child("Hospitality").child(getUID()).set(
        {
          "name": nameController.text,
          "description": descriptionController.text,
          "phone number": phoneNumber,
          "address": addressController.text,
        }
    ).then((value) {
      print("Successfully uploaded your data");

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HospitalityDash()),
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
            controller: addressController,
            maxLines: null,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Address"
            ),
          ),

          if (formCompleted == false)
            Text("You must fill in required parts of the form!"),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  formCompleted = validate(
                      [
                        nameController.text,
                        addressController.text,
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
