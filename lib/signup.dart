import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:volunteer_app/helper.dart';
import 'package:volunteer_app/requester_dash.dart';
import 'package:volunteer_app/volunteer_dash.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
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
        "username" : usernameController.text,
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
        MaterialPageRoute(builder: (context) => const VolunteerDash()),
      );
    }
    else if (type == "requester") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RequesterDash()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up"),
      ),
      body: Column(
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
          TextField(
            controller: usernameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Username',
            ),
          ),
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
            title: Text("Requester"),
            leading: Radio(
              value: "requester",
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
            child: Text("Sign Up"),
          )
        ],
      ),
    );
  }
}
