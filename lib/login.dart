import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:volunteer_app/helper.dart';
import 'package:volunteer_app/hospitality/hospitality_dash.dart';
import 'package:volunteer_app/main.dart';
import 'package:volunteer_app/signup.dart';
import 'package:volunteer_app/volunteer/volunteer_dash.dart';

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
      backgroundColor: ColorPalette.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue,
              ColorPalette.backgroundColor,
            ]
          ),
        ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 50,
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Image.asset("assets/logo.png"),
                ),
              ),
              Expanded(
                flex: 25,
                child: Column(
                  children: [
                    formattedTextField(emailController, "Email", false),
                    formattedTextField(passwordController, "Password", true)
                  ]
                )
              ),
              if (!signInValid)
                Text(
                    "Incorrect username or password!",
                  style: TextStyle(
                    color: Colors.black,
                    backgroundColor: Colors.yellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  ),
                ),
              Expanded(
                flex: 25,
                child: Column(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          signIn();
                        },
                        child: Text("Sign In"),
                        style: formattedButtonStyle()
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignUp()),
                          );
                        },
                        child: Text(
                            "Create Account",
                          style: TextStyle(
                            color: ColorPalette.mainColor,
                            fontSize: 23
                          ),
                        )
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }
}
