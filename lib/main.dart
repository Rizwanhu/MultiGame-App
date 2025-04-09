import 'package:flutter/material.dart';
import 'login_signup.dart';  // Import the login_signup.dart file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),  // Calling the LoginSignupScreen from login_signup.dart
    );
  }
}
