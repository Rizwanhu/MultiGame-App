import 'package:flutter/material.dart';
import 'Bottombar.dart';
import 'main_screen.dart';
import 'Leaderboard.dart';
import 'profile_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cash Card UI',
      home: AdsScreen(),
    );
  }
}

class AdsScreen extends StatefulWidget {
  final int initialIndex;
  const AdsScreen({this.initialIndex = 2, super.key});

  @override
  State<AdsScreen> createState() => _AdsScreenState();
}

class _AdsScreenState extends State<AdsScreen> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Color(0xFFEFEAFE), // Light purple background
        body: Center(
          child: Container(
            width: size.width * 0.85,
            height: size.height * 0.8,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 25,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Shadow below the image
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: 120,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.5), // Increased opacity
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.5), // Increased opacity
                              blurRadius: 20, // Increased blur
                              spreadRadius: 4, // Increased spread
                              offset: Offset(0, 2), // Added offset
                            )
                          ],
                        ),
                      ),
                    ),
                    // Main image
                    Image.asset(
                      'assets/images/trophy.gif',
                      width: 130,
                      height: 130,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Watch Ads',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A2D5A),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Lorem ipsum dolor sit amet,\nconsectetur adipiscing elit.\nEtiam vel mattis velit.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.5,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {},
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF5793F3),
                          Color(0xFF3A74F2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          offset: Offset(0, 8),
                          blurRadius: 15,
                        ),
                        BoxShadow(
                          color: Colors.blue.shade800.withOpacity(0.2),
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.blue.shade900,
                          width: 1.2,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Start',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomBar(
          currentIndex: currentIndex,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MainScreen()),
                (route) => false,
              );
            } else if (index == 1) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LeaderboardPage()),
                (route) => false,
              );
            } else if (index == 3) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
                (route) => false,
              );
            }
          },
        ),
      ),
    );
  }
}
