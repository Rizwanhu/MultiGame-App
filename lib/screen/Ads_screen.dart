import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../components/Bottombar.dart';
import 'main_screen.dart';
import 'Leaderboard.dart';
import 'profile_screen.dart';
import '../../theme/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/audio_service.dart';

class AdsScreen extends StatefulWidget {
  final int initialIndex;
  const AdsScreen({this.initialIndex = 2, Key? key}) : super(key: key);

  @override
  State<AdsScreen> createState() => _AdsScreenState();
}

class _AdsScreenState extends State<AdsScreen> {
  late int currentIndex;
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  bool _isLoading = false;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _loadRewardedAd();
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    _retryTimer?.cancel();
    super.dispose();
  }

  void _loadRewardedAd() {
    print('🔄 Attempting to load rewarded ad...');
    final request = AdRequest();

    RewardedAd.load(
      adUnitId: 'ca-app-pub-2381056381999516/3950724380',
      request: request,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          print('✅ Rewarded ad loaded.');
          setState(() {
            _rewardedAd = ad;
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (error) {
          print(
              '❌ Failed to load rewarded ad: ${error.message} (code: ${error.code})');
          setState(() {
            _isAdLoaded = false;
          });

          _retryTimer?.cancel();
          _retryTimer = Timer(Duration(seconds: 10), _loadRewardedAd);
        },
      ),
    );
  }

  void _showRewardedAd() {
    print(
        '! Ad is not ready. _isAdLoaded: $_isAdLoaded, _rewardedAd is null: ${_rewardedAd == null}');
    if (!_isAdLoaded || _rewardedAd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ad is not ready yet. Please try again later.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        print('🧹 Ad dismissed.');
        ad.dispose();
        _loadRewardedAd();
        setState(() {
          _isLoading = false;
        });
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('❌ Failed to show ad: $error');
        ad.dispose();
        _loadRewardedAd();
        setState(() {
          _isLoading = false;
        });
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        print('🎉 User earned reward: ${reward.amount}');
        _updateUserScore(50);
      },
    );
  }

  void _updateUserScore(int points) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
        
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          // Get current score
          final snapshot = await transaction.get(userDoc);
          final currentScore = snapshot.data()?['score'] ?? 0;
          
          // Update main score
          transaction.update(userDoc, {'score': currentScore + points});
          
          // Add to score history
          final historyRef = userDoc.collection('scoreHistory').doc();
          transaction.set(historyRef, {
            'score': points,
            'source': 'Ad Watch',
            'timestamp': FieldValue.serverTimestamp(),
            'details': 'Earned from watching advertisement'
          });
        });
        
        print('✅ Score and history updated in Firestore!');
      } else {
        print('⚠️ No user signed in.');
      }
    } catch (e) {
      print('❌ Error updating score: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < 0) {
              Navigator.pushReplacement(context, PageRouteBuilder(
  transitionDuration: Duration(milliseconds: 300),
  pageBuilder: (context, animation, secondaryAnimation) => ProfileScreen(),
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
              Navigator.pushReplacement(context, PageRouteBuilder(
  transitionDuration: Duration(milliseconds: 300),
  pageBuilder: (context, animation, secondaryAnimation) => LeaderboardPage(),
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
          backgroundColor: isDarkMode ? Colors.grey[900] : Color(0xFFEFEAFE),
          body: Center(
            child: Container(
              width: size.width * 0.85,
              height: size.height * 0.8,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.4)
                        : Colors.black.withOpacity(0.1),
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
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: 120,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 4,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                        ),
                      ),
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
                          color: isDarkMode ? Colors.white : Color(0xFF1A2D5A),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Watch Ad to get 50 points',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15.5,
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: _isLoading ? null : _showRewardedAd,
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
                          _isLoading ? 'Loading...' : 'Watch Ad',
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
                AudioService().playClickSound();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
                  (route) => false,
                );
              } else if (index == 1) {
                AudioService().playClickSound();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LeaderboardPage()),
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
