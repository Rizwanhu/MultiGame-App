import 'package:flutter/material.dart';
import 'logo_screen.dart'; 
import 'main_screen.dart';
import 'Leaderboard.dart'; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MultiGame',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(), // Start with SplashScreen
    );
  }
}
