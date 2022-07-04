import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

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