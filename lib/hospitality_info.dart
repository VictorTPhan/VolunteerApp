import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:volunteer_app/hospitality_public_profile.dart';

import 'helper.dart';
class HospitalityInfo extends HospitalityPublicProfile {
  const HospitalityInfo({Key? key}) : super(key: key);

  @override
  State<HospitalityPublicProfile> createState() => _HospitalityInfoState();
}

class _HospitalityInfoState extends HospitalityPublicProfileState {
  bool formCompleted = true;

  TextEditingController userNameController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();
  TextEditingController addressController = new TextEditingController();
  String newPhoneNumber = "";

  //constructors run before the screen is first loaded
  _HospitalityInfoState() {
    fetchData();
  }

  // methods are chunks of code that perform specific tasks
  void validateForm() {
    bool confirmed = false;
    confirmed = userNameController.text.isNotEmpty;
    confirmed = newPhoneNumber.isNotEmpty;
    confirmed = addressController.text.isNotEmpty;

    setState(() {
      formCompleted = confirmed;
    });
  }
  Future<void> updateInfo() async {
    await FirebaseDatabase.instance.ref().child("Hospitality").child(getUID()).update(
        {
          "name": userNameController.text,
          "description": descriptionController.text,
          "address": addressController.text,
          "phone number": newPhoneNumber,
        }
    ).then((value) {
      print("Info updated");
    }).catchError((error) {
      print("Could not update: " + error.toString());
    });
  }

  //shows a popup window to change user info
  Widget showEditPopUp(BuildContext context) {
    userNameController.text = hospitalityData.name;
    descriptionController.text = hospitalityData.description;
    addressController.text = hospitalityData.address;

    return SingleChildScrollView(
      child: AlertDialog(
        title: Text('Edit your profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: userNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Username"
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
              controller: addressController,
              maxLines: null,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Address"
              ),
            ),
            IntlPhoneField(
              initialValue: hospitalityData.phoneNumber.toString(),
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(
                  borderSide: BorderSide(),
                ),
              ),
              onChanged: (phone) {
                newPhoneNumber = phone.number;
              },
              onCountryChanged: (country) {
                print('Country changed to: ' + country.name);
              },
            ),
            ElevatedButton(
                onPressed: () {
                  updateInfo().then((value) {
                    fetchData();
                  });
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
        title: Text("Hospitality Info"),
      ),
      body: profileBody(),
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
