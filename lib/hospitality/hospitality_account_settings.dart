import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:volunteer_app/main.dart';

import '../helper.dart';
import '../login.dart';

class HospitalityDeletion extends StatefulWidget {
  const HospitalityDeletion({Key? key}) : super(key: key);

  @override
  State<HospitalityDeletion> createState() => _HospitalityDeletionState();
}

class _HospitalityDeletionState extends State<HospitalityDeletion> {
  bool permissionGranted = false;

  Future<void> deleteFromUserList() async {
    await FirebaseDatabase.instance.ref().child("Users").child(getUID()).remove()
        .then((value) {
      print("Deleted this user from users list.");
    }).catchError((error) {
      print("Could not delete this user from users list: " + error.toString());
    });
  }

  Future<void> deleteProfile() async {
    await FirebaseDatabase.instance.ref().child("Hospitality").child(getUID()).remove()
        .then((value) {
      print("Deleted user profile.");
    }).catchError((error) {
      print("Could not delete user profile: " + error.toString());
    });
  }

  Future<void> deleteAllEvents() async {
    await FirebaseDatabase.instance.ref().child("Events").child(getUID()).remove().
    then((value) {
      print("Deleted all events.");
    }).catchError((error) {
      print("Could not delete all events: " + error.toString());
    });
  }

  Future<void> deleteAccount() async {
    await deleteAllEvents();
    await deleteProfile();
    await deleteFromUserList();
    await FirebaseAuth.instance.currentUser?.delete();

    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: ColorPalette.mainColor,
          title: Text("Account Settings"),
        ),
        body: backgroundGradient(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 20,
                child: Container(),
              ),
              Expanded(
                flex: 30,
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        height: 100,
                        width: 150,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: StadiumBorder(),
                                primary: ColorPalette.mainColor,
                                textStyle: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold
                                )
                            ),
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const Login()),
                              );
                            },
                            child: Text("Log Out")),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 20,
                child: Container(),
              ),
              Expanded(
                flex: 30,
                child: Column(
                  children: [
                    Text(
                      "If you'd like to, you may delete your account here.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20
                      ),
                    ),
                    ElevatedButton(
                        style: formattedButtonStyle(),
                        onPressed: () {
                          setState(() {
                            permissionGranted = true;
                          });
                        }, child: Text("Yes, delete my account")
                    ),
                    if (permissionGranted)
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: StadiumBorder(),
                              primary: Colors.red,
                              textStyle: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold
                              )
                          ),
                          onPressed: () {
                            deleteAccount().then((value) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const Login()),
                              );
                            }
                            );
                          },
                          child: Text("Delete"))
                  ],
                ),
              )
            ],
          ),
        )
    );
  }
}
