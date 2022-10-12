import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:volunteer_app/helper.dart';
import 'package:volunteer_app/main.dart';

import '../login.dart';

class VolunteerDeletion extends StatefulWidget {
  const VolunteerDeletion({Key? key}) : super(key: key);

  @override
  State<VolunteerDeletion> createState() => _VolunteerDeletionState();
}

class _VolunteerDeletionState extends State<VolunteerDeletion> {

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
    await FirebaseDatabase.instance.ref().child("Volunteers").child(getUID()).remove()
        .then((value) {
      print("Deleted user profile.");
    }).catchError((error) {
      print("Could not delete user profile: " + error.toString());
    });
  }

  Future<void> removeFromAllEvents() async {
    await FirebaseDatabase.instance.ref().child("Signups").child(getUID()).once().
    then((event) {
      var info = event.snapshot.value as Map;
      //for every user you find,
      info.forEach((hospitalityUID, listOfTimeStamps) async {
        var timestamps = listOfTimeStamps as Map;
        //look up every timestamp you signed up for
        timestamps.forEach((timeStamp, value) async {
          //look up the event
          await FirebaseDatabase.instance.ref().child("Events").child(hospitalityUID).child(timeStamp).child("volunteers").child(getUID()).remove()
          .then((value) {
            print("Deleted event " + hospitalityUID + " " + timeStamp);
          }).catchError((error)
          {
            print("Couldn't delete this event: " + error.toString());
          });
        });
      });
    }).catchError((error) {
      print("Could not delete all events: " + error.toString());
    });

    await FirebaseDatabase.instance.ref().child("Signups").child(getUID()).remove()
    .then((value) {
      print("Deleted all signups.");
    }).catchError((error) {
      print("Could not delete all signups: " + error.toString());
    });
  }

  Future<void> deleteAccount() async {
    await removeFromAllEvents();
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
