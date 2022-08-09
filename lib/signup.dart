import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:volunteer_app/helper.dart';
import 'package:volunteer_app/hospitality_dash.dart';
import 'package:volunteer_app/hospitality_form.dart';
import 'package:volunteer_app/volunteer_dash.dart';
import 'package:volunteer_app/volunteer_form.dart';

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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Expanded(
        flex: 30,
        child: Center(
          child: Text(
            "APP NAME",
            style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),

        Expanded(
          flex: 20,
          child:
          Column(
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Email',
                ),
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Password',
                ),
              ),
            ],
          ),
        ),

          Expanded(
            flex: 20,
            child: Column(
              children: [
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
              ],
            ),
          ),

          Expanded(
            flex: 5,
            child: ElevatedButton(
              onPressed: signUp,
              child: Text("Sign Up"),
            ),
          ),

          Expanded(
              flex: 25,
              child: Container()
          )
        ],
      ),
    );
  }
}
