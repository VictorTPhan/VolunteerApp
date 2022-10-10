import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:volunteer_app/main.dart';
import '../helper.dart';

class VolunteerPublicProfile extends StatefulWidget {
  const VolunteerPublicProfile({Key? key}) : super(key: key);

  @override
  State<VolunteerPublicProfile> createState() => VolunteerPublicProfileState();
}

class VolunteerPublicProfileState extends State<VolunteerPublicProfile> {

  VolunteerData volunteerData = VolunteerData("", "", "", "", "", 0);

  VolunteerPublicProfileState()
  {
    fetchData();
  }

  Future<void> fetchData() async {
    await FirebaseDatabase.instance.ref().child("Volunteers").child(VolunteerToLookUp.volunteerUID).once().
    then((event) {
      var info = event.snapshot.value as Map;

      setState(() {
        volunteerData = VolunteerData(
            VolunteerToLookUp.volunteerUID,
            info["name"],
            info["description"],
            info["phone number"],
            info["instrument"],
            int.parse(info["age"])
        );
      });
    }).catchError((error) {
      print("Could not grab account: $error");
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        volunteerData.name,
                        style: const TextStyle(
                            fontSize: 33,
                            fontWeight: FontWeight.bold
                        )
                    ),
                    const Text(
                      "volunteer",
                      style: TextStyle(
                          fontSize: 24
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        Expanded(
          flex: 75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(
                color: Colors.black,
                height: 27,
                thickness: 1.8,
              ),
              Text(
                "age: ${volunteerData.age}",
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              const Divider(
                color: Colors.black,
                height: 27,
                thickness: 1.8,
              ),
              Text(
                "phone number: ${volunteerData.phoneNumber}",
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              const Divider(
                color: Colors.black,
                height: 27,
                thickness: 1.8,
              ),
              Text("instrument: ${volunteerData.instrument}",
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              const Divider(
                color: Colors.black,
                height: 27,
                thickness: 1.8,
              ),
              Text(volunteerData.description,
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar (
        backgroundColor: ColorPalette.mainColor,
        title: Text ("Volunteer Info"),
      ),
      body: backgroundGradient(profileBody())
    );
  }
}
