// game_detail_screen.dart
import 'package:flutter/material.dart';

class GameDetailScreen extends StatelessWidget {
  const GameDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Game Screen"),
      ),
      body: const Center(
        child: Text(
          "Welcome to the new page!",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
