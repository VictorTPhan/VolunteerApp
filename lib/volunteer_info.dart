import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:volunteer_app/helper.dart';
class VolunteerInfo extends StatefulWidget {
  const VolunteerInfo({Key? key}) : super(key: key);

  @override
  State<VolunteerInfo> createState() => _VolunteerInfoState();
}

class _VolunteerInfoState extends State<VolunteerInfo> {
  bool formCompleted = true;

  //stores user's name
  String userName = "";
  TextEditingController userNameController = new TextEditingController();

  //stores user's phone number
  String phoneNumber = "";
  String newPhoneNumber = "";

  //stores user's age
  String age = "";
  TextEditingController ageController = new TextEditingController();

  //stores user's instrument
  String instrument = "";
  TextEditingController instrumentController = new TextEditingController();

  //stores user's email
  String email = "";

  //stores user's description
  String description = "";
  TextEditingController descriptionController = new TextEditingController();

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
        phoneNumber = info["phone  number"];
        age = info["age"];
        instrument = info["instrument"];
        email = FirebaseAuth.instance.currentUser!.email.toString();
        description = info["description"];
      });
    }).
    catchError((error) {
      print("Could not grab information: " + error.toString());
    });
  }

  // methods are chunks of code that perform specific tasks
  void validateForm() {
    bool confirmed = false;
    confirmed = userNameController.text.isNotEmpty;
    confirmed = phoneNumber.isNotEmpty;
    confirmed = ageController.text.isNotEmpty;
    confirmed = instrumentController.text.isNotEmpty;
    print(confirmed);

    setState(() {
      formCompleted = confirmed;
    });
  }

  Future<void> updateInfo() async {
    await FirebaseDatabase.instance.ref().child("Volunteers").child(getUID()).update(
      {
        "name": userNameController.text,
        "description": descriptionController.text,
        "age": ageController.text,
        "instrument": instrumentController.text,
        "phone  number": newPhoneNumber,
      }
    ).then((value) {
      print("Info updated");
    }).catchError((error) {
      print("Could not update: " + error.toString());
    });
  }

  //shows a popup window to change user info
  Widget showEditPopUp(BuildContext context) {
    userNameController.text = userName;
    descriptionController.text = description;
    ageController.text = age;
    instrumentController.text = instrument;

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
              controller: ageController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Age"
              ),
            ),
            TextField(
              controller: instrumentController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Instrument"
              ),
            ),
            IntlPhoneField(
              initialValue: phoneNumber,
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
      appBar: AppBar (
        title: Text ("Volunteer Info"),
      ),
      body: Center(
        child: Column (
          children: [
            Text(userName),
            Text(description),
            Text("Age: " + age),
            Text("Instrument(s): " + instrument),
            Text("Phone Number: " + phoneNumber),
            Text("Email: " + email),
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

