import 'package:flutter/material.dart';
import 'package:volunteer_app/helper.dart';
import 'package:volunteer_app/hospitality/hospitality_deletion.dart';
import 'package:volunteer_app/hospitality/hospitality_info.dart';
import 'package:volunteer_app/main.dart';

import 'event/hospitality_event_upload.dart';
import 'event/hospitality_event_view.dart';

class HospitalityDash extends StatefulWidget {
  const HospitalityDash({Key? key}) : super(key: key);

  @override
  State<HospitalityDash> createState() => _HospitalityState();
}

class _HospitalityState extends State<HospitalityDash> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: backgroundGradient(
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  height: 90,
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HospitalityEventView()),
                      );
                    },
                    child: Text("Viewing Events"),
                    style: formattedButtonStyle()
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  height: 90,
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HospitalityEventUpload()),
                      );
                    },
                    child: Text("Uploading Events"),
                      style: formattedButtonStyle()
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  height: 90,
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () {
                      HospitalityToLookUp.hospitalityUID = getUID();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HospitalityInfo()),
                      );
                    },
                    child: Text("View Profile"),
                      style: formattedButtonStyle()
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorPalette.mainColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HospitalityDeletion()),
          );
        },
        child: Icon(
            Icons.settings,
            color: Colors.white,
        ),
      ),
    );
  }
}
