import 'package:flutter/material.dart';

class GameCard extends StatelessWidget {
  final String gameName;
  final String imagePath;

  const GameCard({super.key, required this.gameName, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800, width: 7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(4, 6),
          ),
        ],
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 20),
          child: Text(
            gameName.toUpperCase(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'LuckiestGuy',
              color: Colors.white,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: Colors.black,
                  blurRadius: 4,
                ),
              ],
              decoration: TextDecoration.none,
              decorationColor: Colors.grey.withOpacity(0.3),
              decorationStyle: TextDecorationStyle.solid,
              decorationThickness: 3,
            ),
          ),
        ),
      ),
    );
  }
}
