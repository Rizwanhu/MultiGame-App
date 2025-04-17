import 'package:flutter/material.dart';

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
    {"name": "Ping Pong", "image": "assets/images/pingpong.png"},
    {"name": "Darts", "image": "assets/images/darts.png"},
    {"name": "Snake Game", "image": "assets/images/snake.png"},
    {"name": "Tic Tac Toe", "image": "assets/images/tic-tac-toe.png"},
    {"name": "Ping Pong", "image": "assets/images/pingpong.png"},
    {"name": "Darts", "image": "assets/images/darts.png"},
    {"name": "Snake Game", "image": "assets/images/snake.png"},
    {"name": "Tic Tac Toe", "image": "assets/images/tic-tac-toe.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Multigame App"),
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
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: games.map((game) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlankScreen(gameName: game["name"]),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(game["image"], width: 80, height: 80),
                          SizedBox(height: 10),
                          Text(game["name"], style: TextStyle(fontWeight: FontWeight.bold))
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: Text("Home"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LeaderboardScreen()),
                  );
                },
                child: Text("Leaderboard"),
              ),
            ],
          ),
        ),
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

class LeaderboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Leaderboard")),
      body: Center(
        child: Text(
          "Leaderboard Screen",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
