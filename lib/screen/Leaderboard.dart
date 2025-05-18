import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import '../components/Bottombar.dart';
import 'main_screen.dart';
import 'profile_screen.dart';
import 'ads_screen.dart';
import 'league_page.dart';
import 'package:app/audio_service.dart';
import '../audio_aware_screen.dart';


class LeaderboardPage extends AudioAwareScreen {
  final int initialIndex;
  LeaderboardPage({this.initialIndex = 1});

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends AudioAwareScreenState<LeaderboardPage> {
  int userScore = 0;
  late int currentIndex;
  List<Map<String, dynamic>> leaderboardUsers = [];
  bool isLoading = true;
  final defaultImagePath = 'assets/images/default_profile.png';

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    fetchLeaderboardData();
  }

  Future<void> fetchLeaderboardData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (userDoc.exists) {
          setState(() {
            userScore = userDoc['score'] ?? 0;
          });
        }
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('score', descending: true)
          .limit(7)
          .get();

      final topUsers = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'name': data['username'] ?? 'Unknown',
          'score': data['score'] ?? 0,
          'imageBase64': data['photoBase64'],
          'uid': doc.id,
        };
      }).toList();

      setState(() {
        leaderboardUsers = topUsers;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching leaderboard: $e');
      setState(() => isLoading = false);
    }
  }

  ImageProvider _buildProfileImage(String? imageBase64, {double radius = 18}) {
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      try {
        return MemoryImage(base64Decode(imageBase64));
      } catch (e) {
        print('Error decoding base64 image: $e');
      }
    }
    return AssetImage(defaultImagePath);
  }

  String? getBadgeAsset(int score) {
    if (score >= 15000) return 'assets/images/badges/diamond.png';
    if (score >= 6000) return 'assets/images/badges/gold.png';
    if (score >= 2000) return 'assets/images/badges/silver.png';
    if (score >= 750) return 'assets/images/badges/bronze.png';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < 0) {
              Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration(milliseconds: 300),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        AdsScreen(),
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
            } else if (details.primaryVelocity! > 0) {
              Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration(milliseconds: 300),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        MainScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(-1.0, 0.0), // slide from right
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      );
                    },
                  ));
            }
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Score: $userScore',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: fetchLeaderboardData,
              ),
            ],
          ),
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/background_picture.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(color: Colors.black.withOpacity(0)),
                ),
              ),
              Center(
                child: isLoading
                    ? CircularProgressIndicator()
                    : Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                'Leaderboard',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                ),
                              ),
                            ),
                            Divider(),
                            ...List.generate(leaderboardUsers.length, (index) {
                              final user = leaderboardUsers[index];
                              final isTopThree = index < 3;
                              final badgeImage = getBadgeAsset(user['score']);

                              return Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: isTopThree
                                      ? Colors.blue.shade100.withOpacity(0.4)
                                      : Colors.transparent,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.blue[900],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.grey.shade300,
                                      backgroundImage: _buildProfileImage(
                                          user['imageBase64']),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        user['name'],
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        if (badgeImage != null)
                                          Image.asset(
                                            badgeImage,
                                            width: 24,
                                            height: 24,
                                          ),
                                        SizedBox(width: 6),
                                        Text(
                                          '${user['score']}',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
              ),
            ],
          ),
          bottomNavigationBar: CustomBottomBar(
            currentIndex: currentIndex,
            onTap: (index) {
              AudioService().playClickSound();
              if (index == 0) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => MainScreen()),
                  (route) => false,
                );
              } else if (index == 2) {
                AudioService().playClickSound();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => AdsScreen()),
                  (route) => false,
                );
              } else if (index == 3) {
                AudioService().playClickSound();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => ProfileScreen()),
                  (route) => false,
                );
              } else {
                setState(() {
                  currentIndex = index;
                });
              }
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              AudioService().playClickSound();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LeaguePage()),
              );
            },
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.emoji_events), 
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ),
      ),
    );
  }
}
