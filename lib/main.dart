import 'package:flutter/material.dart';
import 'logo_screen.dart';
// import 'main_screen.dart';
// import 'Leaderboard.dart';
// import 'register.dart';

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



      //   primarySwatch: Colors.purple,
      //   scaffoldBackgroundColor: Colors.grey[100],
      // ),
      // initialRoute: '/profile',
      // routes: {
      //   '/profile': (context) => const ProfileScreen(),
      //   // Add other routes when you create the home and leaderboard screens
      //   '/home': (context) => const Placeholder(), // Replace with actual home screen
      //   '/leaderboard': (context) => const Placeholder(), // Replace with actual leaderboard screen
      // },