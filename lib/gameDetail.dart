import 'package:flutter/material.dart';

class GameDetailScreen extends StatelessWidget {
  final String gameName;
  final String gameImage;

  const GameDetailScreen({
    required this.gameName,
    required this.gameImage,
  });

  // Description logic based on the game name
  String getGameDescription() {
    if (gameName.toLowerCase().contains("snake")) {
      return "Control the snake to collect food and grow longer. Avoid hitting walls and your own tail. The longer the snake, the higher your score!";
    } else if (gameName.toLowerCase().contains("tic")) {
      return "Play against an opponent and place your X or O on the grid. The first to get 3 in a row — horizontally, vertically, or diagonally — wins!";
    } else {
      return "Enjoy playing $gameName!.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDFF3FF),
      body: Column(
        children: [
          // Header
          Container(
            color: Colors.green,
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Text(
                  gameName.toUpperCase(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 10),
                Image.asset(gameImage, height: 80),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    getGameDescription(),
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),

                  // How to Play button
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: show how-to-play screen or dialog
                    },
                     icon: Icon(Icons.ondemand_video), // 🎥 video icon
                    label: Text("HOW TO PLAY"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Play button
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: navigate to the actual game screen
                    },
                    icon: Icon(Icons.play_arrow),
                    label: Text("PLAY"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  Spacer(),

                  // Back button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Back"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[300],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      minimumSize: Size(100, 40),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
