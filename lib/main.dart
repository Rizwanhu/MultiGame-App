import 'package:flutter/material.dart';
import 'login_signup.dart';  // Import the login_signup.dart file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  
  // Hello THIS IS RIZWAN REPOOO
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: LoginPage(),  // Calling the LoginSignupScreen from login_signup.dart
    );
  }
}
