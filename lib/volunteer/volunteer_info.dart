import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:volunteer_app/helper.dart';
import 'package:volunteer_app/main.dart';
import 'package:volunteer_app/volunteer/volunteer_public_profile.dart';
class VolunteerInfo extends VolunteerPublicProfile {
  const VolunteerInfo({Key? key}) : super(key: key);

  @override
  State<VolunteerPublicProfile> createState() => _VolunteerInfoState();
}

class _VolunteerInfoState extends VolunteerPublicProfileState {
  bool formCompleted = true;

  TextEditingController userNameController = new TextEditingController();
  String newPhoneNumber = "";
  TextEditingController ageController = new TextEditingController();
  TextEditingController instrumentController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();

  // methods are chunks of code that perform specific tasks
  void validateForm() {
    bool confirmed = false;
    confirmed = userNameController.text.isNotEmpty;
    confirmed = newPhoneNumber.isNotEmpty;
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
    userNameController.text = volunteerData.name;
    descriptionController.text = volunteerData.description;
    ageController.text = volunteerData.age.toString();
    instrumentController.text = volunteerData.instrument;

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
              initialValue: volunteerData.phoneNumber,
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
      body: backgroundGradient(profileBody()),
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

