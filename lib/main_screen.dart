import 'package:flutter/material.dart';
import 'Leaderboard.dart';
import 'gameDetail.dart';
import 'Bottombar.dart';  // Add this import
import 'GameCard.dart';  // Add this import
import 'profile_screen.dart';  // Add this import


void main() {
  runApp(MultiGameApp());
}

class MultiGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  List<IconData> icons = [Icons.home, Icons.bar_chart, Icons.person];
  List<String> labels = ["Home", "Leaderboard", "Profile"];

  void openDrawer() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Settings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Volume"),
                  Slider(value: 50, min: 0, max: 100, onChanged: (val) {}),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Music"),
                  Switch(value: true, onChanged: (val) {}),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> games = [
    {"name": "Snake Game", "image": "assets/images/snake.png"},
    {"name": "Tic Tac Toe", "image": "assets/images/tic-tac-toe.png"},
    {"name": "Ping Pong", "image": "assets/images/pingpong.png"},
    {"name": "Darts", "image": "assets/images/darts.png"},
    {"name": "Ping Pong", "image": "assets/images/pingpong.png"},
    {"name": "Darts", "image": "assets/images/darts.png"},
    {"name": "Snake Game", "image": "assets/images/snake.png"},
    {"name": "Tic Tac Toe", "image": "assets/images/tic-tac-toe.png"},
    {"name": "Ping Pong", "image": "assets/images/pingpong.png"},
    {"name": "Darts", "image": "assets/images/darts.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 45, // Decreased height
        title: Text(
          "Multigame App",
          style: TextStyle(
            fontSize: 28,
            fontFamily: 'LuckiestGuy',
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 2.0, // Added letter spacing
            shadows: [
              Shadow(
                color: Colors.white,
                blurRadius: 5,
                offset: Offset(2, 2),
              ),
            ],
            decoration: TextDecoration.none,
            decorationColor: Colors.yellow,
            decorationStyle: TextDecorationStyle.solid,
            decorationThickness: 6,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: openDrawer,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
                children: games.map((game) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameDetailScreen(gameName: game["name"], gameImage: game["image"]),
                        ),
                      );
                    },
                    child: GameCard(
                      gameName: game["name"],
                      imagePath: game["image"],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LeaderboardPage(initialIndex: index),
              ),
              (route) => false,
            );
          } else if (index == 2) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(),
              ),
              (route) => false,
            );
          } else {
            setState(() {
              currentIndex = index;
            });
          }
        },
      ),
    );
  }
}

class BlankScreen extends StatelessWidget {
  final String gameName;

  const BlankScreen({required this.gameName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(gameName)),
      body: Center(
        child: Text(
          "Blank screen for $gameName",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
