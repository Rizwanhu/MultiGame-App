import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Leaderboard.dart';
import '../components/gameDetail.dart';
import '../../components/Bottombar.dart';
import '../components/GameCard.dart';
import 'profile_screen.dart';
import '../components/media_grid.dart';
import 'ads_screen.dart';
import '../theme/theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MultiGameApp(),
    ),
  );
}

class MultiGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode,
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
  int userScore = 1250;

  void openDrawer() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
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
                  Text(
                    "Settings", 
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
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Dark Mode"),
                      Switch(
                        value: themeProvider.themeMode == ThemeMode.dark,
                        onChanged: (val) {
                          themeProvider.toggleTheme(val);
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
    {"name": "Card Flipper", "image": "assets/images/CardFlipGame/00.png"},  // Add this as first game
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF121212) : Colors.white,  // Added explicit background color
      appBar: AppBar(
        backgroundColor: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,  // Added background color
        elevation: 0,  // Added to match theme style
        automaticallyImplyLeading: false,
        toolbarHeight: 45,
        title: Row(
          children: [
            Text(
              "Multigame App",
              style: TextStyle(
                fontSize: 28,
                fontFamily: 'LuckiestGuy',
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
                letterSpacing: 2.0,
                shadows: [
                  Shadow(
                    color: isDarkMode ? Colors.black : Colors.white,
                    blurRadius: 5,
                    offset: Offset(2, 2),
                  )
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
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: isDarkMode ? Colors.blue[900] : Colors.blue,  // Adjusted dark mode color
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "SCORE: ",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    userScore.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            Container(
              height: 150,
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8), // Reduced horizontal padding from 20 to 12
              child: const DiagonalMediaGrid(),
            ),
            
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
      bottomNavigationBar: Theme(  // Wrapped bottomNavigationBar with Theme
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
          ),
        ),
        child: CustomBottomBar(
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