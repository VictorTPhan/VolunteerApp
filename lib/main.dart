import 'package:firebase_core/firebase_core.dart';
import 'package:volunteer_app/login.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class ColorPalette {
  static Color mainColor = Color(0xFF0086D9);
  static Color backgroundColor = Color(0xFFF1E7FF);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volunteer App',
      debugShowCheckedModeBanner: false,
      home: const Login(),
    );
  }
}