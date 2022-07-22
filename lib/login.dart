import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:volunteer_app/helper.dart';
import 'package:volunteer_app/hospitality_dash.dart';
import 'package:volunteer_app/signup.dart';
import 'package:volunteer_app/volunteer_dash.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool signInValid = true;

  Future<void> signIn() async {
    FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text
    ).then((ret) {
      goToDash();
    }).catchError((error) {
      setState(() {
        signInValid = false;
      });
    });
  }

  Future<void> goToDash() async {
    String type = await getAccountType(getUID());
    print(type);

    if (type == "volunteer") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const VolunteerDash()),
      );
    }
    else if (type == "hospitality") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HospitalityDash()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
          if (!signInValid)
            Text("Could not sign you in"),
          ElevatedButton(
              onPressed: () {
                signIn();
              },
              child: Text("Sign In")
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUp()),
                );
              },
              child: Text("Sign Up")
          )
        ],
      ),
    );
  }
}
