import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl_phone_field/phone_number.dart';

String getUID() {
  return FirebaseAuth.instance.currentUser!.uid;
}

Future<String> getAccountType(String UID) async {
  String ret = "";

  await FirebaseDatabase.instance.ref().child("Users").child(UID).once().then((event) {
    var info = event.snapshot.value as Map;
    ret = info["type"];
  }).catchError((error) {
    print("Could not get account type: " + error.toString());
    ret = "";
  });

  return ret;
}

bool validate(List<String> textsToCheck)
{
  for(String text in textsToCheck)
  {
    if (removeWhiteSpaceFromControllerText(text).isEmpty)
    {
      return false;
    }
  }

  return true;
}

bool validateDateTimes(var startDate, var startTime, var endTime)
{
  if (startDate == null)
    {
      print("start date hasn't been entered!");
      return false;
    }
  
  DateTime sD = startDate as DateTime;
  DateTime sT = startTime as DateTime;
  DateTime eT = endTime as DateTime;
  
  if (eT.compareTo(sT) < 0)
    {
      print("end time is earlier than start time!");
      return false;
    }

  return true;
}

String removeWhiteSpaceFromControllerText(String text)
{
  String result = text.replaceAll(" ", "");
  return result;
}

class EventLookup{
  String timeStamp;
  String UID;

  EventLookup(
      this.timeStamp,
      this.UID
      );
}

class EventInformation{
  String description;
  String endTime;
  String location;
  String name;
  String requirement;
  String spots;
  String startDate;
  String startTime;
  int volunteers;

  EventInformation(
      this.description,
      this.endTime,
      this.location,
      this.name,
      this.requirement,
      this.spots,
      this.startDate,
      this.startTime,
      this.volunteers,
      );
}

class EventToLookUp
{
  static EventLookup lookup = EventLookup("", "");
}

class VolunteerData
{
  String UID;
  String name;
  String description;
  String phoneNumber;
  String instrument;
  int age;

  VolunteerData(
      this.UID,
      this.name,
      this.description,
      this.phoneNumber,
      this.instrument,
      this.age
      );
}

class HospitalityData {
  String UID;
  String name;
  String description;
  String phoneNumber;
  String address;

  HospitalityData(
      this.UID,
      this.name,
      this.description,
      this.phoneNumber,
      this.address,
      );
}

class VolunteerToLookUp
{
  static String volunteerUID = "";
}

class HospitalityToLookUp
{
  static String hospitalityUID = "";
}