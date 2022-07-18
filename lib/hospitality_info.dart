import 'package:flutter/material.dart';
class HospitalityInfo extends StatefulWidget {
  const HospitalityInfo({Key? key}) : super(key: key);

  @override
  State<HospitalityInfo> createState() => _HospitalityInfoState();
}

class _HospitalityInfoState extends State<HospitalityInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Requester Info"),
      ),
      body: Column (
        children: [
          TextField(
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Name"
            ),
          ),
          TextField(
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Address"
            ),
          ),
          TextField(
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Email"
            ),
          ),
          TextField(
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Phone Number"
            ),
          ),
          TextField(
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Description"
            ),
          ),
        ],
      )
    );

  }
}
