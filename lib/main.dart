import 'package:flutter/material.dart';
import 'logo_screen.dart'; // Import the SplashScreen
import 'main_screen.dart';
//hello world

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(), // Start with SplashScreen
    );
  }
}
