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
        border: Border.all(color: Colors.grey.shade800, width: 7), // Increased border width
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3), // Increased opacity
            blurRadius: 10, // Increased blur
            offset: const Offset(4, 6), // Increased offset
          ),
        ],
      ),
      child: Center(  // Changed to Center
        child: Transform.translate(
          offset: const Offset(0, 9),  // Move text up by 20 pixels
          child: Text(
            gameName.toUpperCase(),  // Capitalize text
            style: const TextStyle(
              fontSize: 20,  // Increased font size
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
              shadows: [  // Added text shadow for better visibility
                Shadow(
                  color: Colors.black,
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
