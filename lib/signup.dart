import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:volunteer_app/helper.dart';
import 'package:volunteer_app/hospitality/hospitality_dash.dart';
import 'package:volunteer_app/hospitality/hospitality_form.dart';
import 'package:volunteer_app/main.dart';
import 'package:volunteer_app/volunteer/volunteer_dash.dart';
import 'package:volunteer_app/volunteer/volunteer_form.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String type = "volunteer";
  bool validSignUp = true;

  Future<void> signUp() async {
    FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text
    ).then((ret) {
      print("Good");
      setInfo();
    }).catchError((error) {
      print("Could not sign up: " + error.toString());
      setState(() {
        validSignUp = false;
      });
    });
  }
  
  Future<void> setInfo() async {
    FirebaseDatabase.instance.ref().child("Users").child(getUID()).set(
      {
        "type" : type
      }
    ).then((ret) {
      goToDash();
    }).catchError((error) {
      print("Could not sign up: " + error.toString());
    });
  }

  void goToDash() {
    if (type == "volunteer") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const VolunteerForm()),
      );
    }
    else if (type == "hospitality") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HospitalityForm()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up"),
      ),
      body: backgroundGradient(
        Column(
          children: [
            formattedTextField(emailController, "Email", false),
            formattedTextField(passwordController, "Password", true),
            ListTile(
              title: Text("Volunteer"),
              leading: Radio(
                value: "volunteer",
                groupValue: type,
                onChanged: (value) {
                  setState(() {
                    type = value.toString();
                  });
                },
              ),
            ),
            ListTile(
              title: Text("Hospitality"),
              leading: Radio(
                value: "hospitality",
                groupValue: type,
                onChanged: (value) {
                  setState(() {
                    type = value.toString();
                  });
                },
              ),
            ),
            if (!validSignUp)
              Text("Could not sign up your account"),
            ElevatedButton(
              onPressed: signUp,
              style: formattedButtonStyle(),
              child: Text("Sign Up"),
            )
          ],
        ),
      )
    );
  }
}
