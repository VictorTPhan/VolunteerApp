import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'helper.dart';

class HospitalityPublicProfile extends StatefulWidget {
  const HospitalityPublicProfile({Key? key}) : super(key: key);

  @override
  State<HospitalityPublicProfile> createState() => HospitalityPublicProfileState();
}

class HospitalityPublicProfileState extends State<HospitalityPublicProfile> {
  HospitalityData hospitalityData = HospitalityData("", "", "", "", "");

  HospitalityPublicProfileState()
  {
    fetchData();
  }

  Future<void> fetchData() async {
    await FirebaseDatabase.instance.ref().child("Hospitality").child(
        HospitalityToLookUp.hospitalityUID).once().
    then((event) {
      var info = event.snapshot.value as Map;

      setState(() {
        hospitalityData = HospitalityData(
            VolunteerToLookUp.volunteerUID,
            info["name"],
            info["description"],
            info["phone number"],
            info["address"]);
      });
    }).catchError((error) {
      print("Could not grab account: " + error.toString());
    });
  }


  Widget profileBody() {
    return Column (
      children: [
        Expanded(
          flex: 25,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                  height: 150,
                  child: Image.network("https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Circle-icons-profile.svg/1024px-Circle-icons-profile.svg.png")
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          hospitalityData.name,
                          style: TextStyle(
                              fontSize: 33,
                              fontWeight: FontWeight.bold
                          )
                      ),
                      Text(
                        "hospitality",
                        style: TextStyle(
                            fontSize: 24
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(
                color: Colors.black,
                height: 27,
                thickness: 1.8,
              ),
              Text(
                "age: "+hospitalityData.address.toString(),
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Divider(
                color: Colors.black,
                height: 27,
                thickness: 1.8,
              ),
              Text(
                "phone number: "+hospitalityData.phoneNumber,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Divider(
                color: Colors.black,
                height: 27,
                thickness: 1.8,
              ),
              Text(hospitalityData.description,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
          flex: 75,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar (
          title: Text ("Volunteer Info"),
        ),
        body: profileBody()
    );
  }
}
