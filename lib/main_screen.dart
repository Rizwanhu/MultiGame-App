import 'package:flutter/material.dart';
import 'Leaderboard.dart';
import 'gameDetail.dart';
import 'Bottombar.dart';  // Add this import
import 'GameCard.dart';  // Add this import
import 'profile_screen.dart';  // Add this import
import 'media_grid.dart';  // Add this import
import 'ads_screen.dart';


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
  double volumeValue = 50.0;
  bool isMusicOn = true;

  void openDrawer() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Settings", 
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Volume"),
                      Expanded(
                        child: Slider(
                          value: volumeValue,
                          min: 0,
                          max: 100,
                          onChanged: (val) {
                            setModalState(() {
                              setState(() {
                                volumeValue = val;
                              });
                            });
                            // TODO: Implement volume control logic here
                          },
                        ),
                      ),
                      Text("${volumeValue.round()}"),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Music"),
                      Switch(
                        value: isMusicOn,
                        onChanged: (val) {
                          setModalState(() {
                            setState(() {
                              isMusicOn = val;
                            });
                          });
                          // TODO: Implement music toggle logic here
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
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
        title: Row(
          children: [
            // Image.asset(
            //   'assets/images/giphy.gif',
            //   width: 30,
            //   height: 40,
            //   fit: BoxFit.contain,
            // ),
            // SizedBox(width: 8),
            Text(
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
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: openDrawer,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 2.0),
            child: Image.asset(
              'assets/images/robot.gif',
              width: 50,
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const DiagonalMediaGrid(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
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
                          builder: (context) => GameDetailScreen(
                            gameName: game["name"],
                            gameImage: game["image"],
                          ),
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
                builder: (context) => AdsScreen(initialIndex: index),
              ),
              (route) => false,
            );
          } else if (index == 3) {
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
