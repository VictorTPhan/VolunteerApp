import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import 'helper.dart';
class HospitalityInfo extends StatefulWidget {
  const HospitalityInfo({Key? key}) : super(key: key);

  @override
  State<HospitalityInfo> createState() => _HospitalityInfoState();
}

class _HospitalityInfoState extends State<HospitalityInfo> {
  //stores user's name
  String userName = "";
  TextEditingController userNameController = new TextEditingController();

  //stores user's description
  String description = "";
  TextEditingController descriptionController = new TextEditingController();

  //stores user's address
  String address = "";
  TextEditingController addressController = new TextEditingController();

  //stores user's phone number
  String phoneNumber = "";
  String newPhoneNumber = "";

  //stores user's email
  String email = "";
  TextEditingController emailController = new TextEditingController();

  //constructors run before the screen is first loaded
  _HospitalityInfoState() {
    fetchData();
  }

  // we will make a method to grab the information.
  // methods are chunks of code that perform specific tasks
  // this is a special method called an asynchronous method (a method that runs in the background)
  Future<void> fetchData() async {
    await FirebaseDatabase.instance.ref().child("Hospitality").child(getUID()).once().
    then((event) {
      var info = event.snapshot.value as Map;

      // setState reloads the page with new information
      setState(() {
        //reloaded page will have correct username
        userName = info["name"];
        description = info ["description"];
        address = info ["address"];
        phoneNumber = info ["phone number"];
        email = FirebaseAuth.instance.currentUser!.email.toString();
      });
    }).
    catchError((error) {
      print("Could not grab information: " + error.toString());
    });
  }

  //shows a popup window to change user info
  Widget showEditPopUp(BuildContext context) {
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
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Email"
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
                newPhoneNumber = phone.number;
              },
              onCountryChanged: (country) {
                print('Country changed to: ' + country.name);
              },
            ),
            ElevatedButton(
                onPressed: () {
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
      appBar: AppBar (
        title: Text ("Hospitality Info"),
      ),
      body: Center(
        child: Column (
          children: [
            Text(userName),
            Text(description),
            Text("Address: " + address),
            Text ("Phone Number: " + phoneNumber),
            Text("Email: " + email)
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