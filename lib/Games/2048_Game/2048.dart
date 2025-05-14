import 'package:flutter/material.dart';
import 'screens/game_screen.dart';
import './constants.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removed debug banner
      title: KAppTitle,
      theme: ThemeData(
        primarySwatch: kMainColor,
      ),
      home: GameScreen(),
    );
  }
}
