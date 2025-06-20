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
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../audio_aware_screen.dart';
import 'challenges.dart';
import '../audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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

class MainScreen extends AudioAwareScreen {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends AudioAwareScreenState<MainScreen> {
  int currentIndex = 0;
  int userScore = 0;

  int currentDay = 1;
  DateTime? lastClaimed;
  Duration timeUntilNext = Duration.zero;
  Timer? timer;
  bool rewardAvailable = false;

  final rewardScores = [0, 25, 50, 75, 100, 125, 150, 200];

  final List<Map<String, dynamic>> games = [
    {"name": "Card Flipper", "image": "assets/images/CardFlipGame/00.png"},
    {"name": "Snake Game", "image": "assets/images/snake.png"},
    {"name": "Tic Tac Toe", "image": "assets/images/tic-tac-toe.png"},
    {"name": "2048", "image": "assets/images/2048_g2.jpeg"},
    {"name": "Runner Game", "image": "assets/images/runner.png"},
    {"name": "Quiz Game", "image": "assets/images/quiz.png"},
  ];

  @override
  void initState() {
    super.initState();
    fetchUserScore();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchUserScore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          userScore = data['score'] ?? 0;
          lastClaimed = data['lastClaimed']?.toDate();
          currentDay = data['rewardDay'] ?? 1;
        });
        checkRewardStatus();
      }
    }
  }

  void checkRewardStatus() {
    final now = DateTime.now();
    if (lastClaimed == null || now.difference(lastClaimed!).inHours >= 48) {
      // Missed a day
      currentDay = 1;
      rewardAvailable = true;
    } else if (now.day != lastClaimed!.day) {
      rewardAvailable = true;
    } else {
      rewardAvailable = false;
    }

    final nextReset = DateTime(now.year, now.month, now.day + 1);
    timeUntilNext = nextReset.difference(now);
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        checkRewardStatus();
        timeUntilNext -= Duration(seconds: 1);
      });
    });
  }

  Future<void> claimReward() async {
    if (!rewardAvailable) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final scoreToAdd = rewardScores[currentDay];
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userDoc);
      final currentScore = snapshot.data()?['score'] ?? 0;

      // Update main score
      transaction.update(userDoc, {
        'score': currentScore + scoreToAdd,
        'lastClaimed': Timestamp.now(),
        'rewardDay': currentDay < 7 ? currentDay + 1 : 1,
      });

      // Add score history entry
      final historyRef = userDoc.collection('scoreHistory').doc();
      transaction.set(historyRef, {
        'score': scoreToAdd,
        'source': 'Daily Reward',
        'timestamp': FieldValue.serverTimestamp(),
        'details': 'Day $currentDay reward claimed'
      });
    });

    setState(() {
      userScore += scoreToAdd;
      lastClaimed = DateTime.now();
      currentDay = currentDay < 7 ? currentDay + 1 : 1;
      rewardAvailable = false;
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("🎉 Congratulations!"),
        content: Text("You received +$scoreToAdd points!"),
        actions: [
          TextButton(
              child: Text("OK"),
              onPressed: () {
                AudioService().playClickSound();
                Navigator.of(context).pop();
              }),
        ],
      ),
    );
  }

  void openDrawer() {
    // Using our helper method from AudioAwareScreenState
    showAudioControls(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! < 0) {
            // Swipe Right → ProfileScreen
            Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  transitionDuration: Duration(milliseconds: 300),
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      LeaderboardPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(1.0, 0.0), // slide from right
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                ));
          }
          // Swipe Left → do nothing
        }
      },
      child: Scaffold(
        backgroundColor: isDarkMode ? Color(0xFF121212) : Colors.white,
        appBar: AppBar(
          backgroundColor: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
          elevation: 0,
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
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                AudioService().playClickSound();
                openDrawer();
              },
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
        body: RefreshIndicator(
          onRefresh: fetchUserScore,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: isDarkMode ? Colors.blue[900] : Colors.blue,
                  width: double.infinity,
                  child: Row(
                    children: [
                      Text("SCORE: ",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Text(userScore.toString(),
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                  padding: EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color.fromARGB(255, 22, 4, 124)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Daily Reward - Day $currentDay",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text("Get +${rewardScores[currentDay]} points today!"),
                      SizedBox(height: 8),
                      rewardAvailable
    ? ElevatedButton(
        onPressed: () {
          AudioService().playClickSound(); 
          claimReward();                   
        },
        child: Text("Claim Reward"),
      )
                          : Text(
                              "Next reward in: ${timeUntilNext.inHours.remainder(24).toString().padLeft(2, '0')}h "
                              "${timeUntilNext.inMinutes.remainder(60).toString().padLeft(2, '0')}m"),
                    ],
                  ),
                ),
                Container(
                  height: 150,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
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
                          AudioService().playClickSound();
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
                // Moved Challenges container to the bottom
                GestureDetector(
                  onTap: () {
                    AudioService().playClickSound();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChallengesScreen()),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                    padding: EdgeInsets.only(
                        top: 12, left: 16, right: 16, bottom: 16),
                    height: 130, // Added fixed height
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.deepPurple.shade800),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.track_changes,
                                color: Colors.deepPurple, size: 30),
                            SizedBox(width: 12),
                            Text(
                              "Challenges",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.deepPurple.shade800,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Complete challenges to earn more points!",
                          style: TextStyle(
                            color: Colors.deepPurple.shade600,
                          ),
                        ),
                        Spacer(),
                        Row(
                          children: [
                            Spacer(),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.deepPurple.shade800,
                              size: 24,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
            ),
          ),
          child: CustomBottomBar(
            currentIndex: currentIndex,
            onTap: (index) {
              AudioService().playClickSound();
              if (index == 1) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          LeaderboardPage(initialIndex: index)),
                  (route) => false,
                );
              } else if (index == 2) {
                AudioService().playClickSound();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AdsScreen(initialIndex: index)),
                  (route) => false,
                );
              } else if (index == 3) {
                AudioService().playClickSound();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
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
      ),
    );
  }
}